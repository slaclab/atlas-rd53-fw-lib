-------------------------------------------------------------------------------
-- File       : AtlasRd53EmuTiming.vhd
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

entity AtlasRd53EmuTiming is
   generic (
      TPD_G           : time             := 1 ns;
      NUM_AXIS_G      : positive         := 1;
      ADDR_WIDTH_G    : positive         := 10;
      SYNTH_MODE_G    : string           := "inferred";
      MEMORY_TYPE_G   : string           := "block";
      AXI_BASE_ADDR_G : slv(31 downto 0) := (others => '0'));
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMaster   : in  AxiLiteReadMasterType;
      axilReadSlave    : out AxiLiteReadSlaveType;
      axilWriteMaster  : in  AxiLiteWriteMasterType;
      axilWriteSlave   : out AxiLiteWriteSlaveType;
      -- Streaming RD53 Trig Interface (clk160MHz domain)
      clk160MHz        : in  sl;
      rst160MHz        : in  sl;
      emuTimingMasters : out AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
      emuTimingSlaves  : in  AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0));
end AtlasRd53EmuTiming;

architecture mapping of AtlasRd53EmuTiming is

   constant NUM_AXIL_MASTERS_C : natural := 2;

   constant LUT_INDEX_C : natural := 0;
   constant FSM_INDEX_C : natural := 1;

   constant XBAR_CONFIG_C : AxiLiteCrossbarMasterConfigArray(NUM_AXIL_MASTERS_C-1 downto 0) := (
      LUT_INDEX_C     => (
         baseAddr     => AXI_BASE_ADDR_G+ x"0000_0000",
         addrBits     => 16,
         connectivity => x"FFFF"),
      FSM_INDEX_C     => (
         baseAddr     => AXI_BASE_ADDR_G + x"0002_0000",
         addrBits     => 16,
         connectivity => x"FFFF"));

   signal regWriteMaster : AxiLiteWriteMasterType;
   signal regWriteSlave  : AxiLiteWriteSlaveType;
   signal regReadMaster  : AxiLiteReadMasterType;
   signal regReadSlave   : AxiLiteReadSlaveType;

   signal axilWriteMasters : AxiLiteWriteMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilWriteSlaves  : AxiLiteWriteSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadMasters  : AxiLiteReadMasterArray(NUM_AXIL_MASTERS_C-1 downto 0);
   signal axilReadSlaves   : AxiLiteReadSlaveArray(NUM_AXIL_MASTERS_C-1 downto 0);

   signal ramAddr : slv(ADDR_WIDTH_G-1 downto 0);
   signal ramData : slv(31 downto 0);

   signal emuTimingMaster : AxiStreamMasterType;
   signal emuTimingSlave  : AxiStreamSlaveType;

begin


   ----------------------------------------
   -- Sync AXI-Lite to 160 MHz clock domain
   ----------------------------------------
   U_AxiLiteAsync : entity work.AxiLiteAsync
      generic map (
         TPD_G => TPD_G)
      port map (
         -- Slave Port
         sAxiClk         => axilClk,
         sAxiClkRst      => axilRst,
         sAxiReadMaster  => axilReadMaster,
         sAxiReadSlave   => axilReadSlave,
         sAxiWriteMaster => axilWriteMaster,
         sAxiWriteSlave  => axilWriteSlave,
         -- Master Port
         mAxiClk         => clk160MHz,
         mAxiClkRst      => rst160MHz,
         mAxiReadMaster  => regReadMaster,
         mAxiReadSlave   => regReadSlave,
         mAxiWriteMaster => regWriteMaster,
         mAxiWriteSlave  => regWriteSlave);

   --------------------------
   -- AXI-Lite: Crossbar Core
   --------------------------  
   U_XBAR : entity work.AxiLiteCrossbar
      generic map (
         TPD_G              => TPD_G,
         NUM_SLAVE_SLOTS_G  => 1,
         NUM_MASTER_SLOTS_G => NUM_AXIL_MASTERS_C,
         MASTERS_CONFIG_G   => XBAR_CONFIG_C)
      port map (
         axiClk              => clk160MHz,
         axiClkRst           => rst160MHz,
         sAxiWriteMasters(0) => regWriteMaster,
         sAxiWriteSlaves(0)  => regWriteSlave,
         sAxiReadMasters(0)  => regReadMaster,
         sAxiReadSlaves(0)   => regReadSlave,
         mAxiWriteMasters    => axilWriteMasters,
         mAxiWriteSlaves     => axilWriteSlaves,
         mAxiReadMasters     => axilReadMasters,
         mAxiReadSlaves      => axilReadSlaves);

   ---------------------------------------------       
   -- AXI-Lite: BRAM trigger bit Pattern storage
   ---------------------------------------------       
   U_LUT : entity work.AxiDualPortRam
      generic map (
         TPD_G            => TPD_G,
         SYNTH_MODE_G     => SYNTH_MODE_G,
         MEMORY_TYPE_G    => MEMORY_TYPE_G,
         AXI_WR_EN_G      => true,
         SYS_WR_EN_G      => false,
         SYS_BYTE_WR_EN_G => false,
         COMMON_CLK_G     => true,
         ADDR_WIDTH_G     => ADDR_WIDTH_G,
         DATA_WIDTH_G     => 32)
      port map (
         -- Axi Port
         axiClk         => clk160MHz,
         axiRst         => rst160MHz,
         axiReadMaster  => axilReadMasters(LUT_INDEX_C),
         axiReadSlave   => axilReadSlaves(LUT_INDEX_C),
         axiWriteMaster => axilWriteMasters(LUT_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(LUT_INDEX_C),
         -- Standard Port
         clk            => clk160MHz,
         addr           => ramAddr,
         dout           => ramData);

   --------------------------------
   -- FSM for reading out the BRAMs
   --------------------------------
   U_FSM : entity work.AtlasRd53EmuTimingFsm
      generic map (
         TPD_G        => TPD_G,
         ADDR_WIDTH_G => ADDR_WIDTH_G)
      port map (
         -- Clock and reset
         clk             => clk160MHz,
         rst             => rst160MHz,
         -- AXI-Lite Interface
         axilReadMaster  => axilReadMasters(FSM_INDEX_C),
         axilReadSlave   => axilReadSlaves(FSM_INDEX_C),
         axilWriteMaster => axilWriteMasters(FSM_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(FSM_INDEX_C),
         -- RAM Interface
         ramAddr         => ramAddr,
         ramData         => ramData,
         -- Streaming RD53 Trig Interface (clk160MHz domain)
         trigMaster      => emuTimingMaster,
         trigSlave       => emuTimingSlave);

   ---------------------------------------------------         
   -- Repeat the AXI stream to all RD53 CMD interfaces
   ---------------------------------------------------         
   U_Repeater : entity work.AxiStreamRepeater
      generic map(
         TPD_G                => TPD_G,
         NUM_MASTERS_G        => NUM_AXIS_G,
         INPUT_PIPE_STAGES_G  => 0,
         OUTPUT_PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => clk160MHz,
         axisRst      => rst160MHz,
         -- Slave
         sAxisMaster  => emuTimingMaster,
         sAxisSlave   => emuTimingSlave,
         -- Masters
         mAxisMasters => emuTimingMasters,
         mAxisSlaves  => emuTimingSlaves);

end mapping;
