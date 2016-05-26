library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity override_controller is
	generic(always_override : integer := 1);
	port(	clk, reset		:in std_logic;
		timebase		:in std_logic_vector(19 downto 0);
		translator_in		:in std_logic_vector(3 downto 0);
		translator_out_reset	:out std_logic;
		override_toggle		:out std_logic;
		override_out		:out std_logic_vector(3 downto 0)
	);
end entity override_controller;

architecture bh of override_controller is
	type state_type is (idle, update);

	signal override_reg, override_next : std_logic_vector (3 downto 0);
	signal state_reg, state_next	: state_type;
	signal translator_reset_reg, translator_reset_next : std_logic;
	signal translator_input_reg, translator_input_next : std_logic_vector(3 downto 0);
begin

	process(clk, reset)
	begin
		if(reset = '1') then
			override_reg <= (others=>'0');
			translator_input_reg <= (others=>'0');
			state_reg <= idle;
			override_toggle <= '1';
			translator_reset_reg <= '1';
		elsif(rising_edge(clk)) then
			override_reg <= override_next;
			state_reg <= state_next;
			translator_reset_reg <= translator_reset_next;
			translator_input_reg <= translator_input_next;
		end if;
	end process;

	process(translator_reset_reg, state_reg, override_reg, translator_in, timebase)
	begin
		override_toggle <= '1';
		override_next <= override_reg;
		state_next <= state_reg;
		translator_reset_next <= '0';
		translator_input_next <= translator_input_reg;
		case state_reg is
			when idle => 
				override_next <= translator_input_reg;
				if(unsigned(timebase) =  1000000) then
					state_next <= update;
				end if;
			when update =>
				translator_input_next <= translator_in;
				translator_reset_next <= '1';
				state_next <= idle;
		end case;
	end process;

	translator_out_reset <= translator_reset_reg;
	override_out <= override_reg;
end architecture bh;




