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
      XIL_DEVICE_G    : string := "ULTRASCALE");
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
      dlyCfgIn      : in  slv(4 downto 0);
      -- Output
      dataOut       : out slv(7 downto 0));
end AuroraRxLaneDeser;

architecture mapping of AuroraRxLaneDeser is

   signal dPortData : sl;
   signal dlyCfg    : slv(8 downto 0) := (others => '0');
   signal dataDly   : sl;
   signal empty     : sl;
   signal rdEn      : sl;

   attribute IODELAY_GROUP            : string;
   attribute IODELAY_GROUP of U_DELAY : label is IODELAY_GROUP_G;

begin

   U_IBUFDS : IBUFDS
      port map (
         I  => dPortDataP,
         IB => dPortDataN,
         O  => dPortData);

   dlyCfg(8 downto 4) <= dlyCfgIn;

   U_DELAY : IDELAYE3
      generic map (
         DELAY_FORMAT     => "COUNT",
         SIM_DEVICE       => XIL_DEVICE_G,
         DELAY_VALUE      => 0,
         REFCLK_FREQUENCY => REF_FREQ_G,
         CASCADE          => "NONE",
         DELAY_SRC        => "IDATAIN",
         DELAY_TYPE       => "VAR_LOAD")
      port map(
         DATAIN      => '0',
         IDATAIN     => dPortData,
         DATAOUT     => dataDly,
         CLK         => clk160MHz,
         CE          => '0',
         RST         => '0',
         INC         => '0',
         LOAD        => '1',
         EN_VTC      => '0',
         CASC_IN     => '0',
         CASC_RETURN => '0',
         CNTVALUEIN  => dlyCfg);

   U_ISERDES : ISERDESE3
      generic map (
         DATA_WIDTH        => 8,
         FIFO_ENABLE       => "TRUE",
         FIFO_SYNC_MODE    => "FALSE",
         IS_CLK_B_INVERTED => '1',
         IS_CLK_INVERTED   => '0',
         IS_RST_INVERTED   => '0',
         SIM_DEVICE        => XIL_DEVICE_G)
      port map (
         D           => dataDly,
         Q           => dataOut,
         CLK         => clk640MHz,
         CLK_B       => clk640MHz,
         CLKDIV      => clk160MHz,
         RST         => rst160MHz,
         FIFO_RD_CLK => clk160MHz,
         FIFO_RD_EN  => rdEn,
         FIFO_EMPTY  => empty);

   rdEn <= not(empty);

end mapping;
