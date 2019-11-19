-------------------------------------------------------------------------------
-- File       : AuroraRxChannel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AuroraRxLaneDeser (Modeled after XAPP1315's rx_sipo_1to7.v)
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

library surf;
use surf.StdRtlPkg.all;

library atlas_rd53_fw_lib;

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
      dlyLoad       : in  sl;
      dlyCfg        : in  slv(8 downto 0);
      -- Output
      dataOut       : out slv(7 downto 0));
end AuroraRxLaneDeser;

architecture mapping of AuroraRxLaneDeser is

   signal dPortData  : sl;
   signal dataDly    : sl;
   signal clk640MHzL : sl;

   attribute IODELAY_GROUP            : string;
   attribute IODELAY_GROUP of U_DELAY : label is IODELAY_GROUP_G;

begin

   U_IBUFDS : IBUFDS
      port map (
         I  => dPortDataP,
         IB => dPortDataN,
         O  => dPortData);

   U_DELAY : IDELAYE3
      generic map (
         DELAY_FORMAT     => "COUNT",
         SIM_DEVICE       => XIL_DEVICE_G,
         DELAY_VALUE      => 0,
         REFCLK_FREQUENCY => REF_FREQ_G,
         UPDATE_MODE      => "ASYNC",
         CASCADE          => "NONE",
         DELAY_SRC        => "IDATAIN",
         DELAY_TYPE       => "VAR_LOAD")
      port map(
         DATAIN      => '0',
         IDATAIN     => dPortData,
         DATAOUT     => dataDly,
         CLK         => clk160MHz,
         RST         => rst160MHz,
         CE          => '0',
         INC         => '0',
         LOAD        => dlyLoad,
         EN_VTC      => '0',
         CASC_IN     => '0',
         CASC_RETURN => '0',
         CNTVALUEIN  => dlyCfg);

   U_ISERDES : ISERDESE3
      generic map (
         DATA_WIDTH     => 8,
         FIFO_ENABLE    => "FALSE",
         FIFO_SYNC_MODE => "FALSE",
         SIM_DEVICE     => XIL_DEVICE_G)
      port map (
         D           => dataDly,
         Q           => dataOut,
         CLK         => clk640MHz,
         CLK_B       => clk640MHzL,
         CLKDIV      => clk160MHz,
         RST         => rst160MHz,
         FIFO_RD_CLK => '0',
         FIFO_RD_EN  => '0',
         FIFO_EMPTY  => open);

   clk640MHzL <= not(clk640MHz);

end mapping;
