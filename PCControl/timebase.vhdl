Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity timebase is
	port (	clk		: in std_logic;				-- systeem clock @ 50Mhz
		reset		: in std_logic;				-- synchrone reset
		count_out	: out std_logic_vector(19 downto 0) 	-- 20 bits, er moet tot 10*10^6 geteld worden. 
		);
end entity timebase;

architecture behavioural of timebase is
	signal count, new_count	: unsigned (19 downto 0);
begin
	process(clk)
	begin
		if(rising_edge(clk)) then
			if (reset = '1') then
				count <= (others => '0');		-- alles wordt op 0 gezet. others: 'The keyword others may be used to refer to all elements not mentioned'
			else
				count <= new_count;			-- als reset niet hoog is, te op.
			end if;
		end if;
	end process;

	process(count)
	begin
		new_count <= count + 1;
	end process;
	
	count_out <= std_logic_vector(count);				-- output aan count vastmaken. count is unsigned, dus het is nodig om om te zetten.
end architecture behavioural;




