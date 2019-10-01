-------------------------------------------------------------------------------
-- File       : AtlasRd53Core.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: RX PHY Core module
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

entity AtlasRd53Core is
   generic (
      TPD_G         : time                  := 1 ns;
      AXIS_CONFIG_G : AxiStreamConfigType;
      VALID_THOLD_G : positive              := 128;  -- Hold until enough to burst into the interleaving MUX
      SIMULATION_G  : boolean               := false;
      RX_MAPPING_G  : Slv2Array(3 downto 0) := (0 => "00", 1 => "01", 2 => "10", 3 => "11");  -- Set the default RX PHY lane mapping 
      XIL_DEVICE_G  : string                := "7SERIES";
      SYNTH_MODE_G  : string                := "xpm");
   port (
      -- I/O Delay Interfaces
      pllRst          : out sl;
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType;
      -- Streaming Config/Trig Interface (clk160MHz domain)
      emuTimingMaster : in  AxiStreamMasterType;
      emuTimingSlave  : out AxiStreamSlaveType;
      -- Streaming Data Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      mDataMaster     : out AxiStreamMasterType;
      mDataSlave      : in  AxiStreamSlaveType;
      sConfigMaster   : in  AxiStreamMasterType;
      sConfigSlave    : out AxiStreamSlaveType;
      mConfigMaster   : out AxiStreamMasterType;
      mConfigSlave    : in  AxiStreamSlaveType;
      -- Timing/Trigger Interface
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      -- Deserialization Interface
      serDesData      : in  Slv8Array(3 downto 0);
      dlySlip         : out slv(3 downto 0);
      -- RD53 ASIC Serial Ports
      dPortCmdP       : out sl;
      dPortCmdN       : out sl);
end AtlasRd53Core;

architecture mapping of AtlasRd53Core is

   constant INT_AXIS_CONFIG_C : AxiStreamConfigType :=
      ssiAxiStreamConfig(
         dataBytes => 8,                -- 64-bit width
         tKeepMode => TKEEP_COMP_C,
         tUserMode => TUSER_FIRST_LAST_C,
         tDestBits => 0,
         tUserBits => 2);

   signal dataMaster : AxiStreamMasterType;
   signal dataCtrl   : AxiStreamCtrlType;

   signal configMaster : AxiStreamMasterType;
   signal configCtrl   : AxiStreamCtrlType;

   signal txDataMaster : AxiStreamMasterType;
   signal txDataSlave  : AxiStreamSlaveType;

   signal batcherMaster : AxiStreamMasterType;
   signal batcherSlave  : AxiStreamSlaveType;

   signal autoReadReg : Slv32Array(3 downto 0);
   signal enable      : slv(3 downto 0);
   signal linkUp      : slv(3 downto 0);
   signal selectRate  : slv(1 downto 0);
   signal rxPhyXbar   : Slv2Array(3 downto 0);
   signal chBond      : sl;
   signal debugStream : sl;
   signal invData     : slv(3 downto 0);
   signal invCmd      : sl;
   signal dlyCmd      : sl;
   signal batchSize   : slv(15 downto 0);
   signal timerConfig : slv(15 downto 0);

begin

   -------------------------
   -- Control/Monitor Module
   -------------------------
   U_Ctrl : entity work.AtlasRd53Ctrl
      generic map (
         TPD_G        => TPD_G,
         RX_MAPPING_G => RX_MAPPING_G)
      port map (
         -- Monitoring Interface (clk160MHz domain)
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         autoReadReg     => autoReadReg,
         dataDrop        => dataCtrl.overflow,
         configDrop      => configCtrl.overflow,
         chBond          => chBond,
         linkUp          => linkUp,
         enable          => enable,
         selectRate      => selectRate,
         invData         => invData,
         invCmd          => invCmd,
         dlyCmd          => dlyCmd,
         rxPhyXbar       => rxPhyXbar,
         debugStream     => debugStream,
         pllRst          => pllRst,
         batchSize       => batchSize,
         timerConfig     => timerConfig,
         -- AXI-Lite Interface (axilClk domain)
         axilClk         => axilClk,
         axilRst         => axilRst,
         axilReadMaster  => axilReadMaster,
         axilReadSlave   => axilReadSlave,
         axilWriteMaster => axilWriteMaster,
         axilWriteSlave  => axilWriteSlave);

   ------------------------
   -- CMD Generation Module
   ------------------------
   U_Cmd : entity work.AtlasRd53TxCmdWrapper
      generic map (
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => AXIS_CONFIG_G,
         XIL_DEVICE_G  => XIL_DEVICE_G,
         SYNTH_MODE_G  => SYNTH_MODE_G)
      port map (
         -- Streaming EMU Trig Interface (clk160MHz domain)
         emuTimingMaster => emuTimingMaster,
         emuTimingSlave  => emuTimingSlave,
         -- Streaming Config Interface (axisClk domain)
         axisClk         => axisClk,
         axisRst         => axisRst,
         sConfigMaster   => sConfigMaster,
         sConfigSlave    => sConfigSlave,
         -- Timing Interface
         clk160MHz       => clk160MHz,
         rst160MHz       => rst160MHz,
         -- Command Serial Interface (clk160MHz domain)
         invCmd          => invCmd,
         dlyCmd          => dlyCmd,
         cmdOutP         => dPortCmdP,
         cmdOutN         => dPortCmdN);

   ---------------
   -- RX PHY Layer
   ---------------
   U_RxPhyLayer : entity work.AuroraRxChannel
      generic map (
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => INT_AXIS_CONFIG_C,
         SIMULATION_G  => SIMULATION_G,
         SYNTH_MODE_G  => SYNTH_MODE_G)
      port map (
         -- Deserialization Interface
         serDesData   => serDesData,
         dlySlip      => dlySlip,
         -- Timing Interface
         clk160MHz    => clk160MHz,
         rst160MHz    => rst160MHz,
         -- Status/Control Interface
         enable       => enable,
         selectRate   => selectRate,
         invData      => invData,
         linkUp       => linkUp,
         chBond       => chBond,
         rxPhyXbar    => rxPhyXbar,
         debugStream  => debugStream,
         -- AutoReg and Read back Interface
         dataMaster   => dataMaster,
         configMaster => configMaster,
         autoReadReg  => autoReadReg);

   -----------------------         
   -- Outbound Config FIFO
   -----------------------         
   U_ConfigFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         SYNTH_MODE_G        => SYNTH_MODE_G,
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => clk160MHz,
         sAxisRst    => rst160MHz,
         sAxisMaster => configMaster,
         sAxisCtrl   => configCtrl,
         -- Master Port
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => mConfigMaster,
         mAxisSlave  => mConfigSlave);

   ---------------------         
   -- Outbound Data FIFO
   ---------------------       
   U_DataFifo : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => false,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         SYNTH_MODE_G        => SYNTH_MODE_G,
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => INT_AXIS_CONFIG_C)
      port map (
         -- Slave Port
         sAxisClk    => clk160MHz,
         sAxisRst    => rst160MHz,
         sAxisMaster => dataMaster,
         sAxisCtrl   => dataCtrl,
         -- Master Port
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => txDataMaster,
         mAxisSlave  => txDataSlave);

   ---------------------------------------------------------
   -- Batch Multiple 64-bit data words into large AXIS frame
   ---------------------------------------------------------
   U_DataBatcher : entity work.AtlasRd53RxDataBatcher
      generic map (
         TPD_G         => TPD_G,
         AXIS_CONFIG_G => INT_AXIS_CONFIG_C)
      port map (
         -- Clock and Reset
         axisClk     => axisClk,
         axisRst     => axisRst,
         -- Configuration/Status Interface
         batchSize   => batchSize,
         timerConfig => timerConfig,
         -- AXI Streaming Interface
         sDataMaster => txDataMaster,
         sDataSlave  => txDataSlave,
         mDataMaster => batcherMaster,
         mDataSlave  => batcherSlave);

   --------------------
   -- Resize/Burst FIFO
   --------------------
   Burst_FIFO : entity work.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => VALID_THOLD_G,
         VALID_BURST_MODE_G  => true,
         -- FIFO configurations
         SYNTH_MODE_G        => "xpm",
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => log2(2*VALID_THOLD_G),
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => INT_AXIS_CONFIG_C,
         MASTER_AXI_CONFIG_G => AXIS_CONFIG_G)
      port map (
         -- Slave Port
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => batcherMaster,
         sAxisSlave  => batcherSlave,
         -- Master Port
         mAxisClk    => axisClk,
         mAxisRst    => axisRst,
         mAxisMaster => mDataMaster,
         mAxisSlave  => mDataSlave);

end mapping;
