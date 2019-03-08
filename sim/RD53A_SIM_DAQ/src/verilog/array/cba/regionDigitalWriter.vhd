------------------------------------------------------------------------------------------------------
--                                        VLSI Design Laboratory
--                               Istituto Nazionale di Fisica Nucleare (INFN)
--                                   via Giuria 1 10125, Torino, Italy
------------------------------------------------------------------------------------------------------
-- [Filename]		RegionDigitalWriter.vhd
-- [Project]		CHIPIX65
-- [Author]			Andrea Paterno' - andrea.paterno@to.infn.it
-- [Language]		VHDL 2008 [IEEE Std. 1076-2008]
-- [Created]		Dec, 2015
-- [Modified]		Jan 13, 2015
-- [Description]	Buffer writing logic, assigns pixel tots to buffer tot spots and writes the hit map.
-- [Notes]			Compile with the -v200x option
-- [Version]		1.0
-- [Revisions]		/
-------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_misc.all;
use IEEE.numeric_std.all;
use std.textio.all;

entity RegionDigitalWriter is
	generic (
		TOT_BITS				: integer;
		WIDTH					: integer
	);
	port (
		totValues				: in std_logic_vector(16*TOT_BITS-1 downto 0);
		hitReady				: in std_logic_vector(15 downto 0);

		-- Outputs
		memoryDataTotValues		: out std_logic_vector(WIDTH*TOT_BITS-1 downto 0)
	);
end RegionDigitalWriter;

architecture rtl of RegionDigitalWriter is

	constant REGION_BUFFER_TOT_NUM : integer := WIDTH;
	constant REGION_PIXEL_NUM_LOG2 : integer := 4;
	constant PIXEL_TOT_BITS : integer := TOT_BITS;

	-- TOT column assignment
	type wparr is array (0 to REGION_BUFFER_TOT_NUM-1) of std_logic_vector(0 to 2**REGION_PIXEL_NUM_LOG2-1);
	type pwarr is array (0 to 2**REGION_PIXEL_NUM_LOG2-1) of std_logic_vector(0 to REGION_BUFFER_TOT_NUM-1);
	type pwarre is array (0 to 2**REGION_PIXEL_NUM_LOG2-1) of std_logic_vector(0 to REGION_BUFFER_TOT_NUM);
	signal wp : wparr;
	signal pw : pwarr;
	signal anyw : wparr;
	signal anyp : pwarre;

	signal hitReadyDelayed	: std_logic_vector(15 downto 0);
	signal itotValues		: std_logic_vector(PIXEL_TOT_BITS*WIDTH-1 downto 0);

	signal hitReadyGated : std_logic_vector(15 downto 0);

begin

	-- Memory Write data
	memoryDataTotValues <= itotValues;

	-- If in Binary Only mode, there's no need to assign the TOTs to the slots.
	hitReadyGated <= hitReady;

	--
	-- This logic binds a pixel to a slot in the row.
	--

	-- Binds pw to wp.
	pwwppg : for pix in 0 to 2**REGION_PIXEL_NUM_LOG2-1 generate
		pwwpbg : for buf in 0 to REGION_BUFFER_TOT_NUM-1 generate
			wp(buf)(pix) <= pw(pix)(buf);
		end generate;
	end generate;

	-- anyw(buf) is a vector. If its i-th element is 1, it means that the location "buf" was allotted
	-- to a pixel whose index is below i. Ultimately, if anyw(buf)(2**REGION_PIXEL_NUM_LOG2-1) is 1,
	-- it means that the buffer "buf" is full.
	anywbg : for buf in 0 to REGION_BUFFER_TOT_NUM-1 generate
		anywpg : for pix in 0 to 2**REGION_PIXEL_NUM_LOG2-1 generate
			anywz : if pix = 0 generate
				anyw(buf)(pix) <= '0';
			end generate;

			anywnz : if pix /= 0 generate
				anyw(buf)(pix) <= anyw(buf)(pix-1) or wp(buf)(pix-1);
			end generate;
		end generate;
	end generate;

	-- anyp(pix) is a vector. If its i-th element is 1, it means that the pixel "pix" was already
	-- associated to a buffer location whose index is below i.
	anypwg : for pix in 0 to 2**REGION_PIXEL_NUM_LOG2-1 generate
		anypbg : for buf in 0 to REGION_BUFFER_TOT_NUM generate
			anypz : if buf = 0 generate
				anyp(pix)(buf) <= '0';
			end generate;

			anypnz : if buf /= 0 generate
				anyp(pix)(buf) <= anyp(pix)(buf-1) or pw(pix)(buf-1);
			end generate;
		end generate;
	end generate;

	-- Real association between buffer location and pixels. A pixel is associated to a buffer location if:
	-- 1) The pixel contains data
	-- 2) The location was not assigned to a preceding pixel
	-- 3) The pixel was not assigned to a preceding location
	pg : for pix in 0 to 2**REGION_PIXEL_NUM_LOG2-1 generate
		bg : for buf in 0 to REGION_BUFFER_TOT_NUM-1 generate
			pi : if buf <= pix generate
				pw(pix)(buf) <= hitReadyGated(pix) and not anyw(buf)(pix) and not anyp(pix)(buf);
			end generate;

			ni : if buf > pix generate
				pw(pix)(buf) <= '0';
			end generate;
		end generate;
	end generate;

	-- Mega multiplexer.
	itvg : process(pw, totValues)
	begin
		itotValues <= (others => '0');

		for buf in 0 to REGION_BUFFER_TOT_NUM-1 loop
			for pix in 0 to 2**REGION_PIXEL_NUM_LOG2-1 loop
				if pw(pix)(buf) = '1' then
--					report "pix " & integer'image(pix) & " buf " & integer'image(buf);
					itotValues((buf+1)*PIXEL_TOT_BITS-1 downto buf*PIXEL_TOT_BITS) <= totValues((pix+1)*PIXEL_TOT_BITS-1 downto pix*PIXEL_TOT_BITS);
				end if;
			end loop;
		end loop;
	end process;

end rtl;

