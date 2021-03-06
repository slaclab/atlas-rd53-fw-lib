-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: FMC mappipng
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
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcMapping is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      XIL_DEVICE_G : string  := "7SERIES");
   port (
      -- Deserialization Interface
      serDesData    : out   Slv8Array(15 downto 0);
      dlyLoad       : in    slv(15 downto 0);
      dlyCfg        : in    Slv9Array(15 downto 0);
      iDelayCtrlRdy : in    sl;
      -- Timing Clock/Reset Interface
      clk160MHz     : out   sl;
      rst160MHz     : out   sl;
      pllClkOut     : out   sl;
      -- PLL Interface
      fpgaPllClkIn  : in    sl;
      pllRst        : in    slv(3 downto 0);
      pllCsL        : in    sl;
      pllSck        : in    sl;
      pllSdi        : in    sl;
      pllSdo        : out   sl;
      -- mDP CMD Interface
      dPortCmdP     : in    slv(3 downto 0);
      dPortCmdN     : in    slv(3 downto 0);
      -- I2C Interface
      i2cScl        : inout sl;
      i2cSda        : inout sl;
      -- TLU Interface
      tluInt        : out   sl;
      tluRst        : out   sl;
      tluBsy        : in    sl := '1';
      tluTrgClk     : in    sl := '0';
      -- FMC LPC Ports
      fmcLaP        : inout slv(33 downto 0);
      fmcLaN        : inout slv(33 downto 0));
end AtlasRd53FmcMapping;

architecture mapping of AtlasRd53FmcMapping is

   signal pllReset   : sl;
   signal pllClk     : slv(1 downto 0);
   signal pllClkBufg : sl;

   signal dPortDataP : Slv4Array(3 downto 0);
   signal dPortDataN : Slv4Array(3 downto 0);

begin

   pllClkOut <= pllClkBufg;
   pllReset  <= uOr(pllRst);

   GEN_PLL_CLK :
   for i in 1 downto 0 generate
      U_IBUFDS : IBUFDS
         port map (
            I  => fmcLaP(i+0),
            IB => fmcLaN(i+0),
            O  => pllClk(i));
   end generate GEN_PLL_CLK;

   U_BUFG : BUFG
      port map (
         I => pllClk(0),
         O => pllClkBufg);

   U_Selectio : entity atlas_rd53_fw_lib.AtlasRd53HsSelectio
      generic map(
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         ref160Clk     => pllClkBufg,
         ref160Rst     => pllReset,
         -- Deserialization Interface
         serDesData    => serDesData,
         dlyLoad       => dlyLoad,
         dlyCfg        => dlyCfg,
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- mDP DATA Interface
         dPortDataP    => dPortDataP,
         dPortDataN    => dPortDataN,
         -- Timing Clock/Reset Interface
         clk160MHz     => clk160MHz,
         rst160MHz     => rst160MHz);

   U_fpgaPllClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         clkIn   => fpgaPllClkIn,
         clkOutP => fmcLaP(2),
         clkOutN => fmcLaN(2));

   fmcLaP(3) <= pllSck;
   fmcLaN(3) <= pllSdi;
   fmcLaP(4) <= pllCsL;
   pllSdo    <= fmcLaN(4);

   GEN_DP :
   for i in 3 downto 0 generate

      fmcLaP(5+i*5) <= dPortCmdP(i);
      fmcLaN(5+i*5) <= dPortCmdN(i);

      GEN_LANE :
      for j in 3 downto 0 generate
         dPortDataP(i)(j) <= fmcLaP(6+i*5+j);
         dPortDataN(i)(j) <= fmcLaN(6+i*5+j);
      end generate GEN_LANE;

   end generate GEN_DP;

   fmcLaP(25) <= i2cScl;
   fmcLaN(25) <= i2cSda;

   U_tluInt : IBUFDS
      port map (
         I  => fmcLaP(26),
         IB => fmcLaN(26),
         O  => tluInt);

   U_tluRst : IBUFDS
      port map (
         I  => fmcLaP(27),
         IB => fmcLaN(27),
         O  => tluRst);

   U_tluBsy : OBUFDS
      port map (
         I  => tluBsy,
         O  => fmcLaP(28),
         OB => fmcLaN(28));

   U_tluTrgClk : entity surf.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         clkIn   => tluTrgClk,
         clkOutP => fmcLaP(29),
         clkOutN => fmcLaN(29));

end mapping;
