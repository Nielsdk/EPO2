library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity override_controller is 
	port(
	clk : in std_logic;
	reset : in std_logic;
	translator_out : in std_logic_vector(7 downto 0);
	override_vector : out std_logic_vector(3 downto 0);
	override : out std_logic;
	reset_translater_out : out std_logic;
	count_reset : in std_logic;
	sensor_l           : in std_logic;
	sensor_m           : in std_logic;
	sensor_r           : in std_logic
	);

end entity override_controller;

architecture behavioural of override_controller is

	type override_controller_states is (
	read_sensor_and_listen,
	forward, backward, stop, right90, right, fastright, left90, left, fastleft);

	signal override_cont_state, override_cont_new_state : override_controller_states;
	signal pwm_count, new_pwm_count : unsigned (19 downto 0);
	signal pwm_count_out : std_logic_vector (19 downto 0);
	signal pwm_count_reset, distance : std_logic;
begin

	process (clk, reset)
begin
	if (rising_edge(clk)) then
		if (reset = '1') then
			override_cont_state <= read_sensor_and_listen;
		else
			override_cont_state <= override_cont_new_state;
		end if;
	end if;
end process;

process (clk, translator_out)
begin



pwm_count_reset <= '0'; 

case override_cont_state is

override_vector <= "0000"; -- moet iets zijn
		when read_sensor_and_listen => 
			reset_translater_out <= '0';
			
			if(sensor_l = '0' and sensor_m = '0' and sensor_r =  '0' and  distance = '1') then -- neem de lijnvolger over. 
				override <= '1';
				case translator_out is --Afhankelijk van het ingekomen signaal van C wordt er hier gekozen uit de juiste bocht.
					when "10000001" => override_cont_new_state <= forward;
					when "10000010" => override_cont_new_state <= right;
		--			when "0011" => override_cont_new_state <= fastright;
					when "10000100" => override_cont_new_state <= left;
		--			when "0101" => override_cont_new_state <= link;
		--			when "0110" => override_cont_new_state <= fastleft;
		--			when "0111" => override_cont_new_state <= left90;
					when "10000000" => override_cont_new_state <= backward;
					when "00000000" => override_cont_new_state <= stop;
					when others => override_cont_new_state <= read_sensor_and_listen;
				end case;
			else
				override <= '0';
				override_cont_new_state <= read_sensor_and_listen;
			end if;
			
		when forward =>  	-- Dit zijn de staten voor de verschillende bochten: rechtdoor, links en rechts bij een kruising. 
							-- Elk zullen zij voor een bepaalde aansturingsstijd een bepaalde stuurrichting van de controller kiezen.
							-- Pas als die tijd verstreken is kom de override_controller weer in zijn read_sensor_and_listen staat. 

			
			if(unsigned(pwm_count_out) < 50) then
				override_vector <= "0001"; -- De staat die de robot vooruit zal laten rijden.
				override_cont_new_state <= forward;
			else
				override_cont_new_state <= read_sensor_and_listen;
				reset_translater_out <= '1';
			end if;
			
		when left => 

			if(unsigned(pwm_count_out) < 50) then
				override_vector <= "0111"; -- harde bocht naar links 
				override_cont_new_state <= left;
			else
				override_cont_new_state <= read_sensor_and_listen;
				reset_translater_out <= '1';
			end if;
		
		when right =>

			if(unsigned(pwm_count_out) < 50) then
				override_vector <= "0100";
				override_cont_new_state <= right;
			else
				override_cont_new_state <= read_sensor_and_listen;
				reset_translater_out <= '1';
			end if;
			
		when backward =>

			if(unsigned(pwm_count_out) < 10) then
				override_vector <= "0100";
				override_cont_new_state <= backward;
			else
				override_cont_new_state <= read_sensor_and_listen;
				reset_translater_out <= '1';
			end if;

		when stop =>

			if(unsigned(pwm_count_out) < 10) then
				override_vector <= "0000";
				pwm_count_reset <= '0'; 
				override_cont_new_state <= stop;
			else
				override_cont_new_state <= read_sensor_and_listen;
				reset_translater_out <= '1';
				pwm_count_reset <= '1'; 
			end if;			
			
		when others => 
			reset_translater_out <= '0';
			override <= '0';
			override_cont_new_state <= read_sensor_and_listen;
end case;
end process;


process(clk)
begin
	if (rising_edge(count_reset)) then
		if(pwm_count_reset = '1') then
			pwm_count <= (others => '0');
		else
			pwm_count <= new_pwm_count;
		end if;
	end if;
end process;

process(pwm_count)

begin
	new_pwm_count <= pwm_count + 1;
end process;

pwm_count_out <= std_logic_vector(pwm_count);



end architecture behavioural;