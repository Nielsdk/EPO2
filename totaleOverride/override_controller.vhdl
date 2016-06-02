LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY override_controller IS
	PORT (
		clk, reset            : IN std_logic;
		translator_out        : IN std_logic_vector(7 DOWNTO 0);
		override_vector       : OUT std_logic_vector(3 DOWNTO 0);
		override              : OUT std_logic;
		translator_out_reset  : OUT std_logic;
		count_reset           : IN std_logic;
		sensor_l              : IN std_logic;
		sensor_m              : IN std_logic;
		sensor_r              : IN std_logic;
		tx_out, tx_send_out   : OUT std_logic
	);
END ENTITY override_controller;

ARCHITECTURE behavioural OF override_controller IS
	-- TYPES
	TYPE override_controller_states IS ( -- Mogelijkheden override controller
	read_sensor_and_listen,
	forward, backward, stop,
       	right90, right, fastright, 
	left90, left, fastleft, 
	forward_station, left_station, right_station);
	TYPE station_state_type IS ( -- States gebruikt binnen de logica van de *_station staten van de override_controller_states.
	first, second, third, fourth, fifth);
	TYPE tx_state IS ( -- States gebruikt bij de transmitter
	tx_idle, tx_wait, tx_send); 

	-- CONSTANTES
	CONSTANT OPERATION_DISTANCE: INTEGER := 140; -- Minimum aantal PWM pulsen die gepasseerd moeten zijn sinds het uitvoeren van de vorige mogelijkheid van de override controller
	CONSTANT FORWARD_PWM_COUNT: INTEGER := 30; -- Aantal PWM pulsen dat die in de staten forward, left, en right moet doorbrengen
	CONSTANT LEFT_PWM_COUNT: INTEGER := 40;
	CONSTANT RIGHT_PWM_COUNT: INTEGER := 40;


	-- SIGNAL
	SIGNAL station_state, new_station_state : station_state_type; -- Geheugenelementen voor het bepalen van de volgende station_state
	SIGNAL override_cont_state, override_cont_new_state : override_controller_states; -- Geheugenelementen voor het bepalen van de volgende station_state
	SIGNAL tx_state_reg, tx_state_next : tx_state; -- Geheugenelementen voor het bepalen van de volgende station_state
	SIGNAL pwm_count, new_pwm_count, distance_count, new_distance_count : unsigned (9 DOWNTO 0); -- Geheugenelementen voor de pwm-tellers voor de bochten en voor de afstand lijnengevolgd
	SIGNAL pwm_count_out : std_logic_vector (10 DOWNTO 0);
	SIGNAL pwm_count_reset, distance_count_reset : std_logic; -- Resets voor de pwm-tellers.
BEGIN

PROCESS (clk, reset) -- Check op rising edge en op resets
BEGIN
	IF (rising_edge(clk)) THEN 
		IF (reset = '1') THEN
			override_cont_state <= read_sensor_and_listen; -- Zet de states in de eerste staat
			station_state <= first;
			tx_state_reg <= tx_idle;
		ELSE
			override_cont_state <= override_cont_new_state; -- Ga naar de volgende staat op de rising edge
			station_state <= new_station_state;
			tx_state_reg <= tx_state_next;
		END IF;
	END IF;
END PROCESS;

PROCESS (clk, translator_out, sensor_l, sensor_m, sensor_r, override_cont_state, pwm_count, distance_count, pwm_count_out, station_state) -- Gedrag van specefieke handelingen
BEGIN
	new_station_state <= station_state; -- Moet een waarde hebben

	CASE override_cont_state IS 
		WHEN read_sensor_and_listen => 	-- In deze staat zal hij lijnvolgen (dwz, overide = 0) totdat een bepaalde afstand is overschreden
		       				-- EN de sensoren allemaal zwart zijn (Bij een kruispunt!)
			translator_out_reset <= '0'; -- Houdt de uitgang op de translator out
			distance_count_reset <= '0'; -- De distance-teller telt gewoon door
			override_vector <= "0000"; -- Stel hij override de controller hier, dan zet hij de robot stil.
			new_station_state <= first; -- Eerste staat in de station FSM, (als het ware een reset van de FSM)

			IF (sensor_l = '0' AND sensor_m = '0' AND sensor_r = '0' AND distance_count > OPERATION_DISTANCE) THEN -- neem de lijnvolger over. 
				override <= '1'; -- TAKE ME OVER
				pwm_count_reset <= '1'; -- Hij komt in de override stand en mag beginnen met tellen van het aantal pwm perioden. Deze teller is voor de bochten.
				CASE translator_out IS -- Afhankelijk van het ingekomen signaal van C wordt er hier gekozen uit de juiste bocht.
					WHEN "10000000" => override_cont_new_state <= stop; -- Standaard coderingen 
					WHEN "10000001" => override_cont_new_state <= forward;
					WHEN "10000010" => override_cont_new_state <= right;
					WHEN "10000100" => override_cont_new_state <= left;
					WHEN "10001000" => override_cont_new_state <= backward;
					WHEN "11000001" => override_cont_new_state <= forward_station;
					WHEN "11000010" => override_cont_new_state <= right_station; --OMGEDRAAID MET LEFT_STATION!!!!!!!!!
					WHEN "11000100" => override_cont_new_state <= left_station;
					WHEN OTHERS => override_cont_new_state <= read_sensor_and_listen; -- Errorcontrole op verkeerd signaal
				END CASE;
			ELSE
				override <= '0';
				pwm_count_reset <= '0'; -- pwm_count is een counter die telt per 20 ms. Zo is het aantal pwm pulsen te tellen.
				override_cont_new_state <= read_sensor_and_listen;
			END IF;

	-- Dit zijn de staten voor de verschillende bochten: rechtdoor, links en rechts bij een kruising.
	-- Er zijn ook staten voor een bocht naar een station, hier zal de staat ook de bocht aan het einde van de weg maken.
	-- Aan het einde van de actie komt de override_controller weer in zijn read_sensor_and_listen staat.


		WHEN forward => --Een korte periode vooruit rijden en daarna weer over op lijnvolgen.
			CASE station_state IS  
				WHEN first =>
					distance_count_reset <= '0'; -- Reset de beide tellers niet
					pwm_count_reset <= '0';
					override <= '0'; -- Gewoon lijnvolgen, hij zal automatisch recht door rijden!
					override_vector <= "0001"; -- vooruit
					override_cont_new_state <= forward; -- Ga naar de volgende staat
					translator_out_reset <= '0'; -- 
					IF (unsigned(pwm_count_out) < FORWARD_PWM_COUNT) THEN -- Zie lijst met constantes
						new_station_state <= first; -- Blijf in dezelfde staat als hij nog niet lang genoeg rechtdoor heeft gereden
					ELSE
						new_station_state <= second; -- Ga naar de volgende staat
					END IF;
				WHEN OTHERS => --second and others.
					distance_count_reset <= '1'; -- Reset de gereden afstand staat
					pwm_count_reset <= '1'; -- Reset de counter voor de handelingen
					override <= '0'; -- Lijnvolgen
					override_vector <= "0000";-- Moet iets zijn, dont care
					override_cont_new_state <= read_sensor_and_listen; -- Ga naar de begin staat
					translator_out_reset <= '1'; -- Reset de output
			END CASE;
			
		WHEN left => -- Voor een bepaalde tijd een bocht naar links maken en daarna weer lijnvolgen.
			CASE station_state IS
				WHEN first =>
					distance_count_reset <= '0'; -- OPM: Dit wordt wel vaker gedaan. Distance_count_reset wordt wel vaker niet gereset ookal wordt die niet gebruikt
					pwm_count_reset <= '0';	     -- Is hier een speciale reden voor?
					override <= '1';
					override_vector <= "0111"; -- harde bocht naar links 0111 -- zachte bocht naar links: 0101
					override_cont_new_state <= left; 
					translator_out_reset <= '0';
					IF (unsigned(pwm_count_out) < LEFT_PWM_COUNT) THEN
						new_station_state <= first; -- Blijf in dezelfde staat
					ELSE
						new_station_state <= second; -- Ga naar de volgende
					END IF;
				WHEN second => -- Zolang beide sensoren nog niet zwart zijn rechtdoor rijden. 
					distance_count_reset <= '0'; 
					pwm_count_reset <= '0';	    
					override <= '1';
					override_vector <= "0001"; -- rechtdoor
					override_cont_new_state <= left; 
					translator_out_reset <= '0';
					if(NOT(sensor_r = '0' AND sensor_m = '0')) then 
						new_station_state <= second;
					else
						new_station_state <= third;
					end if;
					
				WHEN OTHERS => --second and others.
					distance_count_reset <= '1'; -- Reset de gereden distance, deze hebben we zo weer nodig
					pwm_count_reset <= '1'; -- Reset de handelings pwm-teller
					override <= '0'; -- Lijnvolen
					override_vector <= "0000";-- moet iets zijn
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
			END CASE;

		WHEN right => -- Voor een bepaalde periode een bocht naar rechts maken en dan weer lijnvolgen.
			CASE station_state IS
				WHEN first =>
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0100"; -- harde bocht naar rechts
					override_cont_new_state <= right;
					translator_out_reset <= '0';
					IF (unsigned(pwm_count_out) < RIGHT_PWM_COUNT) THEN
						new_station_state <= first;
					ELSE
						new_station_state <= second;
					END IF;
					
				WHEN second => -- Zolang beide sensoren nog niet zwart zijn rechtdoor rijden. 
					distance_count_reset <= '0'; 
					pwm_count_reset <= '0';	    
					override <= '1';
					override_vector <= "0001"; -- rechtdoor
					override_cont_new_state <= right; 
					translator_out_reset <= '0';
					if(NOT(sensor_l = '0' AND sensor_m = '0')) then 
						new_station_state <= second;
					else
						new_station_state <= third;
					end if;	
				
				WHEN OTHERS => --second and others.
					distance_count_reset <= '1';
					pwm_count_reset <= '1';
					override <= '0';
					override_vector <= "0000";-- moet iets zijn
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
			END CASE;
			
		WHEN backward => -- Deze staat is nog niet functioneel
			IF (unsigned(pwm_count_out) < 50) THEN
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "1000";
				override_cont_new_state <= backward;
				translator_out_reset <= '0';
			ELSE
				distance_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			END IF;

		WHEN stop =>
			IF (unsigned(pwm_count_out) < 2) THEN
				distance_count_reset <= '0';
				pwm_count_reset <= '0';
				override <= '1';
				override_vector <= "0000";
				override_cont_new_state <= stop;
				translator_out_reset <= '0';
			ELSE
				distance_count_reset <= '1';
				pwm_count_reset <= '1';
				override <= '0';
				override_vector <= "0000";-- moet iets zijn
				override_cont_new_state <= read_sensor_and_listen;
				translator_out_reset <= '1';
			END IF;


		WHEN left_station => 
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override_vector <= "1000"; -- moet iets zijn
			translator_out_reset <= '0';
			override_cont_new_state <= left_station;
			CASE station_state IS
				WHEN first => -- Gewoon de bocht naar links(gekopierd)
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0111"; -- harde bocht naar links
					override_cont_new_state <= left_station;
					translator_out_reset <= '0';
					IF (unsigned(pwm_count_out) < LEFT_PWM_COUNT) THEN
						new_station_state <= first;
					ELSE
						new_station_state <= second;
					END IF;
				WHEN second => -- De lijn terugvinden.
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0001"; -- Rechtdoor
					override_cont_new_state <= left_station;
					translator_out_reset <= '0';
					IF (sensor_r = '0' AND sensor_m = '0') THEN
						new_station_state <= THIRD;
					ELSE
						new_station_state <= second;
					END IF;
				
				WHEN third => --lijnvolgen (override = '0') zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
					override <= '0';
					IF (sensor_l = '0' OR sensor_m = '0' OR sensor_r = '0') THEN
						new_station_state <= third;
					ELSE
						new_station_state <= fourth;
					END IF;
				WHEN fourth => --Bocht maken als hij aan het einde van de lijn is. Dan geldt: sensor_l ='1' (wit). Dan 180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
					override <= '1';
					override_vector <= "0100"; -- drive_motor_fastright.
					IF (sensor_l = '1') THEN
						new_station_state <= fourth;
					ELSE
						new_station_state <= fifth;
					END IF;
				WHEN fifth => -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand.
					distance_count_reset <= '0'; -- In het geval dat de robot een station bezocht heeft hoeft hij niet de distance counter te resetten, omdat hij geen zwarte stip meer tegen zal komen.
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
			END CASE;

		WHEN forward_station => -- VOORBEELD VOOR FORWARD_STATION COMMANDO.
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override_vector <= "1000"; -- moet iets zijn
			translator_out_reset <= '0';
			override_cont_new_state <= forward_station;
			CASE station_state IS
				WHEN first => -- Lijnvolgen
					override <= '0';
					IF (sensor_l = '0' OR sensor_m = '0' OR sensor_r = '0') THEN --lijnvolgen zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
						new_station_state <= first;
					ELSE
						new_station_state <= second;
					END IF;
				WHEN second => --Bocht maken als hij aan het einde van de lijn is. Dan geldt: sensor_l ='1' (wit). Dan 180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
					override <= '1';
					override_vector <= "0100"; -- drive_motor_fastright.
					IF (sensor_l = '1') THEN
						new_station_state <= second;
					ELSE
						new_station_state <= third;
					END IF;
				WHEN third =>
					distance_count_reset <= '0'; -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand. Hij moet hier weer een signaal sturen naar de pc dat hij het volgende commando wil.
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
				WHEN OTHERS => -- zelfde als Third
					distance_count_reset <= '0';
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
			END CASE;

		WHEN right_station =>
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override_vector <= "1000"; -- moet iets zijn
			translator_out_reset <= '0';
			override_cont_new_state <= right_station;
			CASE station_state IS
				WHEN first => -- Gewoon de bocht naar rechts (gekopierd)
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0100"; -- harde bocht naar rechts
					override_cont_new_state <= right_station;
					translator_out_reset <= '0';
					IF (unsigned(pwm_count_out) < RIGHT_PWM_COUNT) THEN
						new_station_state <= first;
					ELSE
						new_station_state <= second;
					END IF;
				WHEN second =>
					distance_count_reset <= '0';
					pwm_count_reset <= '0';
					override <= '1';
					override_vector <= "0001"; -- Vooruit
					override_cont_new_state <= right_station;
					translator_out_reset <= '0';
					IF (sensor_l = '0' AND sensor_m = '0') THEN
						new_station_state <= THIRD;
					ELSE
						new_station_state <= second;
					END IF;
				
				WHEN third => --lijnvolgen (override = '0') zolang in ieder geval 1 van de sensoren een lijn ziet. Zo rijd hij tot het einde van de lijn (waar ze alle drie wit (='1') worden)
					override <= '0';
					IF (sensor_l = '0' OR sensor_m = '0' OR sensor_r = '0') THEN
						new_station_state <= third;
					ELSE
						new_station_state <= fourth;
					END IF;
				WHEN fourth => --Bocht maken als hij aan het einde van de lijn is. Dan geldt: sensor_l ='1' (wit). Dan 180 graden RECHTSOM draaien. De linker sensor zal als laatste weer zwart worden. Dan verder naar de volgende stap.
					override <= '1';
					override_vector <= "0100"; -- drive_motor_fastright.
					IF (sensor_l = '1') THEN
						new_station_state <= fourth;
					ELSE
						new_station_state <= fifth;
					END IF;
				WHEN fifth => -- De robot is klaar om weer lijn te volgen, hij verlaat de override stand.
					distance_count_reset <= '0'; -- In het geval dat de robot een station bezocht heeft hoeft hij niet de distance counter te resetten, omdat hij geen zwarte stip meer tegen zal komen.
					pwm_count_reset <= '1';
					override <= '0';
					override_cont_new_state <= read_sensor_and_listen;
					translator_out_reset <= '1';
					new_station_state <= first;
			END CASE;
			

		WHEN OTHERS =>
			distance_count_reset <= '0';
			pwm_count_reset <= '0';
			override <= '0';
			override_vector <= "0000";-- moet iets zijn
			override_cont_new_state <= read_sensor_and_listen;
			translator_out_reset <= '0';
	END CASE;
END PROCESS;


-- Counter van PWM perioden (20 ms). Wordt gebruikt voor bochten van een bepaalde lengte 
PROCESS (count_reset, pwm_count_reset, reset, clk)
BEGIN
	IF (reset = '1' OR pwm_count_reset = '1') THEN
		pwm_count <= (OTHERS => '0');
	ELSIF (rising_edge(count_reset)) THEN
		pwm_count <= new_pwm_count;
	END IF;
END PROCESS;

PROCESS (pwm_count)
BEGIN
	new_pwm_count <= pwm_count + 1;
END PROCESS;
pwm_count_out <= std_logic_vector(pwm_count);


-- Counter van PWM perioden, maar dan voor de afstandsmeting (Het stukje tussen de twee stations)
PROCESS (count_reset, distance_count_reset, reset, clk)
BEGIN
	IF (reset = '1') THEN
		distance_count <= "0010010110"; -- Bij een reset doet de distance counter er niet toe, hij begint dan namelijk bij een station.
	ELSIF (distance_count_reset = '1') THEN
		distance_count <= (OTHERS => '0');
	ELSIF (rising_edge(count_reset)) THEN
		distance_count <= new_distance_count;
	END IF;
END PROCESS;

PROCESS (distance_count)
BEGIN
	new_distance_count <= distance_count + 1;
END PROCESS;


-- tx signalen. Zal versturen op het kruisen van de stip tussen de kruispunten, of bij het verschijnen in een *_station staat
PROCESS (clk, sensor_l, sensor_r, sensor_m, distance_count)
BEGIN
	tx_state_next <= tx_state_reg;
	tx_send_out <= '0';
	CASE(tx_state_reg) IS
	WHEN tx_idle =>
	IF (override_cont_state = forward_station OR override_cont_state = right_station OR override_cont_state = left_station) THEN
		tx_state_next <= tx_send;
	ELSIF (sensor_l = '0' AND sensor_m = '0' AND sensor_r = '0' AND distance_count < OPERATION_DISTANCE) THEN
		tx_state_next <= tx_wait;
	END IF;
	WHEN tx_wait =>
	IF (NOT(sensor_l = '0' AND sensor_m = '0' AND sensor_r = '0')) THEN
		tx_state_next <= tx_send;
	END IF;
	WHEN tx_send =>
	tx_out <= '0';
	tx_send_out <= '1';
	IF (NOT(override_cont_state = forward_station OR override_cont_state = right_station OR override_cont_state = left_station)) THEN
		tx_state_next <= tx_idle;
	END IF;
END CASE;
END PROCESS;

END ARCHITECTURE behavioural;
