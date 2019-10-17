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
use work.SsiPkg.all;

entity AuroraRxChannel is
   generic (
      TPD_G         : time    := 1 ns;
      AXIS_CONFIG_G : AxiStreamConfigType;
      SIMULATION_G  : boolean := false;
      SYNTH_MODE_G  : string  := "inferred");
   port (
      -- Deserialization Interface
      serDesData    : in  Slv8Array(3 downto 0);
      dlyLoad       : out slv(3 downto 0);
      dlyCfg        : out Slv9Array(3 downto 0);
      enUsrDlyCfg   : in  sl;
      usrDlyCfg     : in  Slv9Array(3 downto 0);
      eyescanCfg    : in  Slv8Array(3 downto 0);
      lockingCntCfg : in  slv(23 downto 0);
      bitSlip       : out slv(3 downto 0);
      hdrErrDet     : out slv(3 downto 0);
      -- Timing Interface
      clk160MHz     : in  sl;
      rst160MHz     : in  sl;
      -- Status/Control Interface
      enable        : in  slv(3 downto 0);
      invData       : in  slv(3 downto 0);
      selectRate    : in  slv(1 downto 0);
      linkUp        : out slv(3 downto 0);
      chBond        : out sl;
      wrdSent       : out sl;
      singleHdrDet  : out sl;
      doubleHdrDet  : out sl;
      singleHitDet  : out sl;
      doubleHitDet  : out sl;
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
      singleHdrDet : sl;
      doubleHdrDet : sl;
      singleHitDet : sl;
      doubleHitDet : sl;
      idleDet      : sl;
      autoDet      : sl;
      readBackDet  : sl;
      errorDet     : sl;
      fifoRst      : slv(3 downto 0);
      enable       : slv(3 downto 0);
      aligned      : slv(3 downto 0);
      chBond       : sl;
      rdEn         : slv(3 downto 0);
      cnt          : natural range 0 to 3;
      dataMaster   : AxiStreamMasterType;
      state        : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      singleHdrDet => '0',
      doubleHdrDet => '0',
      singleHitDet => '0',
      doubleHitDet => '0',
      idleDet      => '0',
      autoDet      => '0',
      readBackDet  => '0',
      errorDet     => '0',
      fifoRst      => (others => '1'),
      enable       => (others => '0'),
      aligned      => (others => '0'),
      chBond       => '0',
      rdEn         => (others => '0'),
      cnt          => 0,
      dataMaster   => AXI_STREAM_MASTER_INIT_C,
      state        => INIT_S);

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
            SIMULATION_G => SIMULATION_G)
         port map (
            -- RD53 ASIC Serial Interface
            serDesData    => serDesData(i),
            dlyLoad       => dlyLoad(i),
            dlyCfg        => dlyCfg(i),
            enUsrDlyCfg   => enUsrDlyCfg,
            usrDlyCfg     => usrDlyCfg(i),
            eyescanCfg    => eyescanCfg(i),
            lockingCntCfg => lockingCntCfg,
            bitSlip       => bitSlip(i),
            hdrErrDet     => hdrErrDet(i),
            polarity      => invData(i),
            selectRate    => selectRate,
            -- Timing Interface
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
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => AXIS_CONFIG_G)
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

   comb : process (afull, data, enable, header, invData, r, rst160MHz,
                   rxLinkUp, rxPhyXbar, selectRate, valid) is
      variable v      : RegType;
      variable i      : natural;
      variable phyRdy : sl;
      variable hdrCnt : natural range 0 to 2;
      variable hitCnt : natural range 0 to 2;
      variable word   : slv(31 downto 0);
   begin
      -- Latch the current value
      v := r;

      -- Reset the flags
      v.rdEn              := x"0";
      v.aligned           := x"0";
      v.dataMaster.tValid := '0';
      v.autoDet           := '0';
      v.readBackDet       := '0';
      v.errorDet          := '0';
      v.singleHdrDet      := '0';
      v.doubleHdrDet      := '0';
      v.singleHitDet      := '0';
      v.doubleHitDet      := '0';

      -- Create 8-frame packets before the batcher
      v.dataMaster.tUser(SSI_SOF_C) := '1';  -- SOF   
      v.dataMaster.tLast            := '1';  -- EOF

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

               -- Check for service header
               elsif (header(r.cnt) = "10") then

                  -- Check for data in service header
                  if (data(r.cnt)(63 downto 48) = x"1E04") then
                     -- Move the data
                     v.dataMaster.tValid              := r.enable(r.cnt);
                     v.dataMaster.tData(63 downto 32) := x"FFFF_FFFF";
                     v.dataMaster.tData(31 downto 0)  := data(r.cnt)(31 downto 0);

                  -- Check for both register fields are of type AutoRead
                  elsif (data(r.cnt)(63 downto 56) = x"B4") then
                     -- Set the simulation debug flags
                     v.autoDet     := r.enable(r.cnt);
                     v.readBackDet := '0';

                  -- Check for first frame is AutoRead, second is from a read register command
                  elsif (data(r.cnt)(63 downto 56) = x"55") then
                     -- Set the simulation debug flags
                     v.autoDet     := r.enable(r.cnt);
                     v.readBackDet := r.enable(r.cnt);

                  -- Check for first is from a read register command, second frame is AutoRead
                  elsif (data(r.cnt)(63 downto 56) = x"99") then
                     -- Set the simulation debug flags
                     v.autoDet     := r.enable(r.cnt);
                     v.readBackDet := r.enable(r.cnt);

                  -- Check for both register fields are from read register commands
                  elsif (data(r.cnt)(63 downto 56) = x"D2") then
                     -- Set the simulation debug flags
                     v.autoDet     := '0';
                     v.readBackDet := r.enable(r.cnt);

                  -- Check for both register fields are from read register commands
                  elsif (data(r.cnt)(63 downto 56) = x"CC") then
                     -- Set the simulation debug flag
                     v.errorDet := '1';

                  end if;

                  -- Check for IDLE
                  if (data(r.cnt)(63 downto 56) = x"78") then
                     -- Set the simulation debug flag
                     v.idleDet := '1';
                  else
                     -- Set the simulation debug flag
                     v.idleDet := '0';
                  end if;

               end if;

               -- Increment the counter
               if r.cnt = 3 then
                  v.cnt := 0;
               else
                  v.cnt := r.cnt + 1;
               end if;

               -- Setup the debugging when AXI stream width is 128-bit (not used in 64-bit mode)
               v.dataMaster.tData(127 downto 124) := enable;
               v.dataMaster.tData(123 downto 120) := invData;
               v.dataMaster.tData(119 downto 118) := toSlv(r.cnt, 2);
               v.dataMaster.tData(117 downto 116) := selectRate;
               v.dataMaster.tData(115 downto 114) := rxPhyXbar(0);
               v.dataMaster.tData(113 downto 112) := rxPhyXbar(1);
               v.dataMaster.tData(111 downto 110) := rxPhyXbar(2);
               v.dataMaster.tData(109 downto 108) := rxPhyXbar(3);
               v.dataMaster.tData(107)            := v.autoDet;
               v.dataMaster.tData(106)            := v.readBackDet;
               v.dataMaster.tData(105 downto 66)  := (others => '0');
               v.dataMaster.tData(65 downto 64)   := header(r.cnt);

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

      -- Check if word sent
      if (r.dataMaster.tValid = '1') then
         -- Reset the counters
         hdrCnt := 0;
         hitCnt := 0;
         -- Loop through the words
         for i in 1 downto 0 loop
            word := r.dataMaster.tData(32*i+31 downto 32*i);
            -- Check for valid word
            if (word /= x"FFFF_FFFF") then
               -- Check if event header
               if (word(31 downto 25) = "0000001") then
                  hdrCnt := hdrCnt + 1;
               -- Check hit data
               else
                  hitCnt := hitCnt + 1;
               end if;
            end if;
         end loop;
         if hdrCnt = 1 then
            v.singleHdrDet := '1';
         end if;
         if hdrCnt = 2 then
            v.doubleHdrDet := '1';
         end if;
         if hitCnt = 1 then
            v.singleHitDet := '1';
         end if;
         if hitCnt = 2 then
            v.doubleHitDet := '1';
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
      dataMaster   <= r.dataMaster;
      fifoRst      <= r.fifoRst(0);
      linkUp       <= rxLinkUp;
      chBond       <= r.chBond;
      wrdSent      <= r.dataMaster.tValid;
      singleHdrDet <= r.singleHdrDet;
      doubleHdrDet <= r.doubleHdrDet;
      singleHitDet <= r.singleHitDet;
      doubleHitDet <= r.doubleHitDet;

   end process comb;

   seq : process (clk160MHz) is
   begin
      if rising_edge(clk160MHz) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
