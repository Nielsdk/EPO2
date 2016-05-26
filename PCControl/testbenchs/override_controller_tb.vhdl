library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end entity tb;

architecture override_controller_bench of tb is
	component override_controller is
	generic(always_override : integer := 1);
	port(	clk, reset		:in std_logic;
		timebase		:in std_logic_vector(19 downto 0);
		translator_in		:in std_logic_vector(3 downto 0);
		translator_out_reset	:out std_logic;
		override_toggle		:out std_logic;
		override_out		:out std_logic_vector(3 downto 0)
	);
	end component override_controller;
	component timebase is
	port (	clk		: in std_logic;				-- systeem clock @ 50Mhz
		reset		: in std_logic;				-- synchrone reset
		count_out	: out std_logic_vector(19 downto 0) 	-- 20 bits, er moet tot 10*10^6 geteld worden. 
		);
	end component timebase;

	signal clk, reset, translator_out_reset, override_toggle : std_logic;
	signal timebase_tussen : std_logic_vector(19 downto 0);
	signal translator_in, override_out : std_logic_vector(3 downto 0);
begin

KLK:	clk			<=	'1' after 0 ns,
	       			'0' after 10 ns when clk /= '0' else '1' after 10 ns;
rst:	reset			<=	'1' after 0 ns,
			 	'0' after 100 ns;
S00:	translator_in		<=	"0001" after 0 ns,
					"0001" after 200 ns when translator_out_reset /= '1' else "0000" after 200 ns;
C00:	override_controller port map (	clk => clk,
					reset => reset,
					timebase => timebase_tussen,
					translator_in => translator_in,
					translator_out_reset => translator_out_reset,
					override_toggle => override_toggle,
					override_out => override_out
				);
C01:	timebase	port map (	clk => clk,
					reset => reset,
					count_out => timebase_tussen
				);

end architecture override_controller_bench;

