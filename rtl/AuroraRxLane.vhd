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
      TPD_G : time := 1 ns;
      XIL_DEVICE_G : string  := "7SERIES");
   port (
      -- RD53 ASIC Serial Interface
      dPortDataP    : in  sl;
      dPortDataN    : in  sl;
      polarity      : in  sl;
      iDelayCtrlRdy : in  sl;
      -- Timing Interface
      clk640MHz     : in  sl;
      clk160MHz     : in  sl;
      rst160MHz     : in  sl;
      -- Output
      rxLinkUp      : out sl;
      rxValid       : out sl;
      rxHeader      : out slv(1 downto 0);
      rxData        : out slv(63 downto 0));
end AuroraRxLane;

architecture mapping of AuroraRxLane is

   constant SCRAMBLER_TAPS_C : IntegerArray := (0 => 39, 1 => 58);

   signal serDeslock     : sl;
   signal serDesData     : slv(7 downto 0);
   signal serDesDataMask : slv(7 downto 0);

   signal phyRxValid  : sl;
   signal phyRxHeader : slv(1 downto 0);
   signal phyRxData   : slv(63 downto 0);

   signal bitslip          : sl;
   signal unscramblerValid : sl;
   signal gearboxAligned   : sl;

   signal reset           : sl;
   signal misalignedEvent : sl;

begin

   ------------------
   -- XAPP1017 Module
   ------------------
   U_SerDes : entity work.serdes_1_to_468_idelay_ddr
      generic map (
         XIL_DEVICE_G          => XIL_DEVICE_G,
         S                     => 8,
         D                     => 1,
         REF_FREQ              => 300.0,
         HIGH_PERFORMANCE_MODE => "TRUE",
         DATA_FORMAT           => "PER_CLOCK")
      port map (
         datain_p(0)           => dPortDataP,
         datain_n(0)           => dPortDataN,
         reset                 => rst160MHz,
         idelay_rdy            => iDelayCtrlRdy,
         rxclk                 => clk640MHz,
         system_clk            => clk160MHz,
         bit_rate_value        => x"1280",  -- TODO make generic
         rx_lckd               => serDeslock,
         rx_data(0)            => serDesData(7),
         rx_data(1)            => serDesData(6),
         rx_data(2)            => serDesData(5),
         rx_data(3)            => serDesData(4),
         rx_data(4)            => serDesData(3),
         rx_data(5)            => serDesData(2),
         rx_data(6)            => serDesData(1),
         rx_data(7)            => serDesData(0));

   ----------------------------
   -- Support inverted polarity
   ----------------------------
   serDesDataMask <= serDesData when (polarity = '0') else not(serDesData);

   -----------------
   -- Gearbox Module
   -----------------
   U_Gearbox : entity work.Gearbox
      generic map (
         TPD_G          => TPD_G,
         SLAVE_WIDTH_G  => 8,
         MASTER_WIDTH_G => 66)
      port map (
         clk                      => clk160MHz,
         rst                      => rst160MHz,
         slip                     => bitslip,
         slaveData                => serDesDataMask,
         slaveValid               => serDeslock,
         masterData(63 downto 0)  => phyRxData,
         masterData(65 downto 64) => phyRxHeader,
         masterValid              => phyRxValid,
         masterReady              => '1');

   ------------------
   -- Gearbox aligner
   ------------------
   U_GearboxAligner : entity work.Pgp3RxGearboxAligner
      generic map (
         TPD_G       => TPD_G,
         SLIP_WAIT_G => 128)
      port map (
         clk           => clk160MHz,
         rst           => rst160MHz,
         rxHeader      => phyRxHeader,
         rxHeaderValid => phyRxValid,
         slip          => bitslip,
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
         outputData     => rxData,
         outputSideband => rxHeader);

   rxLinkUp <= gearboxAligned;

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

   reset <= misalignedEvent or rst160MHz;

end mapping;
