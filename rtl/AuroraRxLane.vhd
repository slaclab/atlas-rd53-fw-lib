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

library unisim;
use unisim.vcomponents.all;

entity AuroraRxLane is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      -- RD53 ASIC Serial Interface
      serDesData : in  slv(7 downto 0);
      dlyCfg     : out slv(4 downto 0);
      polarity   : in  sl;
      selectRate : in  slv(1 downto 0);
      -- Timing Interface
      clk160MHz  : in  sl;
      rst160MHz  : in  sl;
      -- Output
      rxLinkUp   : out sl;
      rxValid    : out sl;
      rxHeader   : out slv(1 downto 0);
      rxData     : out slv(63 downto 0));
end AuroraRxLane;

architecture mapping of AuroraRxLane is

   constant SCRAMBLER_TAPS_C : IntegerArray := (0 => 39, 1 => 58);

   signal serDesDataMask : slv(7 downto 0);

   signal phyRxValidVec  : slv(3 downto 0);
   signal phyRxHeaderVec : Slv2Array(3 downto 0);
   signal phyRxDataVec   : Slv64Array(3 downto 0);

   signal phyRxValid  : sl;
   signal phyRxHeader : slv(1 downto 0);
   signal phyRxData   : slv(63 downto 0);

   signal bitslip          : sl;
   signal unscramblerValid : sl;
   signal gearboxAligned   : sl;

   signal reset160MHz     : sl;
   signal reset           : sl;
   signal misalignedEvent : sl;

   signal header : slv(1 downto 0);
   signal data   : slv(63 downto 0);

begin

   U_rst160MHz : entity work.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clk160MHz,
         rstIn  => rst160MHz,
         rstOut => reset160MHz);

   ----------------------------
   -- Support inverted polarity
   ----------------------------
   serDesDataMask <= serDesData when(polarity = '0') else not(serDesData);

   -----------------
   -- Gearbox Module
   -----------------
   U_Gearbox_1280Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 8,
         MASTER_WIDTH_G => 66)
      port map (
         clk                      => clk160MHz,
         rst                      => reset160MHz,
         slip                     => bitslip,
         slaveData(7 downto 0)    => serDesDataMask,
         slaveValid               => '1',
         masterData(63 downto 0)  => phyRxDataVec(0),
         masterData(65 downto 64) => phyRxHeaderVec(0),
         masterValid              => phyRxValidVec(0),
         masterReady              => '1');

   U_Gearbox_640Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 4,
         MASTER_WIDTH_G => 66)
      port map (
         clk                      => clk160MHz,
         rst                      => reset160MHz,
         slip                     => bitslip,
         slaveData(0)             => serDesDataMask(0),
         slaveData(1)             => serDesDataMask(2),
         slaveData(2)             => serDesDataMask(4),
         slaveData(3)             => serDesDataMask(6),
         slaveValid               => '1',
         masterData(63 downto 0)  => phyRxDataVec(1),
         masterData(65 downto 64) => phyRxHeaderVec(1),
         masterValid              => phyRxValidVec(1),
         masterReady              => '1');

   U_Gearbox_320Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 2,
         MASTER_WIDTH_G => 66)
      port map (
         clk                      => clk160MHz,
         rst                      => reset160MHz,
         slip                     => bitslip,
         slaveData(0)             => serDesDataMask(0),
         slaveData(1)             => serDesDataMask(4),
         slaveValid               => '1',
         masterData(63 downto 0)  => phyRxDataVec(2),
         masterData(65 downto 64) => phyRxHeaderVec(2),
         masterValid              => phyRxValidVec(2),
         masterReady              => '1');

   U_Gearbox_160Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 1,
         MASTER_WIDTH_G => 66)
      port map (
         clk                      => clk160MHz,
         rst                      => reset160MHz,
         slip                     => bitslip,
         slaveData(0)             => serDesDataMask(0),
         slaveValid               => '1',
         masterData(63 downto 0)  => phyRxDataVec(3),
         masterData(65 downto 64) => phyRxHeaderVec(3),
         masterValid              => phyRxValidVec(3),
         masterReady              => '1');

   ------------------------------------------------------------
   -- "RD53.SEL_SER_CLK[2:0]" and "selectRate" must be the same
   ------------------------------------------------------------
   process(phyRxDataVec, phyRxHeaderVec, phyRxValidVec, selectRate)
   begin
      if (selectRate = "00") then
         phyRxValid  <= phyRxValidVec(0);
         phyRxHeader <= phyRxHeaderVec(0);
         phyRxData   <= phyRxDataVec(0);
      elsif (selectRate = "01") then
         phyRxValid  <= phyRxValidVec(1);
         phyRxHeader <= phyRxHeaderVec(1);
         phyRxData   <= phyRxDataVec(1);
      elsif (selectRate = "10") then
         phyRxValid  <= phyRxValidVec(2);
         phyRxHeader <= phyRxHeaderVec(2);
         phyRxData   <= phyRxDataVec(2);
      else
         phyRxValid  <= phyRxValidVec(3);
         phyRxHeader <= phyRxHeaderVec(3);
         phyRxData   <= phyRxDataVec(3);
      end if;
   end process;

   ------------------
   -- Gearbox aligner
   ------------------
   U_GearboxAligner : entity work.AuroraRxGearboxAligner
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         clk           => clk160MHz,
         rst           => reset160MHz,
         rxHeader      => phyRxHeader,
         rxHeaderValid => phyRxValid,
         slip          => bitslip,
         dlyConfig     => dlyCfg,
         locked        => gearboxAligned);

   ---------------------------------
   -- Unscramble the data for 64b66b
   ---------------------------------
   unscramblerValid <= gearboxAligned and phyRxValid;
   U_Descrambler : entity work.Scrambler
      generic map (
         TPD_G            => TPD_G,
         DIRECTION_G      => "DESCRAMBLER",
         DATA_WIDTH_G     => 64,
         SIDEBAND_WIDTH_G => 2,
         TAPS_G           => SCRAMBLER_TAPS_C)
      port map (
         clk            => clk160MHz,
         rst            => reset,
         inputValid     => unscramblerValid,
         inputData      => phyRxData,
         inputSideband  => phyRxHeader,
         outputValid    => rxValid,
         outputData     => data,
         outputSideband => header);

   rxHeader <= bitReverse(header);
   rxData   <= bitReverse(data);

   U_Reset : entity work.SynchronizerOneShot
      generic map (
         TPD_G          => TPD_G,
         BYPASS_SYNC_G  => true,
         IN_POLARITY_G  => '0',         -- 0 for active LOW, 1 for active HIGH
         OUT_POLARITY_G => '1',         -- 0 for active LOW, 1 for active HIGH
         PULSE_WIDTH_G  => 1)  -- one-shot pulse width duration (units of clk cycles)
      port map (
         clk     => clk160MHz,
         dataIn  => gearboxAligned,
         dataOut => misalignedEvent);

   process(clk160MHz)
   begin
      if rising_edge(clk160MHz) then
         -- Register to help with timing
         rxLinkUp <= gearboxAligned                 after TPD_G;
         reset    <= misalignedEvent or reset160MHz after TPD_G;
      end if;
   end process;

end mapping;
