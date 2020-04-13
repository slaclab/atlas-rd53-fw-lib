-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Wrapper on the AxiStreamDeMux that provides a method for a 
--              "global" command on TDEST = NUM_MASTERS_G
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

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;

entity CmdAxisDeMux is
   generic (
      TPD_G         : time     := 1 ns;
      NUM_MASTERS_G : positive := 1);
   port (
      -- Clock and reset
      axisClk      : in  sl;
      axisRst      : in  sl;
      -- Slave
      sAxisMaster  : in  AxiStreamMasterType;
      sAxisSlave   : out AxiStreamSlaveType;
      -- Masters
      mAxisMasters : out AxiStreamMasterArray(NUM_MASTERS_G-1 downto 0);
      mAxisSlaves  : in  AxiStreamSlaveArray(NUM_MASTERS_G-1 downto 0));
end CmdAxisDeMux;

architecture mapping of CmdAxisDeMux is

   signal axisMasters : AxiStreamMasterArray(NUM_MASTERS_G downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal axisSlaves  : AxiStreamSlaveArray(NUM_MASTERS_G downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

   signal repeatMasters : AxiStreamMasterArray(NUM_MASTERS_G-1 downto 0) := (others => AXI_STREAM_MASTER_INIT_C);
   signal repeatSlaves  : AxiStreamSlaveArray(NUM_MASTERS_G-1 downto 0)  := (others => AXI_STREAM_SLAVE_FORCE_C);

begin

   U_DeMux : entity surf.AxiStreamDeMux
      generic map (
         TPD_G         => TPD_G,
         NUM_MASTERS_G => (NUM_MASTERS_G+1),
         PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => axisClk,
         axisRst      => axisRst,
         -- Slave         
         sAxisMaster  => sAxisMaster,
         sAxisSlave   => sAxisSlave,
         -- Masters
         mAxisMasters => axisMasters,
         mAxisSlaves  => axisSlaves);

   U_Repeater : entity surf.AxiStreamRepeater
      generic map(
         TPD_G                => TPD_G,
         NUM_MASTERS_G        => NUM_MASTERS_G,
         INPUT_PIPE_STAGES_G  => 0,
         OUTPUT_PIPE_STAGES_G => 1)
      port map (
         -- Clock and reset
         axisClk      => axisClk,
         axisRst      => axisRst,
         -- Slave
         sAxisMaster  => axisMasters(NUM_MASTERS_G),
         sAxisSlave   => axisSlaves(NUM_MASTERS_G),
         -- Masters
         mAxisMasters => repeatMasters,
         mAxisSlaves  => repeatSlaves);

   GEN_VEC :
   for i in NUM_MASTERS_G-1 downto 0 generate
      U_Mux : entity surf.AxiStreamMux
         generic map (
            TPD_G         => TPD_G,
            NUM_SLAVES_G  => 2,
            PIPE_STAGES_G => 1)
         port map (
            -- Clock and reset
            axisClk         => axisClk,
            axisRst         => axisRst,
            -- Slaves
            sAxisMasters(0) => axisMasters(i),
            sAxisMasters(1) => repeatMasters(i),
            sAxisSlaves(0)  => axisSlaves(i),
            sAxisSlaves(1)  => repeatSlaves(i),
            -- Master
            mAxisMaster     => mAxisMasters(i),
            mAxisSlave      => mAxisSlaves(i));
   end generate GEN_VEC;

end mapping;
