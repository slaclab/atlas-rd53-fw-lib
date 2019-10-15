-------------------------------------------------------------------------------
-- File       : AuroraRxChannel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Aligns the LVDS RX gearbox.
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
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

use work.StdRtlPkg.all;

entity AuroraRxGearboxAligner is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false);
   port (
      clk           : in  sl;
      rst           : in  sl;
      rxHeader      : in  slv(1 downto 0);
      rxHeaderValid : in  sl;
      bitSlip       : out sl;
      hdrErrDet     : out sl;
      dlyLoad       : out sl;
      dlyCfg        : out slv(8 downto 0);
      enUsrDlyCfg   : in  sl;
      usrDlyCfg     : in  slv(8 downto 0);
      slideDlyDir   : in  sl;
      slideDlyCfg   : in  slv(5 downto 0);
      locked        : out sl);
end entity AuroraRxGearboxAligner;

architecture rtl of AuroraRxGearboxAligner is

   constant SLIP_WAIT_C  : positive := ite(SIMULATION_G, 10, 100);
   constant LOCKED_CNT_C : positive := ite(SIMULATION_G, 100, 1000);

   type StateType is (
      UNLOCKED_S,
      SLIP_WAIT_S,
      LOCKING_S,
      EYE_SCAN_S,
      LOCKED_S);

   type RegType is record
      enUsrDlyCfg : sl;
      usrDlyCfg   : slv(8 downto 0);
      dlyLoad     : slv(1 downto 0);
      dlyConfig   : slv(8 downto 0);
      dlyCache    : slv(8 downto 0);
      slipWaitCnt : natural range 0 to SLIP_WAIT_C-1;
      goodCnt     : natural range 0 to LOCKED_CNT_C-1;
      slip        : sl;
      hdrErrDet   : sl;
      armed       : sl;
      scanDone    : sl;
      locked      : sl;
      state       : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      enUsrDlyCfg => '0',
      usrDlyCfg   => (others => '0'),
      dlyLoad     => (others => '0'),
      dlyConfig   => toSlv(64, 9),
      dlyCache    => toSlv(64, 9),
      slipWaitCnt => 0,
      goodCnt     => 0,
      slip        => '0',
      hdrErrDet   => '0',
      armed       => '0',
      scanDone    => '0',
      locked      => '0',
      state       => UNLOCKED_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (enUsrDlyCfg, r, rst, rxHeader, rxHeaderValid, slideDlyCfg,
                   usrDlyCfg) is
      variable v : RegType;

      procedure slipProcedure is
      begin

         -- Update the Delay module
         v.dlyLoad(1) := '1';

         -- Check for max value
         if (r.dlyConfig >= (511-63)) then

            -- Set min. value
            v.dlyConfig := toSlv(64, 9);

            -- Slip by 1-bit in the gearbox
            v.slip := '1';

         else
            -- Increment the counter
            v.dlyConfig := r.dlyConfig + 1;
         end if;

         -- Reset the flags
         v.armed    := '0';
         v.scanDone := '0';
         v.locked   := '0';

         -- Reset the counter
         v.goodCnt := 0;

         -- Next state
         v.state := SLIP_WAIT_S;

      end procedure slipProcedure;

   begin
      -- Latch the current value
      v := r;

      -- Reset strobes
      v.slip      := '0';
      v.hdrErrDet := '0';

      -- Shift register
      v.dlyLoad := '0' & r.dlyLoad(1);

      -- Check for bad header
      if (rxHeaderValid = '1') and ((rxHeader = "00") or (rxHeader = "11")) then
         v.hdrErrDet := '1';
      end if;

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when UNLOCKED_S =>
            -- Check for data
            if (rxHeaderValid = '1') then
               -- Check for bad header
               if (v.hdrErrDet = '1') then
                  -- Execute the slip procedure
                  slipProcedure;
               else
                  -- Next state
                  v.state := LOCKING_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when SLIP_WAIT_S =>
            -- Check the counter
            if (r.slipWaitCnt = SLIP_WAIT_C-1) then

               -- Reset the counter
               v.slipWaitCnt := 0;

               -- Check if eye scan completed
               if (r.scanDone = '1') then
                  -- Next state
                  v.state := LOCKED_S;
               -- Check for armed mode
               elsif (r.armed = '1') then
                  -- Next state
                  v.state := EYE_SCAN_S;
               else
                  -- Next state
                  v.state := UNLOCKED_S;
               end if;

            else
               -- Increment the counter
               v.slipWaitCnt := r.slipWaitCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when LOCKING_S =>
            -- Check for data
            if (rxHeaderValid = '1') then

               -- Check for bad header
               if (v.hdrErrDet = '1') then
                  -- Execute the slip procedure
                  slipProcedure;

               elsif (r.goodCnt /= LOCKED_CNT_C-1) then
                  -- Increment the counter
                  v.goodCnt := r.goodCnt + 1;
               else

                  -- Set the flag
                  v.armed := '1';

                  -- Reset the counter
                  v.goodCnt := 0;

                  -- Make a cached copy
                  v.dlyCache := r.dlyConfig;

                  -- Update the Delay module
                  v.dlyLoad(1) := '1';
                  v.dlyConfig  := r.dlyConfig + 1;

                  -- Next state
                  v.state := SLIP_WAIT_S;

               end if;
            end if;
         ----------------------------------------------------------------------
         when EYE_SCAN_S =>
            -- Check for data
            if (rxHeaderValid = '1') then

               -- Check for bad header
               if (v.hdrErrDet = '1') then
                  -- Execute the slip procedure
                  slipProcedure;

               elsif (r.goodCnt /= LOCKED_CNT_C-1) then
                  -- Increment the counter
                  v.goodCnt := r.goodCnt + 1;
               else

                  -- Reset the counter
                  v.goodCnt := 0;

                  -- Update the Delay module
                  v.dlyLoad(1) := '1';
                  v.dlyConfig  := r.dlyConfig + 1;

                  -- Check if a 64 count wide eye has been detected
                  if (r.dlyConfig-r.dlyCache) = 63 then

                     -- Perform the slide
                     v.dlyConfig := r.dlyConfig - resize(slideDlyCfg, 9);

                     -- Set the flag
                     v.scanDone := '1';

                  end if;

                  -- Next state
                  v.state := SLIP_WAIT_S;

               end if;
            end if;
         ----------------------------------------------------------------------
         when LOCKED_S =>
            -- Check for data
            if (rxHeaderValid = '1') then

               -- Check for bad header
               if (v.hdrErrDet = '1') then
                  -- Execute the slip procedure
                  slipProcedure;

               else
                  -- Set the flag
                  v.locked := '1';
               end if;

            end if;
      ----------------------------------------------------------------------
      end case;

      -- Keep a delayed copy
      v.enUsrDlyCfg := enUsrDlyCfg;
      v.usrDlyCfg   := usrDlyCfg;

      -- Check for changes in enUsrDlyCfg values or usrDlyCfg values or dlyConfig value
      if (r.enUsrDlyCfg /= v.enUsrDlyCfg) or (r.usrDlyCfg /= v.usrDlyCfg) or (r.dlyConfig /= v.dlyConfig) then
         -- Update the RX IDELAY configuration
         v.dlyLoad(1) := '1';
      end if;

      -- Outputs 
      locked    <= r.locked;
      bitSlip   <= r.slip;
      dlyLoad   <= r.dlyLoad(0);
      hdrErrDet <= r.hdrErrDet;

      -- Check if using user delay configuration
      if (enUsrDlyCfg = '1') then
         -- Force to user configuration
         dlyCfg <= usrDlyCfg;
      else
         -- Else use the automatic value
         dlyCfg <= r.dlyConfig;
      end if;

      -- Reset
      if (rst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk) is
   begin
      if (rising_edge(clk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
