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
use work.SsiPkg.all;

entity AtlasRd53EmuTiming is
   generic (
      TPD_G         : time     := 1 ns;
      NUM_AXIS_G    : positive := 1;
      ADDR_WIDTH_G  : positive := 10;
      SYNTH_MODE_G  : string   := "inferred";
      MEMORY_TYPE_G : string   := "block");
   port (
      -- AXI-Lite Interface (axilClk domain)
      axilClk          : in  sl;
      axilRst          : in  sl;
      axilReadMasters  : in  AxiLiteReadMasterArray(1 downto 0);
      axilReadSlaves   : out AxiLiteReadSlaveArray(1 downto 0);
      axilWriteMasters : in  AxiLiteWriteMasterArray(1 downto 0);
      axilWriteSlaves  : out AxiLiteWriteSlaveArray(1 downto 0);
      -- Streaming RD53 Trig Interface (clk160MHz domain)
      clk160MHz        : in  slv(NUM_AXIS_G-1 downto 0);
      rst160MHz        : in  slv(NUM_AXIS_G-1 downto 0);
      emuTimingMasters : out AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
      emuTimingSlaves  : in  AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0));
end AtlasRd53EmuTiming;

architecture mapping of AtlasRd53EmuTiming is

   constant LUT_INDEX_C : natural := 0;
   constant FSM_INDEX_C : natural := 1;

   signal ramAddr : slv(ADDR_WIDTH_G-1 downto 0);
   signal ramData : slv(31 downto 0);

   signal emuTimingMaster : AxiStreamMasterType;
   signal emuTimingSlave  : AxiStreamSlaveType;

   signal txMasters : AxiStreamMasterArray(NUM_AXIS_G-1 downto 0);
   signal txSlaves  : AxiStreamSlaveArray(NUM_AXIS_G-1 downto 0);

begin

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
         COMMON_CLK_G     => false,
         ADDR_WIDTH_G     => ADDR_WIDTH_G,
         DATA_WIDTH_G     => 32)
      port map (
         -- Axi Port
         axiClk         => axilClk,
         axiRst         => axilRst,
         axiReadMaster  => axilReadMasters(LUT_INDEX_C),
         axiReadSlave   => axilReadSlaves(LUT_INDEX_C),
         axiWriteMaster => axilWriteMasters(LUT_INDEX_C),
         axiWriteSlave  => axilWriteSlaves(LUT_INDEX_C),
         -- Standard Port
         clk            => clk160MHz(0),
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
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMasters(FSM_INDEX_C),
         axilReadSlave   => axilReadSlaves(FSM_INDEX_C),
         axilWriteMaster => axilWriteMasters(FSM_INDEX_C),
         axilWriteSlave  => axilWriteSlaves(FSM_INDEX_C),
         -- RAM Interface (clk160MHz domain)
         clk160MHz       => clk160MHz(0),
         rst160MHz       => rst160MHz(0),
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
         axisClk      => clk160MHz(0),
         axisRst      => rst160MHz(0),
         -- Slave
         sAxisMaster  => emuTimingMaster,
         sAxisSlave   => emuTimingSlave,
         -- Masters
         mAxisMasters => txMasters,
         mAxisSlaves  => txSlaves);

   GEN_mDP :
   for i in NUM_AXIS_G-1 downto 0 generate
      ASYNC_FIFO : entity work.AxiStreamFifoV2
         generic map (
            -- General Configurations
            TPD_G               => TPD_G,
            PIPE_STAGES_G       => 0,
            SLAVE_READY_EN_G    => true,
            VALID_THOLD_G       => 1,
            -- FIFO configurations
            SYNTH_MODE_G        => SYNTH_MODE_G,
            MEMORY_TYPE_G       => "distributed",
            GEN_SYNC_FIFO_G     => ite(i = 0, true, false),
            CASCADE_SIZE_G      => 1,
            FIFO_ADDR_WIDTH_G   => 4,
            -- AXI Stream Port Configurations
            SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
            MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(4))
         port map (
            -- Slave Port
            sAxisClk    => clk160MHz(0),
            sAxisRst    => rst160MHz(0),
            sAxisMaster => txMasters(i),
            sAxisSlave  => txSlaves(i),
            -- Master Port
            mAxisClk    => clk160MHz(i),
            mAxisRst    => rst160MHz(i),
            mAxisMaster => emuTimingMasters(i),
            mAxisSlave  => emuTimingSlaves(i));
   end generate GEN_mDP;

end mapping;
