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
      XIL_DEVICE_G    : string := "ULTRASCALE_PLUS");
   port (
      -- RD53 ASIC Serial Interface
      dPortDataP       : in  sl;
      dPortDataN       : in  sl;
      iDelayCtrlRdy    : in  sl;
      -- Timing Interface
      clk640MHz        : in  sl;
      clk160MHz        : in  sl;
      rst160MHz        : in  sl;
      -- Delay Configuration
      dlyCfgIn         : in  slv(4 downto 0);
      rxBitCtrlToSlice : in  slv(39 downto 0);
      txBitCtrlToSlice : in  slv(39 downto 0);
      rxBitSliceToCtrl : out slv(39 downto 0);
      txBitSliceToCtrl : out slv(39 downto 0);
      -- Output
      dataOut          : out slv(7 downto 0));
end AuroraRxLaneDeser;

architecture mapping of AuroraRxLaneDeser is

   signal dPortData : sl;
   signal dlyCfg    : slv(8 downto 0) := (others => '0');
   signal fifoEmpty : sl;
   signal fifoRdEn : sl;

   attribute IODELAY_GROUP            : string;
   attribute IODELAY_GROUP of U_DELAY : label is IODELAY_GROUP_G;

begin

   U_IBUFDS : IBUFDS
      port map (
         I  => dPortDataP,
         IB => dPortDataN,
         O  => dPortData);

   dlyCfg(8 downto 4) <= dlyCfgIn;

   U_DELAY : RX_BITSLICE
      generic map (
         CASCADE                 => "FALSE",
         -- DATA_TYPE               => "DATA",
         DATA_TYPE               => "SERIAL",
         DATA_WIDTH              => 8,
         DELAY_FORMAT            => "COUNT",
         DELAY_TYPE              => "VAR_LOAD",
         DELAY_VALUE             => 0,
         DELAY_VALUE_EXT         => 0,
         FIFO_SYNC_MODE          => "FALSE",
         IS_CLK_EXT_INVERTED     => '0',
         IS_CLK_INVERTED         => '0',
         IS_RST_DLY_EXT_INVERTED => '0',
         IS_RST_DLY_INVERTED     => '0',
         IS_RST_INVERTED         => '0',
         REFCLK_FREQUENCY        => REF_FREQ_G,
         SIM_DEVICE              => XIL_DEVICE_G,
         UPDATE_MODE             => "ASYNC",
         UPDATE_MODE_EXT         => "ASYNC")
      port map (
         RX_BIT_CTRL_IN  => rxBitCtrlToSlice,
         TX_BIT_CTRL_IN  => txBitCtrlToSlice,
         RX_BIT_CTRL_OUT => rxBitSliceToCtrl,
         TX_BIT_CTRL_OUT => txBitSliceToCtrl,
         Q               => dataOut,
         CE              => '0',
         CE_EXT          => '0',
         CLK             => clk160MHz,
         CLK_EXT         => '0',
         CNTVALUEIN      => dlyCfg,
         CNTVALUEIN_EXT  => (others => '0'),
         DATAIN          => dPortData,
         EN_VTC          => '0',
         EN_VTC_EXT      => '0',
         FIFO_RD_CLK     => clk160MHz,
         FIFO_RD_EN      => fifoRdEn,
         FIFO_EMPTY      => fifoEmpty,
         INC             => '0',
         INC_EXT         => '0',
         LOAD            => '1',
         LOAD_EXT        => '0',
         RST             => rst160MHz,
         RST_DLY         => '0',
         RST_DLY_EXT     => '0');

   fifoRdEn <= not(fifoEmpty);      
         
end mapping;
