-------------------------------------------------------------------------------
-- File       : AuroraRxChannel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AuroraRxLane
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiStreamPkg.all;

entity AuroraRxChannel is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      XIL_DEVICE_G : string  := "7SERIES";
      SYNTH_MODE_G : string  := "inferred");
   port (
      -- RD53 ASIC Serial Ports
      dPortDataP    : in  slv(3 downto 0);
      dPortDataN    : in  slv(3 downto 0);
      -- Timing Interface
      clk640MHz     : in  sl;
      clk160MHz     : in  sl;
      rst160MHz     : in  sl;
      -- Status/Control Interface
      iDelayCtrlRdy : in  sl;
      enable        : in  slv(3 downto 0);
      invData       : in  slv(3 downto 0);
      linkUp        : out slv(3 downto 0);
      chBond        : out sl;
      rxPhyXbar     : in  Slv2Array(3 downto 0);
      debugStream   : in  sl;
      -- AutoReg and Read back Interface
      dataMaster    : out AxiStreamMasterType;
      configMaster  : out AxiStreamMasterType;
      autoReadReg   : out Slv32Array(3 downto 0));
end AuroraRxChannel;

architecture rtl of AuroraRxChannel is

   type StateType is (
      INIT_S,
      MOVE_S);

   type RegType is record
      fifoRst    : slv(3 downto 0);
      enable     : slv(3 downto 0);
      aligned    : slv(3 downto 0);
      chBond     : sl;
      rdEn       : slv(3 downto 0);
      cnt        : natural range 0 to 3;
      dataMaster : AxiStreamMasterType;
      state      : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      fifoRst    => (others => '1'),
      enable     => (others => '0'),
      aligned    => (others => '0'),
      chBond     => '0',
      rdEn       => (others => '0'),
      cnt        => 0,
      dataMaster => AXI_STREAM_MASTER_INIT_C,
      state      => INIT_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal fifoRst : sl := '1';

   signal rxLinkUp : slv(3 downto 0)        := (others => '0');
   signal rxValid  : slv(3 downto 0)        := (others => '0');
   signal rxHeader : Slv2Array(3 downto 0)  := (others => (others => '0'));
   signal rxData   : Slv64Array(3 downto 0) := (others => (others => '0'));

   signal rxLinkUpOut : slv(3 downto 0)        := (others => '0');
   signal rxValidOut  : slv(3 downto 0)        := (others => '0');
   signal rxHeaderOut : Slv2Array(3 downto 0)  := (others => (others => '0'));
   signal rxDataOut   : Slv64Array(3 downto 0) := (others => (others => '0'));

   signal valid  : slv(3 downto 0)        := (others => '0');
   signal afull  : slv(3 downto 0)        := (others => '0');
   signal rdEn   : slv(3 downto 0)        := (others => '0');
   signal header : Slv2Array(3 downto 0)  := (others => (others => '0'));
   signal data   : Slv64Array(3 downto 0) := (others => (others => '0'));

   attribute dont_touch             : string;
   attribute dont_touch of fifoRst  : signal is "TRUE";
   attribute dont_touch of rxValid  : signal is "TRUE";
   attribute dont_touch of rxHeader : signal is "TRUE";
   attribute dont_touch of rxData   : signal is "TRUE";
   attribute dont_touch of rxLinkUp : signal is "TRUE";
   attribute dont_touch of valid    : signal is "TRUE";
   attribute dont_touch of afull    : signal is "TRUE";
   attribute dont_touch of rdEn     : signal is "TRUE";
   attribute dont_touch of header   : signal is "TRUE";
   attribute dont_touch of data     : signal is "TRUE";

begin

   GEN_LANE : for i in 3 downto 0 generate

      U_Rx : entity work.AuroraRxLane
         generic map (
            TPD_G        => TPD_G,
            XIL_DEVICE_G => XIL_DEVICE_G)
         port map (
            -- RD53 ASIC Serial Interface
            dPortDataP    => dPortDataP(i),
            dPortDataN    => dPortDataN(i),
            polarity      => invData(i),
            iDelayCtrlRdy => iDelayCtrlRdy,
            -- Timing Interface
            clk640MHz     => clk640MHz,
            clk160MHz     => clk160MHz,
            rst160MHz     => rst160MHz,
            -- Output
            rxLinkUp      => rxLinkUpOut(i),
            rxValid       => rxValidOut(i),
            rxHeader      => rxHeaderOut(i),
            rxData        => rxDataOut(i));

      -- Crossbar Switch
      process(clk160MHz)
      begin
         if rising_edge(clk160MHz) then
            rxData(i)   <= rxDataOut(conv_integer(rxPhyXbar(i)))   after TPD_G;
            rxHeader(i) <= rxHeaderOut(conv_integer(rxPhyXbar(i))) after TPD_G;
            rxValid(i)  <= rxValidOut(conv_integer(rxPhyXbar(i)))  after TPD_G;
            rxLinkUp(i) <= rxLinkUpOut(conv_integer(rxPhyXbar(i))) after TPD_G;
         end if;
      end process;

      U_Fifo : entity work.Fifo
         generic map (
            TPD_G           => TPD_G,
            GEN_SYNC_FIFO_G => true,
            FWFT_EN_G       => true,
            PIPE_STAGES_G   => 1,
            SYNTH_MODE_G    => SYNTH_MODE_G,
            MEMORY_TYPE_G   => "block",
            DATA_WIDTH_G    => 66,
            ADDR_WIDTH_G    => 9)
         port map (
            -- Resets
            rst                => fifoRst,
            --Write Ports (wr_clk domain)
            wr_clk             => clk160MHz,
            wr_en              => rxValid(i),
            din(65 downto 64)  => rxHeader(i),
            din(63 downto 0)   => rxData(i),
            almost_full        => afull(i),
            --Read Ports (rd_clk domain)
            rd_clk             => clk160MHz,
            rd_en              => rdEn(i),
            dout(65 downto 64) => header(i),
            dout(63 downto 0)  => data(i),
            valid              => valid(i));

   end generate GEN_LANE;

   U_RdReg : entity work.AtlasRd53RdReg
      generic map (
         TPD_G => TPD_G)
      port map (
         clk160MHz    => clk160MHz,
         rst160MHz    => rst160MHz,
         -- Data Tap Interface
         debugStream  => debugStream,
         rxLinkUp     => rxLinkUp,
         rxValid      => rxValid,
         rxHeader     => rxHeader,
         rxData       => rxData,
         -- AutoReg and Read back Interface
         autoReadReg  => autoReadReg,
         configMaster => configMaster);

   comb : process (afull, data, enable, header, r, rst160MHz, rxLinkUp, valid) is
      variable v      : RegType;
      variable i      : natural;
      variable phyRdy : sl;
   begin
      -- Latch the current value
      v := r;

      -- Reset the flags
      v.rdEn              := x"0";
      v.aligned           := x"0";
      v.dataMaster.tValid := '0';

      -- Shirt Register
      v.fifoRst := r.fifoRst(2 downto 0) & '0';

      -- Keep a delayed copy
      v.enable := enable;

      -- Loop through the channels
      for i in 3 downto 0 loop
         -- Check for alignment and masked off channel
         if (enable(i) = '1') then
            if (valid(i) = '1') and (header(i) = "10") and (data(i) = x"7880_0000_0000_0000") then
               v.aligned(i) := '1';
            end if;
         else
            v.aligned(i) := '1';
         end if;
         -- Check if PHY layer ready
         phyRdy := '1';
         if (enable(i) = '1') and (rxLinkUp(i) = '0') then
            phyRdy := '0';
         end if;
      end loop;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when INIT_S =>
            -- Reset the flag
            v.chBond := '0';
            -- Reset the counter
            v.cnt    := 0;
            -- Check for de-asserted reset
            if (r.fifoRst = 0) then
               -- Check if aligned 
               if (v.aligned = x"F") then
                  -- Accept the data
                  v.rdEn  := x"F";
                  -- Next state
                  v.state := MOVE_S;
               else
                  -- Blowoff unaligned lanes
                  v.rdEn := not(v.aligned);
               end if;
            end if;
         ----------------------------------------------------------------------
         when MOVE_S =>
            -- Set the flag
            v.chBond := '1';
            -- Check for data or masked off channel
            if (valid(r.cnt) = '1') or (r.enable(r.cnt) = '0') then
               -- Accept the data
               v.rdEn(r.cnt) := '1';
               -- Check for data header
               if (header(r.cnt) = "01") then
                  -- Move the data
                  v.dataMaster.tValid             := r.enable(r.cnt);
                  v.dataMaster.tData(63 downto 0) := data(r.cnt);
               -- Check for data in service header
               elsif (header(r.cnt) = "10") and (data(r.cnt)(63 downto 32) = x"1E04_0000") then
                  -- Move the data
                  v.dataMaster.tValid              := r.enable(r.cnt);
                  v.dataMaster.tData(63 downto 32) := x"FFFF_FFFF";
                  v.dataMaster.tData(31 downto 0)  := data(r.cnt)(31 downto 0);
               -- Check for AutoRead or command responds
               elsif (header(r.cnt) = "10") and (
                  (data(r.cnt)(63 downto 56) = x"B4") or  -- both register fields are of type AutoRead
                  (data(r.cnt)(63 downto 56) = x"55") or  -- first frame is AutoRead, second is from a read register command
                  (data(r.cnt)(63 downto 56) = x"99") or  -- first is from a read register command, second frame is AutoRead
                  (data(r.cnt)(63 downto 56) = x"D2")) then  -- both register fields are from read register commands
                  v.dataMaster.tValid             := r.enable(r.cnt);
                  v.dataMaster.tData(63 downto 0) := data(r.cnt);
               end if;
               -- Increment the counter
               if r.cnt = 3 then
                  v.cnt := 0;
               else
                  v.cnt := r.cnt + 1;
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Check for de-asserted reset
      if (r.fifoRst = 0) then
         -- Check the AFULL or enabled changed or physical layer not ready
         if (afull /= 0) or (enable /= r.enable) or (phyRdy = '0') then
            v.fifoRst := x"F";
            v.state   := INIT_S;
         end if;
      end if;

      -- Combinatorial Outputs
      rdEn <= v.rdEn;

      -- Reset
      if (rst160MHz = '1') or (enable = 0) then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

      -- Registered Outputs
      dataMaster <= r.dataMaster;
      linkUp     <= rxLinkUp;
      chBond     <= r.chBond;
      fifoRst    <= r.fifoRst(0);

   end process comb;

   seq : process (clk160MHz) is
   begin
      if rising_edge(clk160MHz) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
