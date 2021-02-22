-------------------------------------------------------------------------------
-- File       : AtlasRd53TxCmdWrapper.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper for AtlasRd53TxCmd
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
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library atlas_rd53_fw_lib;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53TxCmdWrapper is
   generic (
      TPD_G         : time   := 1 ns;
      AXIS_CONFIG_G : AxiStreamConfigType;
      XIL_DEVICE_G  : string := "NONE";
      SYNTH_MODE_G  : string := "inferred";
      MEMORY_TYPE_G : string := "block");
   port (
      -- Streaming EMU Trig Interface (clk160MHz domain)
      emuTimingMaster : in  AxiStreamMasterType;
      emuTimingSlave  : out AxiStreamSlaveType;
      -- Streaming Config Interface (axisClk domain)
      axisClk         : in  sl;
      axisRst         : in  sl;
      -- Streaming RD53 Config/Trig Interface (clk160MHz domain)
      sConfigMaster   : in  AxiStreamMasterType;
      sConfigSlave    : out AxiStreamSlaveType;
      -- Timing Interface
      clkEn160MHz     : in  sl              := '1';
      clk160MHz       : in  sl;
      rst160MHz       : in  sl;
      -- Command Serial Interface (clk160MHz domain)
      dlyCmd          : in  sl              := '0';
      invCmd          : in  sl              := '0';
      cmdMode         : in  slv(1 downto 0) := "00";
      cmdOut          : out sl;
      cmdBusy         : out sl;
      cmdOutP         : out sl;
      cmdOutN         : out sl);
end entity AtlasRd53TxCmdWrapper;

architecture rtl of AtlasRd53TxCmdWrapper is

   signal cmdMaster : AxiStreamMasterType;
   signal cmdSlave  : AxiStreamSlaveType;

   signal muxMaster : AxiStreamMasterType;
   signal muxSlave  : AxiStreamSlaveType;

   signal configMaster : AxiStreamMasterType;
   signal configSlave  : AxiStreamSlaveType;

   signal slave : AxiStreamSlaveType;

   signal fifoWrCnt : slv(8 downto 0);

   signal rdyL : sl;

   signal cmd        : sl;
   signal cmdMask    : sl;
   signal cmdMaskDly : sl;

   signal D1        : sl;
   signal D2        : sl;
   signal cmdOutReg : sl;

begin

   cmdOut <= cmd;

   --------------------------------------------------------------
   -- Prevent back pressuring the DMA if the 160 MHz is not ready
   --------------------------------------------------------------
   sConfigSlave <= slave when (rdyL = '0') else AXI_STREAM_SLAVE_FORCE_C;
   U_rdyL : entity surf.Synchronizer
      generic map (
         TPD_G => TPD_G)
      port map (
         clk     => axisClk,
         dataIn  => rst160MHz,
         dataOut => rdyL);

   -----------------------
   -- Outbound Config FIFO
   -----------------------
   U_ConfigFifo : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 1,
         -- FIFO configurations
         SYNTH_MODE_G        => SYNTH_MODE_G,
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => false,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => AXIS_CONFIG_G,
         MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         -- Slave Port
         sAxisClk    => axisClk,
         sAxisRst    => axisRst,
         sAxisMaster => sConfigMaster,
         sAxisSlave  => slave,
         -- Master Port
         mAxisClk    => clk160MHz,
         mAxisRst    => rst160MHz,
         mAxisMaster => configMaster,
         mAxisSlave  => configSlave);

   U_Mux : entity surf.AxiStreamMux
      generic map (
         TPD_G         => TPD_G,
         NUM_SLAVES_G  => 2,
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk         => clk160MHz,
         axisRst         => rst160MHz,
         -- Slaves
         sAxisMasters(0) => configMaster,
         sAxisMasters(1) => emuTimingMaster,
         sAxisSlaves(0)  => configSlave,
         sAxisSlaves(1)  => emuTimingSlave,
         -- Master
         mAxisMaster     => muxMaster,
         mAxisSlave      => muxSlave);

   U_FW_CACH : entity surf.AxiStreamFifoV2
      generic map (
         -- General Configurations
         TPD_G               => TPD_G,
         INT_PIPE_STAGES_G   => 0,
         PIPE_STAGES_G       => 0,
         SLAVE_READY_EN_G    => true,
         VALID_THOLD_G       => 500,    -- less than 2**FIFO_ADDR_WIDTH_G
         VALID_BURST_MODE_G  => true,   -- bursting mode enabled
         -- FIFO configurations
         SYNTH_MODE_G        => SYNTH_MODE_G,
         MEMORY_TYPE_G       => "block",
         GEN_SYNC_FIFO_G     => true,
         FIFO_ADDR_WIDTH_G   => 9,
         -- AXI Stream Port Configurations
         SLAVE_AXI_CONFIG_G  => ssiAxiStreamConfig(4),
         MASTER_AXI_CONFIG_G => ssiAxiStreamConfig(4))
      port map (
         -- Slave Port
         sAxisClk    => clk160MHz,
         sAxisRst    => rst160MHz,
         sAxisMaster => muxMaster,
         sAxisSlave  => muxSlave,
         fifoWrCnt   => fifoWrCnt,
         -- Master Port
         mAxisClk    => clk160MHz,
         mAxisRst    => rst160MHz,
         mAxisMaster => cmdMaster,
         mAxisSlave  => cmdSlave);

   cmdBusy <= '0' when (fifoWrCnt = 0) else '1';

   U_Cmd : entity atlas_rd53_fw_lib.AtlasRd53TxCmd
      generic map (
         TPD_G => TPD_G)
      port map (
         cmdMode     => cmdMode,
         -- Clock and Reset
         clkEn160MHz => clkEn160MHz,
         clk160MHz   => clk160MHz,
         rst160MHz   => rst160MHz,
         -- Streaming RD53 Config Interface (clk160MHz domain)
         cmdMaster   => cmdMaster,
         cmdSlave    => cmdSlave,
         -- Serial Output Interface
         cmdOut      => cmd);

   ----------------------------------
   -- Set the command polarity output
   ----------------------------------
   cmdMask <= cmd xor invCmd;

   --------------------------
   -- Generate a delayed copy
   --------------------------
   process(clk160MHz)
   begin
      if rising_edge(clk160MHz) then
         cmdMaskDly <= cmdMask after TPD_G;
      end if;
   end process;

   -------------------------------------------------------------------------------------
   -- Add the ability to deskew the CMD with respect to the external re-timing flip-flop
   -------------------------------------------------------------------------------------
   D1 <= cmdMask when (dlyCmd = '0') else cmdMaskDly;
   D2 <= cmdMask;

   -----------------------------
   -- Output DDR Register Module
   -----------------------------
   GEN_7SERIES : if (XIL_DEVICE_G = "7SERIES") generate
      U_OutputReg : ODDR
         generic map (
            DDR_CLK_EDGE => "SAME_EDGE")
         port map (
            C  => clk160MHz,
            Q  => cmdOutReg,
            CE => '1',
            D1 => D1,
            D2 => D2,
            R  => '0',
            S  => '0');
   end generate;

   GEN_ULTRASCALE : if (XIL_DEVICE_G = "ULTRASCALE") or (XIL_DEVICE_G = "ULTRASCALE_PLUS") generate
      U_OutputReg : ODDRE1
         generic map (
            SIM_DEVICE => XIL_DEVICE_G)
         port map (
            C  => clk160MHz,
            Q  => cmdOutReg,
            D1 => D1,
            D2 => D2,
            SR => '0');
   end generate;

   GEN_OBUFDS : if (XIL_DEVICE_G /= "NONE") generate
      U_OBUFDS : OBUFDS
         port map (
            I  => cmdOutReg,
            O  => cmdOutP,
            OB => cmdOutN);
   end generate;

end rtl;
