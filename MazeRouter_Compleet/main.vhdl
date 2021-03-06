LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY systeem IS
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
END ENTITY systeem;

ARCHITECTURE structural OF systeem IS
	COMPONENT timebase IS
		PORT (
			clk          : IN std_logic;
			reset        : IN std_logic;
			count_reset  : IN std_logic;
			count_out    : OUT std_logic_vector (19 DOWNTO 0)
		);
	END COMPONENT timebase;
	COMPONENT motorcontrol IS
		PORT (
			clk        : IN std_logic;
			reset      : IN std_logic;
			direction  : IN std_logic;
			count_in   : IN std_logic_vector (19 DOWNTO 0);
			speed      : IN std_logic;
			pwm        : OUT std_logic
		);
	END COMPONENT motorcontrol;
	COMPONENT inputbuffer IS
		PORT (
			clk           : IN std_logic;
			reset         : IN std_logic;
			sensor_l_in   : IN std_logic;
			sensor_m_in   : IN std_logic;
			sensor_r_in   : IN std_logic;

			sensor_l_out  : OUT std_logic;
			sensor_m_out  : OUT std_logic;
			sensor_r_out  : OUT std_logic
		);
	END COMPONENT inputbuffer;
	COMPONENT override_controller IS
	port(
	clk : in std_logic;
	reset : in std_logic;
	translator_out : in std_logic_vector(7 downto 0);
	override_vector : out std_logic_vector(3 downto 0);
	override : out std_logic;
	translator_out_reset : out std_logic;
	count_reset : in std_logic;
	sensor_l           : in std_logic;
	sensor_m           : in std_logic;
	sensor_r           : in std_logic;
	tx_out : OUT std_logic_vector(7 downto 0);
       	tx_send_out : OUT std_logic
	);
	END COMPONENT override_controller;
	COMPONENT uart IS
		PORT (
			clk, reset     : IN std_logic;
			rx             : IN std_logic;
			tx             : OUT std_logic; 
			uart_in        : IN std_logic_vector(7 DOWNTO 0); 
			uart_out       : OUT std_logic_vector(7 DOWNTO 0); 
			write_data     : IN std_logic; 
			read_data      : IN std_logic; 
			receiver_flag  : OUT std_logic
		);
	END COMPONENT uart;
	COMPONENT rx_translator IS
		GENERIC (HANDSHAKE : INTEGER := 0); -- '1' = TRUE, '0' = FALSE 
		PORT (
			receiver_in           : IN std_logic_vector(7 DOWNTO 0); 
			flag_in               : IN std_logic; 
			clk, reset            : IN std_logic;
			translator_out_reset  : IN std_logic;
			flag_reset            : OUT std_logic;

			translator_out        : OUT std_logic_vector(7 DOWNTO 0); 

			receiver_check        : OUT std_logic_vector(7 DOWNTO 0);
			send_check            : OUT std_logic 
		);
	END COMPONENT rx_translator;
	COMPONENT controller IS
		PORT (
			clk                : IN std_logic;
			reset              : IN std_logic;

			sensor_l           : IN std_logic;
			sensor_m           : IN std_logic;
			sensor_r           : IN std_logic;

			count_in           : IN std_logic_vector (19 DOWNTO 0);
			override_vector    : IN std_logic_vector (3 DOWNTO 0);
			override           : IN std_logic;

			count_reset        : OUT std_logic;

			motor_l_reset      : OUT std_logic;
			motor_l_direction  : OUT std_logic;
			motor_l_speed      : OUT std_logic;

			motor_r_reset      : OUT std_logic;
			motor_r_direction  : OUT std_logic;
			motor_r_speed      : OUT std_logic


		);
	END COMPONENT controller;
--	component tx_translator is
--	port(	clk, reset : in std_logic;
--	      	control : in std_logic;
--		new_control : in std_logic;
--		--flag : in std_logic;
--		translator_out : out std_logic_vector(7 downto 0);
--		send : out std_logic
--	);
--	end component tx_translator;


	-- Signalen uit inputbuffer
	SIGNAL TL_sensor_l_buff : std_logic; -- Linker gebufferd sensorsignaal
	SIGNAL TL_sensor_m_buff : std_logic; -- Middelste gebufferd sensorsignaal
	SIGNAL TL_sensor_r_buff : std_logic; -- Rechter gebufferd sensorsignaal
	-- Signalen uit controller
	SIGNAL TL_override : std_logic; -- Override de controller zodat er geen lijnen meer gevolgd worden
	SIGNAL TL_override_vector : std_logic_vector(3 DOWNTO 0); -- Signaal van de override naar de controller
	SIGNAL TL_motor_l_reset : std_logic; -- Reset van de linker motor
	SIGNAL TL_motor_l_direction : std_logic; -- Richting van de linker motor
	SIGNAL TL_motor_l_speed : std_logic; -- Snelheid van de linker motor
	SIGNAL TL_motor_r_reset : std_logic; -- Reset van de linker motor
	SIGNAL TL_motor_r_direction : std_logic; -- Richting van de linker motor
	SIGNAL TL_motor_r_speed : std_logic; -- Snelheid van de linker motor
	-- Signalen uit de timebase
	SIGNAL TL_count_reset : std_logic; -- Reset van 'TL_count'
	SIGNAL TL_count : std_logic_vector(19 DOWNTO 0); -- Output van de timebase
	-- Signalen uit de UART
	SIGNAL TL_uart_in : std_logic_vector(7 DOWNTO 0); -- Ingang van de uart
	SIGNAL TL_uart_out : std_logic_vector(7 DOWNTO 0); -- Uitgang van de uart
	SIGNAL TL_signal_flag : std_logic; -- Signaal die weergeeft of er een nieuw signaal is
	SIGNAL TL_uart_read : std_logic; -- Lees uart_out
	SIGNAL TL_uart_write : std_logic; -- Schrijf uart_in
	-- Signalen uit de receiver vertaler
	SIGNAL TL_translator_out : std_logic_vector(7 DOWNTO 0); -- Output van de vertaler
	SIGNAL TL_translator_out_reset : std_logic; -- Reset van de vertaler
	-- Null signalen
	SIGNAL NULL_1 : std_logic_vector(7 downto 0);
	SIGNAL NULL_2 : std_logic;	
BEGIN
	C00 : inputbuffer
	PORT MAP(
	clk => TL_clk, 
	reset => TL_reset,
	sensor_l_in => TL_sensor_l, 
	sensor_m_in => TL_sensor_m, 
	sensor_r_in => TL_sensor_r, 
	sensor_l_out => TL_sensor_l_buff, 
	sensor_m_out => TL_sensor_m_buff, 
	sensor_r_out => TL_sensor_r_buff
	);

	C01 : controller
	PORT MAP(
	clk => TL_clk, 
	reset => TL_reset, 
	sensor_l => TL_sensor_l_buff, 
	sensor_m => TL_sensor_m_buff, 
	sensor_r => TL_sensor_r_buff, 
	count_in => TL_count, 
	count_reset => TL_count_reset, 
	motor_l_reset => TL_motor_l_reset, 
	motor_r_reset => TL_motor_r_reset, 
	motor_l_direction => TL_motor_l_direction, 
	motor_r_direction => TL_motor_r_direction, 
	motor_l_speed => TL_motor_l_speed, 
	motor_r_speed => TL_motor_r_speed, 
	override_vector => TL_override_vector, 
	override => TL_override
	);

	C02 : timebase
	PORT MAP(
	clk => TL_clk, 
	reset => TL_reset, 
	count_out => TL_count, 
	count_reset => TL_count_reset
	);

	C03 : motorcontrol -- RECHTS
	PORT MAP(
	clk => TL_clk, 
	reset => TL_motor_r_reset, 
	direction => TL_motor_r_direction, 
	count_in => TL_count, 
	pwm => TL_motor_r, 
	speed => TL_motor_r_speed
	);

	C04 : motorcontrol -- LINKS
	PORT MAP(
	clk => TL_clk, 
	reset => TL_motor_l_reset, 
	direction => TL_motor_l_direction, 
	count_in => TL_count, 
	pwm => TL_motor_l, 
	speed => TL_motor_l_speed
	);

	C05 : uart
	PORT MAP(
	clk => TL_clk, 
	reset => TL_reset, 
	rx => TL_rx, 
	tx => TL_tx, 
	uart_in => TL_uart_in, 
	uart_out => TL_uart_out, 
	write_data => TL_uart_write, 
	read_data => TL_uart_read, 
	receiver_flag => TL_signal_flag
	);

	C06 : rx_translator
	PORT MAP(
	receiver_in => TL_uart_out, 
	flag_in => TL_signal_flag, 
	clk => TL_clk, 
	translator_out_reset => TL_translator_out_reset, 
	reset => TL_reset, 
	flag_reset => TL_uart_read, 
	translator_out => TL_translator_out, 
	receiver_check => NULL_1,  -- Niet verbinden
	send_check => NULL_2 -- Niet verbinden
	);

	C07 : override_controller
	PORT MAP(
	clk => TL_clk, 
	reset => TL_reset, 
	translator_out => TL_translator_out, 
	translator_out_reset => TL_translator_out_reset, 
	override => TL_override, 
	override_vector => TL_override_vector,
	sensor_l => TL_sensor_l_buff, 
	sensor_m => TL_sensor_m_buff, 
	sensor_r => TL_sensor_r_buff,
	count_reset => TL_count_reset,
	tx_out => TL_uart_in,
	tx_send_out => TL_uart_write	
	);
	
END ARCHITECTURE structural;

