-- A2
-- Joris Bentvelsen 4460642
-- Laurens Rutten 4450787


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity inputbuffer is
	port (	clk				: in	std_logic;
			reset			: in	std_logic;
			sensor_in		: in	std_logic;
			sensor_out	: out	std_logic
	);
end entity inputbuffer;

architecture behavioural of inputbuffer is

signal sensor_buf_t : std_logic;

begin
process(clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			sensor_buf_t <= '0';
		else
			sensor_buf_t <= sensor_in;
		end if;
	end if;
end process;

process(clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			sensor_out <= '0';
		else
			sensor_out <= sensor_buf_t;
		end if;
	end if;
end process;

end architecture behavioural;