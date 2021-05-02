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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library atlas_rd53_fw_lib;

entity AtlasRd53Core is
   generic (
      TPD_G         : time                  := 1 ns;
      AXIS_CONFIG_G : AxiStreamConfigType;
      VALID_THOLD_G : positive              := 128;  -- Hold until enough to burst into the interleaving MUX
      SIMULATION_G  : boolean               := false;
      EN_RX_G       : boolean               := true;
      RX_MAPPING_G  : Slv2Array(3 downto 0) := (0 => "00", 1 => "01", 2 => "10", 3 => "11");  -- Set the default RX PHY lane mapping
      XIL_DEVICE_G  : string                := "7SERIES";
      SYNTH_MODE_G  : string                := "xpm");
   port (
      -- CMD busy Flags
      cmdBusyOut      : out sl;
      cmdBusyAll      : in  sl;
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
      sConfigMaster   : in  AxiStreamMasterType;
      sConfigSlave    : out AxiStreamSlaveType;
      mConfigMaster   : out AxiStreamMasterType   := AXI_STREAM_MASTER_INIT_C;
      mConfigSlave    : in  AxiStreamSlaveType;
      mDataMaster     : out AxiStreamMasterType   := AXI_STREAM_MASTER_INIT_C;
      mDataSlave      : in  AxiStreamSlaveType;
      -- Timing/Trigger Interface
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      -- Deserialization Interface
      serDesData      : in  Slv8Array(3 downto 0);
      dlyLoad         : out slv(3 downto 0)       := (others => '0');
      dlyCfg          : out Slv9Array(3 downto 0) := (others => (others => '0'));
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

   signal dataMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal dataCtrl   : AxiStreamCtrlType   := AXI_STREAM_CTRL_UNUSED_C;

   signal configMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal configCtrl   : AxiStreamCtrlType   := AXI_STREAM_CTRL_UNUSED_C;

   signal txDataMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal txDataSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal batcherMaster : AxiStreamMasterType := AXI_STREAM_MASTER_INIT_C;
   signal batcherSlave  : AxiStreamSlaveType  := AXI_STREAM_SLAVE_FORCE_C;

   signal autoReadReg  : Slv32Array(3 downto 0) := (others => (others => '0'));
   signal enable       : slv(3 downto 0)        := (others => '0');
   signal linkUp       : slv(3 downto 0)        := (others => '0');
   signal hdrErrDet    : slv(3 downto 0)        := (others => '0');
   signal bitSlip      : slv(3 downto 0)        := (others => '0');
   signal selectRate   : slv(1 downto 0)        := (others => '0');
   signal rxPhyXbar    : Slv2Array(3 downto 0)  := (others => (others => '0'));
   signal chBond       : sl                     := '0';
   signal debugStream  : sl                     := '0';
   signal invData      : slv(3 downto 0)        := (others => '0');
   signal invCmd       : sl                     := '0';
   signal dlyCmd       : sl                     := '0';
   signal cmdMode      : slv(1 downto 0)        := (others => '0');
   signal NOP_C        : slv(15 downto 0)       := b"0110_1001_0110_1001";
   signal SYNC_C       : slv(15 downto 0)       := b"1000_0001_0111_1110";
   signal SYNC_freq    : slv(15 downto 0)       := b"0000_0000_0010_0000";
   signal GPulse_C     : slv(15 downto 0)       := b"0101_1100_0101_1100";
   signal GPulse_freq  : slv(15 downto 0)       := b"0000_0000_0000_0000";
   signal batchSize    : slv(15 downto 0)       := (others => '0');
   signal timerConfig  : slv(15 downto 0)       := (others => '0');
   signal wrdSent      : sl                     := '0';
   signal singleHdrDet : sl                     := '0';
   signal doubleHdrDet : sl                     := '0';
   signal singleHitDet : sl                     := '0';
   signal doubleHitDet : sl                     := '0';
   signal cmdBusy      : sl                     := '0';

   signal localRst    : sl := '1';
   signal localReset  : sl := '1';
   signal reset160MHz : sl := '1';

   signal dlyConfig     : Slv9Array(3 downto 0) := (others => (others => '0'));
   signal enUsrDlyCfg   : sl                    := '0';
   signal usrDlyCfg     : Slv9Array(3 downto 0) := (others => (others => '0'));
   signal eyescanCfg    : Slv8Array(3 downto 0) := (others => (others => '0'));
   signal lockingCntCfg : slv(23 downto 0)      := (others => '0');

begin

   cmdBusyOut <= cmdBusy;
   dlyCfg     <= dlyConfig;

   localReset <= localRst or rst160MHz;

   U_Rst : entity surf.RstPipeline
      generic map (
         TPD_G => TPD_G)
      port map (
         clk    => clk160MHz,
         rstIn  => localReset,
         rstOut => reset160MHz);

   -------------------------
   -- Control/Monitor Module
   -------------------------
   U_Ctrl : entity atlas_rd53_fw_lib.AtlasRd53Ctrl
      generic map (
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G,
         EN_RX_G      => EN_RX_G,
         RX_MAPPING_G => RX_MAPPING_G)
      port map (
         -- Monitoring Interface (clk160MHz domain)
         clk160MHz       => clk160MHz,
         rst160MHz       => reset160MHz,
         autoReadReg     => autoReadReg,
         dataDrop        => dataCtrl.overflow,
         configDrop      => configCtrl.overflow,
         chBond          => chBond,
         wrdSent         => wrdSent,
         singleHdrDet    => singleHdrDet,
         doubleHdrDet    => doubleHdrDet,
         singleHitDet    => singleHitDet,
         doubleHitDet    => doubleHitDet,
         dlyCfg          => dlyConfig,
         hdrErrDet       => hdrErrDet,
         bitSlip         => bitSlip,
         linkUp          => linkUp,
         cmdBusy         => cmdBusy,
         cmdBusyAll      => cmdBusyAll,
         downlinkReady   => '0',
         uplinkReady     => '0',
         enable          => enable,
         selectRate      => selectRate,
         invData         => invData,
         invCmd          => invCmd,
         cmdMode         => cmdMode,
         -- CMD value
         NOP_C           => NOP_C,
         SYNC_C          => SYNC_C,
         SYNC_freq       => SYNC_freq,
         GPulse_C        => GPulse_C,
         GPulse_freq     => GPulse_freq,
         dlyCmd          => dlyCmd,
         rxPhyXbar       => rxPhyXbar,
         debugStream     => debugStream,
         enUsrDlyCfg     => enUsrDlyCfg,
         usrDlyCfg       => usrDlyCfg,
         eyescanCfg      => eyescanCfg,
         lockingCntCfg   => lockingCntCfg,
         pllRst          => pllRst,
         localRst        => localRst,
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
   U_Cmd : entity atlas_rd53_fw_lib.AtlasRd53TxCmdWrapper
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
         rst160MHz       => reset160MHz,
         -- Command Serial Interface (clk160MHz domain)
         cmdBusy         => cmdBusy,
         invCmd          => invCmd,
         cmdMode         => cmdMode,
         -- CMD value
         NOP_C           => NOP_C,
         SYNC_C          => SYNC_C,
         SYNC_freq       => SYNC_freq,
         GPulse_C        => GPulse_C,
         GPulse_freq     => GPulse_freq,
         dlyCmd          => dlyCmd,
         cmdOutP         => dPortCmdP,
         cmdOutN         => dPortCmdN);

   GEN_RX : if EN_RX_G generate

      ---------------
      -- RX PHY Layer
      ---------------
      U_RxPhyLayer : entity atlas_rd53_fw_lib.AuroraRxChannel
         generic map (
            TPD_G         => TPD_G,
            AXIS_CONFIG_G => INT_AXIS_CONFIG_C,
            SIMULATION_G  => SIMULATION_G,
            SYNTH_MODE_G  => SYNTH_MODE_G)
         port map (
            -- Deserialization Interface
            serDesData    => serDesData,
            dlyLoad       => dlyLoad,
            dlyCfg        => dlyConfig,
            enUsrDlyCfg   => enUsrDlyCfg,
            usrDlyCfg     => usrDlyCfg,
            eyescanCfg    => eyescanCfg,
            lockingCntCfg => lockingCntCfg,
            bitSlip       => bitSlip,
            hdrErrDet     => hdrErrDet,
            -- Timing Interface
            clk160MHz     => clk160MHz,
            rst160MHz     => reset160MHz,
            -- Status/Control Interface
            enable        => enable,
            selectRate    => selectRate,
            invData       => invData,
            linkUp        => linkUp,
            chBond        => chBond,
            wrdSent       => wrdSent,
            singleHdrDet  => singleHdrDet,
            doubleHdrDet  => doubleHdrDet,
            singleHitDet  => singleHitDet,
            doubleHitDet  => doubleHitDet,
            rxPhyXbar     => rxPhyXbar,
            debugStream   => debugStream,
            -- AutoReg and Read back Interface
            dataMaster    => dataMaster,
            configMaster  => configMaster,
            autoReadReg   => autoReadReg);

      -----------------------
      -- Outbound Config FIFO
      -----------------------
      U_ConfigFifo : entity surf.AxiStreamFifoV2
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
            sAxisRst    => reset160MHz,
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
      U_DataFifo : entity surf.AxiStreamFifoV2
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
            sAxisRst    => reset160MHz,
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
      U_DataBatcher : entity atlas_rd53_fw_lib.AtlasRd53RxDataBatcher
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
      Burst_FIFO : entity surf.AxiStreamFifoV2
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

   end generate;

end mapping;
