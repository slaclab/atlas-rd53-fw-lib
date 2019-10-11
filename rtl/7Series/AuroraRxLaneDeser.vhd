-------------------------------------------------------------------------------
-- File       : AuroraRxChannel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AuroraRxLaneDeser
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

entity AuroraRxLaneDeser is
   generic (
      TPD_G           : time   := 1 ns;
      IODELAY_GROUP_G : string := "rd53_aurora";
      REF_FREQ_G      : real   := 300.0;  -- IDELAYCTRL's REFCLK (in units of Hz)
      XIL_DEVICE_G    : string := "7SERIES");
   port (
      -- RD53 ASIC Serial Interface
      dPortDataP    : in  sl;
      dPortDataN    : in  sl;
      iDelayCtrlRdy : in  sl;
      -- Timing Interface
      clk640MHz     : in  sl;
      clk160MHz     : in  sl;
      rst160MHz     : in  sl;
      -- Delay Configuration
      dlyLoad       : in  sl;
      dlyCfg        : in  slv(8 downto 0);
      -- Output
      dataOut       : out slv(7 downto 0));
end AuroraRxLaneDeser;

architecture mapping of AuroraRxLaneDeser is

   signal clk640MHzL : sl;
   signal dPortData  : sl;
   signal dataDly    : sl;

   attribute IODELAY_GROUP            : string;
   attribute IODELAY_GROUP of U_DELAY : label is IODELAY_GROUP_G;

begin

   U_IBUFDS : IBUFDS
      port map (
         I  => dPortDataP,
         IB => dPortDataN,
         O  => dPortData);

   U_DELAY : IDELAYE2
      generic map (
         REFCLK_FREQUENCY      => REF_FREQ_G,
         HIGH_PERFORMANCE_MODE => "TRUE",
         IDELAY_VALUE          => 0,
         DELAY_SRC             => "IDATAIN",
         IDELAY_TYPE           => "VAR_LOAD")
      port map(
         DATAIN     => '0',
         IDATAIN    => dPortData,
         DATAOUT    => dataDly,
         C          => clk160MHz,
         CE         => '0',
         INC        => '0',
         LD         => dlyLoad,
         LDPIPEEN   => '0',
         REGRST     => '0',
         CINVCTRL   => '0',
         CNTVALUEIN => dlyCfg(4 downto 0));

   U_ISERDES : ISERDESE2
      generic map (
         DATA_WIDTH     => 8,
         DATA_RATE      => "DDR",
         IOBDELAY       => "IFD",
         DYN_CLK_INV_EN => "FALSE",
         INTERFACE_TYPE => "NETWORKING")
      port map (
         D            => '0',
         DDLY         => dataDly,
         CE1          => '1',
         CE2          => '1',
         CLK          => clk640MHz,
         CLKB         => clk640MHzL,
         RST          => rst160MHz,
         CLKDIV       => clk160MHz,
         CLKDIVP      => '0',
         OCLK         => '0',
         OCLKB        => '0',
         DYNCLKSEL    => '0',
         DYNCLKDIVSEL => '0',
         SHIFTIN1     => '0',
         SHIFTIN2     => '0',
         BITSLIP      => '0',
         O            => open,
         Q8           => dataOut(0),
         Q7           => dataOut(1),
         Q6           => dataOut(2),
         Q5           => dataOut(3),
         Q4           => dataOut(4),
         Q3           => dataOut(5),
         Q2           => dataOut(6),
         Q1           => dataOut(7),
         OFB          => '0',
         SHIFTOUT1    => open,
         SHIFTOUT2    => open);

   clk640MHzL <= not(clk640MHz);

end mapping;
