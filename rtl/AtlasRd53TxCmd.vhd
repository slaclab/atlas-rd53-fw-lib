-------------------------------------------------------------------------------
-- File       : AtlasRd53TxCmd.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: Module to generate CMD serial stream to RD53 ASIC
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
USE ieee.numeric_std.ALL;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiStreamPkg.all;

library atlas_rd53_fw_lib;

entity AtlasRd53TxCmd is
   generic (
      TPD_G : time := 1 ns);
   port (
      -- Cmd Value
      NOP_C       : in slv(15 downto 0) := b"0110_1001_0110_1001";
      SYNC_C      : in slv(15 downto 0) := b"1000_0001_0111_1110";
      SYNC_freq   : in slv(15 downto 0) := b"0000_0000_0010_0000";
      GPulse_C    : in slv(31 downto 0) := b"0101_1100_0101_1100_1010_0110_1010_0110";
      GPulse_freq : in slv(15 downto 0) := b"0000_0000_0000_0000";
      -- CMD mode: 00 normal; 01: 010101010101; 10: constant 1; 11 constant 0
      cmdMode     : in  slv(1 downto 0) := "00";
      -- Clock and Reset
      clkEn160MHz : in  sl;
      clk160MHz   : in  sl;
      rst160MHz   : in  sl;
      -- Streaming RD53 Config Interface (clk160MHz domain)
      cmdMaster   : in  AxiStreamMasterType;
      cmdSlave    : out AxiStreamSlaveType;
      -- Serial Output Interface
      cmdOut      : out sl);
end AtlasRd53TxCmd;

architecture rtl of AtlasRd53TxCmd is

   signal SYNC_C_reg        : slv(15 downto 0) := b"1000_0001_0111_1110";
   signal SYNC_freq_reg     : slv(15 downto 0) := b"0000_0000_0010_0000";
   signal GPulse_C_reg      : slv(31 downto 0) := b"0101_1100_0101_1100_1010_0110_1010_0110";
   signal GPulse_freq_reg   : slv(15 downto 0) := b"0000_0000_0000_0000";
   signal NOP_DWORD_C_reg   : slv(31 downto 0) := b"0101_0101_0101_0101_0101_0101_0101_0101";
   constant TRAIN_C       : slv(15 downto 0) := b"0101_0101_0101_0101";
   constant TRAIN_DWORD_C : slv(31 downto 0) := (TRAIN_C & TRAIN_C);
   constant All0_C        : slv(15 downto 0) := b"0000_0000_0000_0000";
   constant All0_DWORD_C  : slv(31 downto 0) := (All0_C & All0_C);
   constant All1_C        : slv(15 downto 0) := b"1111_1111_1111_1111";
   constant All1_DWORD_C  : slv(31 downto 0) := (All1_C & All1_C);

   type StateType is (
      INIT_S,
      LISTEN_S);

   type RegType is record
      syncCnt  : natural range 0 to 65535;
      gpulseCnt: natural range 0 to 65535;
      cmd      : sl;
      tData    : slv(31 downto 0);
      shiftReg : slv(31 downto 0);
      shiftCnt : slv(4 downto 0);
      init     : slv(8 downto 0);
      cmdSlave : AxiStreamSlaveType;
      state    : StateType;
   end record RegType;
   constant REG_INIT_C : RegType := (
      syncCnt  => 1,
      gpulseCnt=> 1,
      cmd      => '0',
      tData    => b"0101_0101_0101_0101_0101_0101_0101_0101",
      shiftReg => b"0101_0101_0101_0101_0101_0101_0101_0101",
      shiftCnt => (others => '0'),
      init     => (others => '1'),
      cmdSlave => AXI_STREAM_SLAVE_INIT_C,
      state    => INIT_S);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   SYNC_C_reg<=SYNC_C;
   SYNC_freq_reg<=SYNC_freq;
   GPulse_C_reg<=GPulse_C;
   GPulse_freq_reg<=GPulse_freq;
   NOP_DWORD_C_reg<= NOP_C & NOP_C;

   comb : process (clkEn160MHz, cmdMaster, cmdMode, SYNC_C_reg, SYNC_freq_reg, GPulse_C_reg, GPulse_freq_reg, NOP_DWORD_C_reg, r, rst160MHz) is
      variable v : RegType;
   begin
      -- Latch the current value
      v := r;

      -- Reset the strobes
      v.cmdSlave.tReady := '0';

      -- Check for the clk enable
      if (clkEn160MHz = '1') then

         -- Update the shift register
         case cmdMode is
            when "00"=>
               v.shiftReg := r.shiftReg(30 downto 0) & '0';
            when "01"=>
               v.shiftReg := r.shiftReg(30 downto 0) & '0';
            when "10"=>
               v.shiftReg := (others => '1');
            when "11"=>
               v.shiftReg := (others => '0');
         end case;

         -- Increment the counter
         v.shiftCnt := r.shiftCnt + 1;

         -- Check if last bit in shift registers sent
         if (r.shiftCnt = "11111") then

            -- Default shift reg update value
            case cmdMode is
               when "00"=>
                  v.shiftReg := NOP_DWORD_C_reg;
               when "01"=>
                  v.shiftReg := TRAIN_DWORD_C;
               when "10"=>
                  v.shiftReg := All1_DWORD_C;
               when "11"=>
                  v.shiftReg := All0_DWORD_C;
            end case;

            -- State Machine
            case r.state is
               ----------------------------------------------------------------------
               when INIT_S =>
                  -- Check initialization completed
                  if (r.init = 0) then
                     -- Next state
                     v.state := LISTEN_S;
                  else
                     -- Decrement the counter
                     v.init := r.init -1;
                  end if;
               ----------------------------------------------------------------------
               when LISTEN_S =>
                  -- Check for streaming data
                  if (cmdMaster.tValid = '1') then

                     -- Accept the data
                     v.cmdSlave.tReady := '1';

                     -- Move the data (only 32-bit data from the software)
                     case cmdMode is
                        when "00"=>
                           v.shiftReg := cmdMaster.tData(31 downto 0);
                        when "01"=>
                           v.shiftReg := TRAIN_DWORD_C;
                        when "10"=>
                           v.shiftReg := All1_DWORD_C;
                        when "11"=>
                           v.shiftReg := All0_DWORD_C;
                     end case;

                     -- Sample for simulation debugging
                     v.tData := cmdMaster.tData(31 downto 0);

                  end if;
            ----------------------------------------------------------------------
            end case;

            --------------------------------------------------------------------------------------
            -- It is recommended that at lest one sync frame be inserted at least every <SYNC_freq> frames.
            --------------------------------------------------------------------------------------
            if (r.syncCnt = SYNC_freq_reg(15 downto 1)) then  -- shift two frame into shiftReg
               -- Check for NOP and not forwarding user config
               if (v.shiftReg = NOP_DWORD_C_reg) and (v.cmdSlave.tReady = '0') then
                  -- Insert the SYNC frame
                  v.shiftReg(15 downto 0) := SYNC_C_reg;
                  -- Reset the counter
                  v.syncCnt               := 1;
               end if;
            else
			   if (r.syncCnt = 65535) then  -- loopback to 1
                  v.syncCnt               := 1;
			   end if;
               v.syncCnt := r.syncCnt + 1;

			   -- It is recommended that at lest one global pulse frame be inserted at least every <GPulse_freq> frames.
			   if (r.gpulseCnt = GPulse_freq_reg(15 downto 1)) then  -- shift two frame into shiftReg
																 -- Check for NOP and not forwarding user config
				   if (v.shiftReg = NOP_DWORD_C_reg) and (v.cmdSlave.tReady = '0') then
				  -- Insert the SYNC frame
					   v.shiftReg(31 downto 0) := GPulse_C_reg;
				  -- Reset the counter
					   v.gpulseCnt               := 1;
				   end if;
			   else
			       if (r.gpulseCnt = 65535) then  -- loopback to 1
                       v.gpulseCnt               := 1;
			       end if;

				   v.gpulseCnt := r.gpulseCnt + 1;
			   end if;

            end if;

         end if;

      end if;

      -- Outputs
      cmdSlave <= v.cmdSlave;
      cmdOut   <= r.shiftReg(31);

      -- Reset
      if (rst160MHz = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (clk160MHz) is
   begin
      if rising_edge(clk160MHz) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end rtl;
