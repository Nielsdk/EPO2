-- A2
-- Joris Bentvelsen 4460642
-- Laurens Rutten 4450787


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity motorcontrol is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		direction	: in	std_logic;
		count_in	: in	std_logic_vector (19 downto 0);
		speed		: in 	std_logic;
		pwm		: out	std_logic
	);
end entity motorcontrol;


architecture behavioural of motorcontrol is

type motor_controller_state is (reset_state, pwm_high, pwm_low);

signal state, new_state : motor_controller_state;
begin

--Speed: '1' is snel, '0' is langzaam

process(clk)
begin
	if (rising_edge(clk)) then
		if(reset = '1') then
			state <= reset_state;
		else
			state <= new_state;
		end if;
	end if;
end process;

process (state, count_in, direction, speed, clk)
begin


new_state <= state;
	case state is
		when reset_state =>
			pwm <= '0';
	--		new_state <= pwm_high;
			if (unsigned(count_in) = "0000000000000000") then	-- Deze if zorgt ervoor dat 
				new_state <= pwm_high;
			else
					new_state <= reset_state;
			end if;
		
		
		when pwm_high =>
			pwm <= '1';
			if (direction = '0') then
				if (speed = '1') then
				
					if (unsigned(count_in) < 50000) then -- fast: 1100001101010000 slow: 1110101001100000
						new_state <= pwm_high;
					else
						new_state <= pwm_low;
					end if;
					
				else
				
					if (unsigned(count_in) < 68000) then -- fast: 1100001101010000 slow: 1110101001100000
						new_state <= pwm_high;
					else
						new_state <= pwm_low;
					end if;
					
				end if;
				
			else
				if (speed = '1') then
					if(unsigned(count_in) < 100000) then --  fast 11000011010100000 slow: 10100110000001000
						new_state <= pwm_high;
					else
						new_state <= pwm_low;
					end if;
				
				else
				
					if(unsigned(count_in) < 82000) then --  fast 11000011010100000 slow: 10100110000001000
						new_state <= pwm_high;
					else
						new_state <= pwm_low;
					end if;
					
				end if;
			end if;
		when pwm_low =>
			pwm <= '0';
			
			
	end case;
end process;

end architecture behavioural;

