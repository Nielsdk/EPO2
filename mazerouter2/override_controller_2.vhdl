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

	type station_state_type is (first, second, third, fourth);
	signal station_state, new_station_state : station_state_type;
 
	signal override_cont_state, override_cont_new_state : override_controller_states;
	signal pwm_count, new_pwm_count, distance_count, new_distance_count : unsigned (19 downto 0);
	signal pwm_count_out : std_logic_vector (19 downto 0);
	signal pwm_count_reset, distance_count_reset : std_logic;
 
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

process (clk, translator_out, sensor_l, sensor_m, sensor_r, override_cont_state, pwm_count, distance_count, pwm_count_out, station_state)

begin
	--pwm_count_reset <= '1';
	--translator_out_reset <= '0';
	--override_vector <= "0000";-- moet iets zijn
	new_station_state <= station_state;
 
	
	case override_cont_state is

		when read_sensor_and_listen => 
			translator_out_reset <= '0';
			override_vector <= "0000"; -- Stel hij override de controller hier, dan zet hij de robot stil.
			new_station_state <= first;
			distance_count_reset <= '0';

			if (sensor_l = '0' and sensor_m = '0' and sensor_r = '0' and distance_count > 2 ) then -- neem de lijnvolger over. DISTANCE MOET TOEGEVOEGD WORDEN.
				override <= '1';
				pwm_count_reset <= '1'; -- Hij komt in de override stand en mag beginnen met tellen van het aantal pwm perioden.
 
				case translator_out is --Afhankelijk van het ingekomen signaal van C wordt er hier gekozen uit de juiste bocht.
					when "10000000" => override_cont_new_state <= stop; 
					when "10000001" => override_cont_new_state <= forward;
					when "10000010" => override_cont_new_state <= right;
					when "10000100" => override_cont_new_state <= left;
					when "10001000" => override_cont_new_state <= backward;
					when "11000001" => override_cont_new_state <= forward_station;
					when "11000010" => override_cont_new_state <= LEFT_STATION; ----------------OMGEDRAAID MET LEFT_STATION!!!!!!!!!
					when "11000100" => override_cont_new_state <= RIGHT_STATION;
					when others => override_cont_new_state <= read_sensor_and_listen; 
				end case;
			else
				override <= '0';
				pwm_count_reset <= '0'; --pwm_count is een counter die telt per 20 ms. Zo is het aantal pwm pulsen te tellen.
				override_cont_new_state <= read_sensor_and_listen;
			end if;

			----------------------------------------------------------------------------------------------------------------------
			-- Dit zijn de staten voor de verschillende bochten: rechtdoor, links en rechts bij een kruising.
			-- Er zijn ook staten voor een bocht naar een station, hier zal de staat ook de bocht aan het einde van de weg maken.
			-- Aan het einde van de actie komt de override_controller weer in zijn read_sensor_and_listen staat.
			----------------------------------------------------------------------------------------------------------------------
 
		when forward => --Een korte periode vooruit rijden en daarna weer over op lijnvolgen.
			case station_state is
				when first =>
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0001"; -- harde bocht naar links
					override_cont_new_state <= forward;
					translator_out_reset <= '0';
			
					if (unsigned(pwm_count_out) < 3) then
						new_station_state <= first;
					else
						new_station_state <= second;
					end if;
				
				when others => --second and others.
					distance_count_reset <= '1';
					pwm_count_reset <= '1';
					override <= '0';
					override_vector <= "0000";-- moet iets zijn
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
			end case;
				
--			if (unsigned(pwm_count_out) < 50) then
--				distance_count_reset <= '0';
--				pwm_count_reset <= '0';
--				override <= '1';
--				override_vector <= "0001"; -- De staat die de robot vooruit zal laten rijden.
--				override_cont_new_state <= forward;
--				translator_out_reset <= '0';
--			else
--				distance_count_reset <= '1';
--				pwm_count_reset <= '1';
--				override <= '0';
--				override_vector <= "0000";-- moet iets zijn
--				override_cont_new_state <= read_sensor_and_listen;
--				translator_out_reset <= '1';
--			end if;

		when left => -- Voor een bepaalde tijd een bocht naar links maken en daarna weer lijnvolgen.

			case station_state is
				when first =>
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0111"; -- harde bocht naar links
					override_cont_new_state <= left;
					translator_out_reset <= '0';
			
					if (unsigned(pwm_count_out) < 3) then
						new_station_state <= first;
					else
						new_station_state <= second;
					end if;
				
				when others => --second and others.
					distance_count_reset <= '1';
					pwm_count_reset <= '1';
					override <= '0';
					override_vector <= "0000";-- moet iets zijn
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
			end case;
				
			
--			if (unsigned(pwm_count_out) < 3) then
--				distance_count_reset <= '0';
--				pwm_count_reset <= '0';
--				override <= '1';
--				override_vector <= "0111"; -- harde bocht naar links
--				override_cont_new_state <= left;
--				translator_out_reset <= '0';
--			else
--				distance_count_reset <= '1';
--				pwm_count_reset <= '0';
--				override <= '0';
--				override_vector <= "0000";-- moet iets zijn
--				override_cont_new_state <= read_sensor_and_listen;
--				translator_out_reset <= '1';
--			end if;

		when right => -- Voor een bepaalde periode een bocht naar rechts maken en dan weer lijnvolgen.
			case station_state is
				when first =>
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0100"; -- harde bocht naar rechts
					override_cont_new_state <= right;
					translator_out_reset <= '0';
			
					if (unsigned(pwm_count_out) < 3) then
						new_station_state <= first;
					else
						new_station_state <= second;
					end if;
				
				when others => --second and others.
					distance_count_reset <= '1';
					pwm_count_reset <= '1';
					override <= '0';
					override_vector <= "0000";-- moet iets zijn
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
			end case;
		
		
--			if (unsigned(pwm_count_out) < 4) then
--				distance_count_reset <= '0';
--				pwm_count_reset <= '0';
--				override <= '1';
--				override_vector <= "0100";
--				override_cont_new_state <= right;
--				translator_out_reset <= '0';
--			else
--				distance_count_reset <= '1';
--				pwm_count_reset <= '1';
--				override <= '0';
--				override_vector <= "0000";-- moet iets zijn
--				override_cont_new_state <= read_sensor_and_listen;
--				translator_out_reset <= '1';
--			end if;

		when backward => -- Deze staat is nog niet functioneel
 
			if (unsigned(pwm_count_out) < 50) then
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "1000";
				override_cont_new_state <= backward;
				translator_out_reset <= '0';
			else
				distance_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;

		when stop => 
 
			if (unsigned(pwm_count_out) < 2) then
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0000";
				override_cont_new_state <= stop;
				translator_out_reset <= '0';
			else
				distance_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		--LET OP! DIT IS EEN OUDE VERSIE, BIJ LEFT_STATION STAAT EEN WELLICHT BETERE VERSIE OM DIT AAN TE PAKKEN.
		when forward_station => -- Eerst een bepaalde afstand naar voren rijden. GEEN distance_count_reset uitvoeren! 180 graden draaien. Lijnvolgen. Signaal afgeven dat hij verder kan.
 
			if (unsigned(pwm_count_out) < 3) then -- 0.15 m vooruit met 0.14 m/s. Dat is 1 seconde = 50 pwm counts. Hier gaat hij gewoon een stukje lijnvolgen
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '0'; --lijnvolgen dus override = '0'
				override_vector <= "1000";
				override_cont_new_state <= forward_station;
				translator_out_reset <= '0';
			elsif (unsigned(pwm_count_out) < 5) then -- voor 0.5 seconde 180 graden bocht maken. (25 counts uiteindelijk)
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0111";
				override_cont_new_state <= forward_station;
				translator_out_reset <= '0'; 
			else
				distance_count_reset <= '0'; --deze moet '0' zijn omdat hier niet opnieuw een afstandsmeting gedaan hoeft te worden. Hierna mag er gewoon weer lijngevolgd worden tot het volgende station.
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			end if;
 
		when left_station => -- VOORBEELD VOOR FORWARD_STATION COMMANDO. 
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override_vector <= "1000"; -- moet iets zijn
			translator_out_reset <= '0';
			override_cont_new_state <= left_station;
 
			case station_state is
 
				when first => -- Lijnvolgen
					override <= '0';
 
					if (sensor_l = '0' or sensor_m = '0' or sensor_r = '0') then --lijnvolgen zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
						new_station_state <= first;
					else
						new_station_state <= second;
					end if;
 
				when second => --Bocht maken als hij aan het einde van de lijn is. Dan geldt: sensor_l ='1' (wit). Dan 180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
					override <= '1';
					override_vector <= "0100"; -- drive_motor_fastright.
 
					if (sensor_l = '1') then
						new_station_state <= second;
					else
						new_station_state <= third;
					end if;
 
				when third => 
					distance_count_reset <= '0'; -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand. Hij moet hier weer een signaal sturen naar de pc dat hij het volgende commando wil.
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
 
				when others => -- zelfde als Third
					distance_count_reset <= '0';
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
			end case;
 

		when right_station => 
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override_vector <= "1000"; -- moet iets zijn
			translator_out_reset <= '0';
			override_cont_new_state <= right_station;
 
			case station_state is
 				when first => -- Gewoon de bocht naar rechts (gekopierd)
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0100"; -- harde bocht naar rechts
					override_cont_new_state <= right_station;
					translator_out_reset <= '0';
			
					if (unsigned(pwm_count_out) < 3) then
						new_station_state <= first;
					else
						new_station_state <= second;
					end if;
				
				when second => --lijnvolgen (override = '0') zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
					override <= '0';
					if (sensor_l = '0' or sensor_m = '0' or sensor_r = '0') then 
						new_station_state <= second;
					else
						new_station_state <= third;
					end if;
 
				when third => --Bocht maken als hij aan het einde van de lijn is. Dan geldt: sensor_l ='1' (wit). Dan 180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
					override <= '1';
					override_vector <= "0100"; -- drive_motor_fastright.
					if (sensor_l = '1') then
						new_station_state <= third;
					else
						new_station_state <= fourth;
					end if;
 
				when fourth => -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand. Hij moet hier weer een signaal sturen naar de pc dat hij het volgende commando wil.
					distance_count_reset <= '0'; -- In het geval dat de robot een station bezocht heeft hoeft hij niet de distance counter te resetten, omdat hij geen zwarte stip meer tegen zal komen.
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
			end case;

		when others => 
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override <= '0';
			override_vector <= "0000";-- moet iets zijn
			override_cont_new_state <= read_sensor_and_listen;
			translator_out_reset <= '0';
	end case;
end process;


---------------- Counter van PWM perioden (20 ms). Wordt gebruikt voor bochten van een bepaalde lengte. -------
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

pwm_count_out <= std_logic_vector(pwm_count);
----------------------------------------------------------------------------------------------------------------


--------------- Counter van PWM perioden,  maar dan voor de afstandsmeting.------------------
process (count_reset, distance_count_reset, reset, clk)
begin
	if (reset = '1' or distance_count_reset = '1') then
		distance_count <= (others => '0');
	elsif (rising_edge(count_reset)) then
		distance_count <= new_distance_count;
	end if;

end process;

process (distance_count)

begin
	new_distance_count <= distance_count + 1;
end process;
------------------------------------------------------------------------------------------------


end architecture behavioural;