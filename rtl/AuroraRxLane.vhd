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
      serDesData    : in  slv(7 downto 0);
      dlyLoad       : out sl;
      dlyCfg        : out slv(8 downto 0);
      enUsrDlyCfg   : in  sl                    := '0';
      usrDlyCfg     : in  slv(8 downto 0)       := (others => '0');
      eyescanCfg    : in  slv(7 downto 0)       := toSlv(80, 8);
      lockingCntCfg : in  slv(23 downto 0)      := ite(SIMULATION_G, x"00_0064", x"00_FFFF");
      hdrErrDet     : out sl;
      bitSlip       : out sl;
      polarity      : in  sl := '1';
      selectRate    : in  slv(1 downto 0)       := (others => '0');
      -- Timing Interface
      clk160MHz     : in  sl;
      rst160MHz     : in  sl;
      -- Output
      rxLinkUp      : out sl;
      rxValid       : out sl;
      rxHeader      : out slv(1 downto 0);
      rxData        : out slv(63 downto 0));
end AuroraRxLane;

architecture mapping of AuroraRxLane is

   ------------------------------------------------------------------------------------------------------
   -- Scrambler Taps: G(x) = 1 + x^39 + x^58 (Equation 5-1)
   -- https://www.xilinx.com/support/documentation/ip_documentation/aurora_64b66b_protocol_spec_sp011.pdf
   ------------------------------------------------------------------------------------------------------
   constant SCRAMBLER_TAPS_C : IntegerArray := (0 => 39, 1 => 58);

   signal serDesDataMask : slv(7 downto 0);

   signal phyRxValidVec  : slv(3 downto 0);
   signal phyRxHeaderVec : Slv2Array(3 downto 0);
   signal phyRxDataVec   : Slv64Array(3 downto 0);

   signal phyRxValid  : sl;
   signal phyRxHeader : slv(1 downto 0);
   signal phyRxData   : slv(63 downto 0);

   signal slip             : sl;
   signal unscramblerValid : sl;
   signal gearboxAligned   : sl;

   signal rxValidOut      : sl;
   signal reset160MHz     : sl;
   signal reset           : sl;
   signal misalignedEvent : sl;

   signal header : slv(1 downto 0);
   signal data   : slv(63 downto 0);

   attribute dont_touch                : string;
   attribute dont_touch of phyRxValid  : signal is "TRUE";
   attribute dont_touch of phyRxHeader : signal is "TRUE";
   attribute dont_touch of phyRxData   : signal is "TRUE";

begin

   bitSlip <= slip;

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

   -------------------------------------------------------------------------------------------------------------
   -- Gearbox Module: Refer to "Figure 7-1: Serialization Order for Aurora 64B/66B Block Codes" for bit ordering
   -- https://www.xilinx.com/support/documentation/ip_documentation/aurora_64b66b_protocol_spec_sp011.pdf
   -------------------------------------------------------------------------------------------------------------
   U_Gearbox_1280Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 8,
         MASTER_WIDTH_G => 66)
      port map (
         clk                     => clk160MHz,
         rst                     => reset160MHz,
         slip                    => slip,
         slaveData(7 downto 0)   => serDesDataMask,
         slaveValid              => '1',
         masterData(1 downto 0)  => phyRxHeaderVec(0),
         masterData(65 downto 2) => phyRxDataVec(0),
         masterValid             => phyRxValidVec(0),
         masterReady             => '1');

   U_Gearbox_640Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 4,
         MASTER_WIDTH_G => 66)
      port map (
         clk                     => clk160MHz,
         rst                     => reset160MHz,
         slip                    => slip,
         slaveData(0)            => serDesDataMask(0),
         slaveData(1)            => serDesDataMask(2),
         slaveData(2)            => serDesDataMask(4),
         slaveData(3)            => serDesDataMask(6),
         slaveValid              => '1',
         masterData(1 downto 0)  => phyRxHeaderVec(1),
         masterData(65 downto 2) => phyRxDataVec(1),
         masterValid             => phyRxValidVec(1),
         masterReady             => '1');

   U_Gearbox_320Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 2,
         MASTER_WIDTH_G => 66)
      port map (
         clk                     => clk160MHz,
         rst                     => reset160MHz,
         slip                    => slip,
         slaveData(0)            => serDesDataMask(0),
         slaveData(1)            => serDesDataMask(4),
         slaveValid              => '1',
         masterData(1 downto 0)  => phyRxHeaderVec(2),
         masterData(65 downto 2) => phyRxDataVec(2),
         masterValid             => phyRxValidVec(2),
         masterReady             => '1');

   U_Gearbox_160Mbps : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 1,
         MASTER_WIDTH_G => 66)
      port map (
         clk                     => clk160MHz,
         rst                     => reset160MHz,
         slip                    => slip,
         slaveData(0)            => serDesDataMask(0),
         slaveValid              => '1',
         masterData(1 downto 0)  => phyRxHeaderVec(3),
         masterData(65 downto 2) => phyRxDataVec(3),
         masterValid             => phyRxValidVec(3),
         masterReady             => '1');

   ------------------------------------------------------------
   -- "RD53.SEL_SER_CLK[2:0]" and "selectRate" must be the same
   ------------------------------------------------------------
   process(clk160MHz)
   begin
      if rising_edge(clk160MHz) then
         phyRxValid <= '0' after TPD_G;
         if (selectRate = "00") and (phyRxValidVec(0) = '1') then
            phyRxValid  <= '1'               after TPD_G;
            phyRxHeader <= phyRxHeaderVec(0) after TPD_G;
            phyRxData   <= phyRxDataVec(0)   after TPD_G;
         elsif (selectRate = "01") and (phyRxValidVec(1) = '1') then
            phyRxValid  <= '1'               after TPD_G;
            phyRxHeader <= phyRxHeaderVec(1) after TPD_G;
            phyRxData   <= phyRxDataVec(1)   after TPD_G;
         elsif (selectRate = "10") and (phyRxValidVec(2) = '1') then
            phyRxValid  <= '1'               after TPD_G;
            phyRxHeader <= phyRxHeaderVec(2) after TPD_G;
            phyRxData   <= phyRxDataVec(2)   after TPD_G;
         elsif (selectRate = "11") and (phyRxValidVec(3) = '1') then
            phyRxValid  <= '1'               after TPD_G;
            phyRxHeader <= phyRxHeaderVec(3) after TPD_G;
            phyRxData   <= phyRxDataVec(3)   after TPD_G;
         end if;
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
         clk            => clk160MHz,
         rst            => reset160MHz,
         rxHeader       => phyRxHeader,
         rxHeaderValid  => phyRxValid,
         hdrErrDet      => hdrErrDet,
         bitSlip        => slip,
         dlyLoad        => dlyLoad,
         dlyCfg         => dlyCfg,
         enUsrDlyCfg    => enUsrDlyCfg,
         usrDlyCfg      => usrDlyCfg,
         bypFirstBerDet => selectRate(1),
         eyescanCfg     => eyescanCfg,
         lockingCntCfg  => lockingCntCfg,
         locked         => gearboxAligned);

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
         outputValid    => rxValidOut,
         outputData     => data,
         outputSideband => header);

   rxValid  <= rxValidOut;
   rxData   <= bitReverse(data);
   rxHeader <= bitReverse(header);

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
