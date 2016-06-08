LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb IS
END ENTITY tb;

ARCHITECTURE systeem_tb OF tb IS
	-- Constantes
	CONSTANT reset_time : time := 50 ns;
	CONSTANT clk_time : time := 20 ns;

	-- Procedures gebruikt bij de simulatie!
	-- Gebruik als volgt:
	-- Zie procedure rx_signal_feed: in de body (na 'begin') staan
	-- procedure calls naar rx_in.
	-- Om een nieuw signaal erbij te zetten, moet je het volgende erin 
	-- zetten: 'rx_in(rx, ...), waar ... je 8 bit signaal is!
	-- De statements worden sequentieel uitgevoerd (het is tenslotte een
	-- Procedure...)
	procedure rx_in(signal rx: out std_logic;
       			constant value : std_logic_vector(7 downto 0)) is
	constant delay : time := 104267 ns;
	begin
	rx <= '0'; -- Start bit
	wait for delay;
	for I in 0 to 7 loop 
		rx <= value(I);
		wait for delay;
	end loop;
	rx <= '1'; -- Stop bit
	wait for delay;
	end procedure rx_in;
	procedure rx_signal_feed(signal rx: out std_logic;
       			constant reset_time : time) is
	begin
	rx <= '1'; -- Stand by modus
	wait for reset_time;
	-- Zet hier je signalen
	-- Een kort overzicht van de mogelijkheden:
	-- 10000000	Stop met rijden
	-- 10000001	Vooruit rijden
	-- 10000010	Rechtsaf en rijden
	-- 10000100	Linksaf en rijden
	-- 10001000	Achteruit rijden
	-- 11000001	Vooruit rijden tot aan het station
	-- 11000010	Rechtsaf en rijden tot aan het station
	-- 11000100	Linksaf en rijden tot aan het station
	-- 11001000	Achteruit rijden tot aan het station
	rx_in(rx, "10000100"); --links
	wait for 30 ms;
	rx_in(rx, "11000100"); --links station
	wait for 70 ms;
	rx_in(rx, "10000010"); -- rechts
	end procedure rx_signal_feed;

	-- Eveneens als de vorige, kan je deze als volgt gebruiken:
	-- Zet bij 'sensors_signal_feed' in de body een sensors_in met de
	-- parameters zoals ze er in het voorbeeld staan, met de 8 bit vector
	-- Naar eigen keus...
	procedure sensors_in(signal sensor_l : out std_logic; 
			     signal sensor_m : out std_logic; 
			     signal sensor_r : out std_logic; 
		constant value : std_logic_vector( 2 downto 0)) is
	begin
	sensor_l <= value(2);
	sensor_m <= value(1);
	sensor_r <= value(0);
	end procedure sensors_in;
	procedure sensors_signal_feed(signal sensor_l, sensor_m, sensor_r : out std_logic) is
	begin
		-- Zet hier je signalen
		sensors_in(sensor_l, sensor_m, sensor_r, "101");
		wait for 10 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "000");
		wait for 15 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "110");
		wait for 20 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "010");
		wait for 10 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "000");
		wait for 50 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "111");
		wait for 25 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "011");
		wait for 25 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "000");
		wait for 5 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "111");
		wait for 25 ms;
		sensors_in(sensor_l, sensor_m, sensor_r, "100");
	end procedure sensors_signal_feed;

	-- Systeem importeren
	COMPONENT systeem IS
		PORT (
			TL_rx        : IN std_logic;
			TL_tx        : OUT std_logic;
			TL_clk       : IN std_logic;
			TL_reset     : IN std_logic;
			TL_sensor_l  : IN std_logic;
			TL_sensor_m  : IN std_logic;
			TL_sensor_r  : IN std_logic;
			TL_motor_l   : OUT std_logic;
			TL_motor_r   : OUT std_logic
		);
	END COMPONENT systeem;
 
	-- Relevante signalen
	SIGNAL clk : std_logic;
	SIGNAL reset : std_logic;
	SIGNAL rx : std_logic; --input bit stream
	SIGNAL tx : std_logic; --output bit stream
	SIGNAL sensor_l, sensor_r, sensor_m : std_logic;
	SIGNAL motor_l, motor_r : std_logic;
BEGIN
	rx_signal_feed(rx, RESET_TIME);
	sensors_signal_feed(sensor_l, sensor_m, sensor_r);

	C00 : systeem
	PORT MAP(
	TL_clk => clk, -- IN 
	TL_reset => reset, -- IN
	TL_rx => rx, -- IN
	TL_tx => tx, 
	TL_sensor_l => sensor_l, -- IN 
	TL_sensor_m => sensor_m, -- IN
	TL_sensor_r => sensor_r, -- IN
	TL_motor_l => motor_l, 
	TL_motor_r => motor_r
	);

	S03 : clk <= '1' AFTER 0 ns, 
		'0' AFTER (CLK_TIME / 2) WHEN clk /= '0' ELSE '1' AFTER (CLK_TIME / 2);

	S04 : reset <= '1' AFTER 0 ns, 
		'0' AFTER RESET_TIME;

END ARCHITECTURE systeem_tb;

