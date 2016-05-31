library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity override_controller is
	port (
		clk                   : in std_logic;
		reset                 : in std_logic;
		translator_out        : in std_logic_vector(7 downto 0);
		override_vector       : out std_logic_vector(3 downto 0);
		override              : out std_logic;
		translator_out_reset  : out std_logic;
		count_reset           : in std_logic;
		sensor_l              : in std_logic;
		sensor_m              : in std_logic;
		sensor_r              : in std_logic
	);

end entity override_controller;

architecture behavioural of override_controller is

	type override_controller_states is (
	read_sensor_and_listen, 
	forward, backward, stop, right90, right, fastright, left90, left, fastleft, forward_station, left_station, right_station);

	type station_state_type is (first, second, third);
	signal station_state, new_station_state : station_state_type;
	
	signal override_cont_state, override_cont_new_state : override_controller_states;
	signal pwm_count, new_pwm_count, long_pwm_count, new_long_pwm_count : unsigned (19 downto 0);
	signal pwm_count_out : std_logic_vector (19 downto 0);
	signal pwm_count_reset, long_pwm_count_reset : std_logic;
--	signal station_state : std_logic;
	
begin

process (clk, reset)
begin
	if (rising_edge(clk)) then
		if (reset = '1') then
			override_cont_state <= read_sensor_and_listen;
			station_state <= first;
		else
			override_cont_state <= override_cont_new_state;
			station_state <= new_station_state;
		end if;
	end if;
end process;

process (clk, translator_out, sensor_l, sensor_m, sensor_r, override_cont_state, pwm_count, long_pwm_count, pwm_count_out)

--variable station_state : integer := 0;
begin
	--pwm_count_reset <= '1';
	--translator_out_reset <= '0';
 	--override_vector <= "0000";-- moet iets zijn
	new_station_state <= station_state;
	
	long_pwm_count_reset <= '0';
	case override_cont_state is

		when read_sensor_and_listen => 
			translator_out_reset <= '0';
			override_vector <= "0000";
			new_station_state <= first;
 
			if (sensor_l = '0' and sensor_m = '0' and sensor_r = '0'  and long_pwm_count > 2 ) then -- neem de lijnvolger over. DISTANCE MOET TOEGEVOEGD WORDEN. or distance = '1'
				override <= '1';
				pwm_count_reset <= '1'; -- Hij komt in de override stand en mag beginnen met tellen van het aantal pwm perioden.
				
				
				case translator_out is --Afhankelijk van het ingekomen signaal van C wordt er hier gekozen uit de juiste bocht.
					when "10000000" => override_cont_new_state <= stop;				
					when "10000001" => override_cont_new_state <= forward;
					when "10000010" => override_cont_new_state <= right;
					when "10000100" => override_cont_new_state <= left;
					when "10001000" => override_cont_new_state <= backward;
					when "11000001" => override_cont_new_state <= forward_station;
					when "11000010" => override_cont_new_state <= right_station;
					when "11000100" => override_cont_new_state <= left_station;
												
					when others => override_cont_new_state <= read_sensor_and_listen; -- pwm_count_reset <= '0';
				end case;
			else
				override <= '0';
				pwm_count_reset <= '0'; --pwm_count is een counter die telt per 20 ms. Zo is het aantal pwm pulsen te tellen.
				override_cont_new_state <= read_sensor_and_listen;
			end if;
 
		--------------------------------------------------------------------------------------------------------------
		-- Dit zijn de staten voor de verschillende bochten: rechtdoor, links en rechts bij een kruising.			--
		-- Elk zullen zij voor een bepaalde aansturingsstijd een bepaalde stuurrichting van de controller kiezen.	--
		-- Pas als die tijd verstreken is kom de override_controller weer in zijn read_sensor_and_listen staat.		--
		--------------------------------------------------------------------------------------------------------------
		
		when forward =>
 
			if (unsigned(pwm_count_out) < 50) then

				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0001"; -- De staat die de robot vooruit zal laten rijden.
				override_cont_new_state <= forward;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		when left => 

			if (unsigned(pwm_count_out) < 3) then
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0111"; -- harde bocht naar links
				override_cont_new_state <= left;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		when right => 

			if (unsigned(pwm_count_out) < 4) then
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0100";
				override_cont_new_state <= right;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		when backward => 
		
			if (unsigned(pwm_count_out) < 50) then
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "1000";
				override_cont_new_state <= backward;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;

		when stop => 
		
			if (unsigned(pwm_count_out) < 2) then
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0000";
				override_cont_new_state <= stop;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if; 
			
		when forward_station => -- Eerst een bepaalde afstand naar voren rijden. GEEN long_pwm_count_reset uitvoeren! 180 graden draaien. Lijnvolgen. Signaal afgeven dat hij verder kan.
		
			if (unsigned(pwm_count_out) < 3) then -- 0.15 m vooruit met 0.14 m/s. Dat is 1 seconde = 50 pwm counts. Hier gaat hij gewoon een stukje lijnvolgen
				pwm_count_reset <= '0';
				override <= '0'; --lijnvolgen dus override = '0'
				override_vector <= "1000";
				override_cont_new_state <= forward_station;
				translator_out_reset <= '0';
			elsif(unsigned(pwm_count_out) < 5) then -- voor 0.5 seconde 180 graden bocht maken. (25 counts uiteindelijk)
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0111";
				override_cont_new_state <= forward_station;
				translator_out_reset <= '0';				
			else
				long_pwm_count_reset <= '0'; --deze moet '0' zijn omdat hier niet opnieuw een afstandsmeting gedaan hoeft te worden. Hierna mag er gewoon weer lijngevolgd worden tot het volgende station.
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
			
		when left_station => -- VOORBEELD VOOR FORWARD_STATION COMMANDO.
			

			if ((sensor_l = '0' or sensor_m = '0' or sensor_r = '0') and station_state = first) then -- lijnvolgen zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
				pwm_count_reset <= '0';
				override <= '0';
				override_vector <= "1000"; -- moet iets zijn
				override_cont_new_state <= left_station;
				translator_out_reset <= '0';
				new_station_state <= first;
			elsif(sensor_l = '1') then -- Bocht maken als hij aan het einde van de lijn is (vorige conditie eindigt). Dan geldt: sensor_l ='1' (wit).  Dan  180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0100"; -- drive_motor_fastright.
				override_cont_new_state <= left_station;
				translator_out_reset <= '0';
				new_station_state <= second;			
			else
				long_pwm_count_reset <= '0'; -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand. Hij moet hier weer een signaal sturen naar de pc dat hij het volgende commando wil.
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
				new_station_state <= third;
			end if;

		when right_station => 
		
			if (unsigned(pwm_count_out) < 50) then
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "1000";
				override_cont_new_state <= backward;
				translator_out_reset <= '0';
			else
				long_pwm_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		when others => 
			long_pwm_count_reset <= '0';
			pwm_count_reset <= '0';
			override <= '0';
			override_vector <= "0000";-- moet iets zijn
			override_cont_new_state <= read_sensor_and_listen;
			translator_out_reset <= '0';
	end case;
end process;

process (count_reset, pwm_count_reset, reset, clk)
begin
	if (reset = '1' or pwm_count_reset = '1') then
		pwm_count <= (others => '0');
	elsif (rising_edge(count_reset)) then
		pwm_count <= new_pwm_count;
	end if;
 
end process;

process (pwm_count)

begin
	new_pwm_count <= pwm_count + 1;
end process;

process (count_reset, long_pwm_count_reset, reset, clk)
begin
	if (reset = '1' or long_pwm_count_reset = '1') then
		long_pwm_count <= (others => '0');
	elsif (rising_edge(count_reset)) then
		long_pwm_count <= new_long_pwm_count;
	end if;
 
end process;

process (long_pwm_count)

begin
	new_long_pwm_count <= long_pwm_count + 1;
end process;

pwm_count_out <= std_logic_vector(pwm_count);

end architecture behavioural;

