-------------------------------------------------------------------------------
-- File       : AuroraRxChannel.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Company    : SLAC National Accelerator Laboratory
-- Platform   : 
-- Standard   : VHDL'93/02
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
      locked        : out sl);
end entity AuroraRxGearboxAligner;

architecture rtl of AuroraRxGearboxAligner is

   constant SLIP_WAIT_C  : positive := 100;
   constant LOCKED_CNT_C : positive := ite(SIMULATION_G, 100, 10000);

   type StateType is (
      UNLOCKED_S,
      SLIP_WAIT_S,
      LOCKED_S);

   type RegType is record
      enUsrDlyCfg : sl;
      usrDlyCfg   : slv(8 downto 0);
      dlyLoad     : slv(1 downto 0);
      dlyConfig   : slv(8 downto 0);
      slipWaitCnt : natural range 0 to SLIP_WAIT_C-1;
      goodCnt     : natural range 0 to LOCKED_CNT_C-1;
      slip        : sl;
      hdrErrDet   : sl;
      locked      : sl;
      state       : StateType;
   end record RegType;

   constant REG_INIT_C : RegType := (
      enUsrDlyCfg => '0',
      usrDlyCfg   => (others => '0'),
      dlyLoad     => (others => '0'),
      dlyConfig   => (others => '0'),
      slipWaitCnt => 0,
      goodCnt     => 0,
      slip        => '0',
      hdrErrDet   => '0',
      locked      => '0',
      state       => UNLOCKED_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (enUsrDlyCfg, r, rst, rxHeader, rxHeaderValid, usrDlyCfg) is
      variable v : RegType;

      procedure slipProcedure is
      begin

         -- Update and Increment the RX IDELAY configuration
         v.dlyLoad(1) := '1';
         v.dlyConfig  := r.dlyConfig + 1;

         -- Check for roll over of delay configuration
         if (v.dlyConfig = 0) then
            -- Slip by 1-bit in the gearbox
            v.slip := '1';
         end if;

         -- Reset the flag
         v.locked := '0';

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

      -- State Machine
      case r.state is
         ----------------------------------------------------------------------
         when UNLOCKED_S =>
            -- Check for data
            if (rxHeaderValid = '1') then
               -- Check for bad header
               if (rxHeader = "00" or rxHeader = "11") then
                  -- Execute the slip procedure
                  slipProcedure;
               else
                  -- Next state
                  v.state := LOCKED_S;
               end if;
            end if;
         ----------------------------------------------------------------------
         when SLIP_WAIT_S =>
            -- Check the counter
            if (r.slipWaitCnt = SLIP_WAIT_C-1) then
               -- Reset the counter
               v.slipWaitCnt := 0;
               -- Next state
               v.state       := UNLOCKED_S;
            else
               -- Increment the counter
               v.slipWaitCnt := r.slipWaitCnt + 1;
            end if;
         ----------------------------------------------------------------------
         when LOCKED_S =>
            -- Check for data
            if (rxHeaderValid = '1') then
               -- Check for bad header
               if (rxHeader = "00" or rxHeader = "11") then
                  -- Execute the slip procedure
                  slipProcedure;
               elsif (r.goodCnt /= LOCKED_CNT_C-1) then
                  -- Increment the counter
                  v.goodCnt := r.goodCnt + 1;
               else
                  -- Set the flag
                  v.locked := '1';
               end if;
            end if;
      ----------------------------------------------------------------------
      end case;

      -- Check for bad header
      if (rxHeaderValid = '1') and ((rxHeader = "00") or (rxHeader = "11")) then
         v.hdrErrDet := '1';
      end if;

      -- Keep a delayed copy
      v.enUsrDlyCfg := enUsrDlyCfg;
      v.usrDlyCfg   := usrDlyCfg;

      -- Check for changes in enUsrDlyCfg values or usrDlyCfg values
      if (r.enUsrDlyCfg /= v.enUsrDlyCfg) or (r.usrDlyCfg /= v.usrDlyCfg) then
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
