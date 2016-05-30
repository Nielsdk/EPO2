-- A2
-- Joris Bentvelsen 4460642
-- Laurens Rutten 4450787

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;



entity timebase is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		count_reset : in	std_logic;
		count_out	: out	std_logic_vector (19 downto 0)
	);
end entity timebase;


architecture behavioural of timebase is

signal count, new_count : unsigned (19 downto 0);

begin
	--This process generates the register

process(clk, reset) -- Heeft een asynchrone reset gekregen. (bedoeling?)
begin
	if(reset = '1') then
			count <= (others => '0');
	elsif(rising_edge(clk)) then
		if(count_reset = '1') then
			count <= (others => '0');
		else
			count <= new_count;
		end if;
	end if;
end process;

process(count)
begin
	new_count <= count + 1;
end process;

count_out <= std_logic_vector(count);


end architecture behavioural;
