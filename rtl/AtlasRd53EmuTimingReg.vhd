-------------------------------------------------------------------------------
-- File       : AtlasRd53EmuTimingReg.vhd
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

entity AtlasRd53EmuTimingReg is
   generic (
      TPD_G        : time     := 1 ns;
      ADDR_WIDTH_G : positive := 8);
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- FSM Interface (clk160MHz domain)
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      busy            : in  sl;
      backpressure    : in  sl;
      trigger         : out sl;
      maxAddr         : out slv(ADDR_WIDTH_G-1 downto 0);
      iteration       : out slv(15 downto 0);
      timerSize       : out slv(31 downto 0));
end AtlasRd53EmuTimingReg;

architecture mapping of AtlasRd53EmuTimingReg is

   type RegType is record
      trigger         : sl;
      maxAddr         : slv(ADDR_WIDTH_G-1 downto 0);
      iteration       : slv(15 downto 0);
      timerSize       : slv(31 downto 0);
      backpressureCnt : slv(31 downto 0);
      axilReadSlave   : AxiLiteReadSlaveType;
      axilWriteSlave  : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      trigger         => '0',
      maxAddr         => (others => '0'),
      iteration       => (others => '0'),
      timerSize       => (others => '0'),
      backpressureCnt => (others => '0'),
      axilReadSlave   => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave  => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

   signal busySync         : sl;
   signal backpressureSync : sl;

begin

   U_busy : entity work.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axilClk,
         dataIn  => busy,
         dataOut => busySync);

   U_backpressure : entity work.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axilClk,
         dataIn  => backpressure,
         dataOut => backpressureSync);

   comb : process (axilReadMaster, axilRst, axilWriteMaster, backpressureSync,
                   busySync, r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.trigger := '0';

      -- Check for back pressure counter
      if (backpressureSync = '1') then
         -- Increment the counter
         v.backpressureCnt := r.backpressureCnt + 1;
      end if;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      axiSlaveRegister (axilEp, x"00", 0, v.trigger);
      axiSlaveRegister (axilEp, x"04", 0, v.timerSize);
      axiSlaveRegister (axilEp, x"08", 0, v.maxAddr);
      axiSlaveRegister (axilEp, x"0C", 0, v.iteration);
      axiSlaveRegisterR(axilEp, x"10", 0, r.backpressureCnt);
      axiSlaveRegisterR(axilEp, x"14", 0, busySync);

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;

      -- Synchronous Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

   U_trigger : entity work.SynchronizerOneShot
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => clk160MHz,
         dataIn  => r.trigger,
         dataOut => trigger);

   U_timerSize : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => timerSize'length)
      port map (
         wr_clk => axilClk,
         din    => r.timerSize,
         rd_clk => clk160MHz,
         dout   => timerSize);

   U_maxAddr : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => maxAddr'length)
      port map (
         wr_clk => axilClk,
         din    => r.maxAddr,
         rd_clk => clk160MHz,
         dout   => maxAddr);

   U_iteration : entity work.SynchronizerFifo
      generic map (
         TPD_G        => TPD_G,
         DATA_WIDTH_G => iteration'length)
      port map (
         wr_clk => axilClk,
         din    => r.iteration,
         rd_clk => clk160MHz,
         dout   => iteration);

end mapping;
