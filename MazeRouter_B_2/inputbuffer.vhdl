-- A2
-- Joris Bentvelsen 4460642
-- Laurens Rutten 4450787


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity inputbuffer is
	port (	clk				: in	std_logic;
			reset			: in	std_logic;
			sensor_l_in		: in	std_logic;
			sensor_m_in		: in	std_logic;
			sensor_r_in		: in	std_logic;

			sensor_l_out	: out	std_logic;
			sensor_m_out	: out	std_logic;
			sensor_r_out	: out	std_logic
	);
end entity inputbuffer;

architecture behavioural of inputbuffer is

signal sensor_l_buf_t, sensor_m_buf_t, sensor_r_buf_t : std_logic;

begin
process(clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			sensor_l_buf_t <= '0';
			sensor_m_buf_t <= '0';
			sensor_r_buf_t <= '0';
		else
			sensor_l_buf_t <= sensor_l_in;
			sensor_m_buf_t <= sensor_m_in;
			sensor_r_buf_t <= sensor_r_in;
		end if;
	end if;
end process;

process(clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			sensor_l_out <= '0';
			sensor_m_out <= '0';
			sensor_r_out <= '0';
		else
			sensor_l_out <= sensor_l_buf_t;
			sensor_m_out <= sensor_m_buf_t;
			sensor_r_out <= sensor_r_buf_t;
		end if;
	end if;
end process;

end architecture behavioural;