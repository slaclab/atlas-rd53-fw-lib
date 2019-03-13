-------------------------------------------------------------------------------
-- File       : AtlasRd53EmuTimingFsm.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Hit/Trig Module
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
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

entity AtlasRd53EmuTimingFsm is
   generic (
      TPD_G        : time     := 1 ns;
      ADDR_WIDTH_G : positive := 8);
   port (
      -- Clock and reset
      clk             : in  sl;
      rst             : in  sl;
      -- AXI-Lite Interface
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- RAM Interface
      ramAddr         : out slv(ADDR_WIDTH_G-1 downto 0);
      ramData         : in  slv(31 downto 0);
      -- Streaming RD53 Trig Interface (clk160MHz domain)
      trigMaster      : out AxiStreamMasterType;
      trigSlave       : in  AxiStreamSlaveType);
end AtlasRd53EmuTimingFsm;

architecture mapping of AtlasRd53EmuTimingFsm is

   type StateType is (
      IDLE_S,
      RUN_S,
      WAIT_S);

   type RegType is record
      busy            : sl;
      trigger         : sl;
      ramRdy          : sl;
      timeout         : sl;
      ramAddr         : slv(ADDR_WIDTH_G-1 downto 0);
      maxAddr         : slv(ADDR_WIDTH_G-1 downto 0);
      iteration       : slv(15 downto 0);
      loopCnt         : slv(15 downto 0);
      timer           : slv(31 downto 0);
      timerSize       : slv(31 downto 0);
      backpressureCnt : slv(31 downto 0);
      axilReadSlave   : AxiLiteReadSlaveType;
      axilWriteSlave  : AxiLiteWriteSlaveType;
      trigMaster      : AxiStreamMasterType;
      state           : StateType;
   end record;

   constant REG_INIT_C : RegType := (
      busy            => '0',
      trigger         => '0',
      ramRdy          => '0',
      timeout         => '0',
      ramAddr         => (others => '0'),
      maxAddr         => (others => '0'),
      iteration       => (others => '0'),
      loopCnt         => (others => '0'),
      timer           => (others => '0'),
      timerSize       => (others => '0'),
      backpressureCnt => (others => '0'),
      axilReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C,
      trigMaster      => AXI_STREAM_MASTER_INIT_C,
      state           => IDLE_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axilReadMaster, axilWriteMaster, r, ramData, rst, trigSlave) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.trigger := '0';

      -- Update the status flag
      if (r.state = IDLE_S) then
         v.busy := '0';
      else
         v.busy := '1';
      end if;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister(axilEp, x"00", 0, v.trigger);
      axiSlaveRegister(axilEp, x"04", 0, v.timerSize);
      axiSlaveRegister(axilEp, x"08", 0, v.maxAddr);
      axiSlaveRegister(axilEp, x"0C", 0, v.iteration);
      axiSlaveRegisterR(axilEp, x"10", 0, r.backpressureCnt);
      axiSlaveRegisterR(axilEp, x"14", 0, r.busy);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Check the timer
      if (r.timer = r.timerSize) then
         -- Set the flag
         v.timeout := '1';
      else
         -- Increment the counter
         v.timer := r.timer + 1;
      end if;

      -- AXI Stream flow control
      if (trigSlave.tReady = '1') then
         v.trigMaster.tValid := '0';
         v.trigMaster.tLast  := '0';
      end if;

      -- State Machine
      case (r.state) is
         ----------------------------------------------------------------------   
         when IDLE_S =>
            -- Reset the buses
            v.ramAddr := (others => '0');
            v.loopCnt := (others => '0');
            v.ramRdy  := '0';
            v.timeout := '0';
            v.timer   := (others => '0');
            -- Check for start
            if (r.trigger = '1') then
               -- Next state
               v.state := RUN_S;
            end if;
         ----------------------------------------------------------------------
         when RUN_S =>
            -- Set the flag
            v.ramRdy := '1';
            -- Check the flag
            if (r.ramRdy = '1') then
               --Reset the flag
               v.ramRdy := '0';
               -- Check if ready to move data
               if (v.trigMaster.tValid = '0') then
                  -- Move the data
                  v.trigMaster.tValid             := '1';
                  v.trigMaster.tData(31 downto 0) := ramData;
                  -- Check max ram address
                  if (r.ramAddr = r.maxAddr) then
                     -- Reset the address bus 
                     v.ramAddr          := (others => '0');
                     -- Terminate the frame
                     v.trigMaster.tLast := '1';
                     -- Check if max one-shot iteration count
                     if (r.loopCnt = r.iteration) then
                        -- Reset the address bus 
                        v.loopCnt := (others => '0');
                        -- Next state
                        v.state   := IDLE_S;
                     else
                        -- Increment the counter
                        v.loopCnt := r.loopCnt + 1;
                        -- Next state
                        v.state   := WAIT_S;
                     end if;
                  else
                     -- Increment the counter
                     v.ramAddr := r.ramAddr + 1;
                  end if;
               else
                  -- Increment the back pressure counter
                  v.backpressureCnt := r.backpressureCnt + 1;
               end if;
            end if;
         ----------------------------------------------------------------------
         when WAIT_S =>
            if (r.timeout = '1') then
               -- Reset arm the timer
               v.timeout := '0';
               v.timer   := (others => '0');
               -- Next state
               v.state   := RUN_S;
            end if;
      ----------------------------------------------------------------------
      end case;

      if (v.trigger = '1') then
         -- Check if need to terminate frame
         if (v.trigMaster.tValid = '1') then
            -- Terminate the frame
            v.trigMaster.tLast := '1';
         end if;
         -- Next state
         v.state := IDLE_S;
      end if;

      -- Outputs
      ramAddr        <= v.ramAddr;
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      trigMaster     <= r.trigMaster;

      -- Synchronous Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
