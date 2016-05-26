LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb IS
END ENTITY tb;

ARCHITECTURE systeem_tb OF tb IS
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
 
	SIGNAL clk : std_logic;
	SIGNAL reset : std_logic;
	SIGNAL rx : std_logic; --input bit stream
	SIGNAL tx : std_logic; --output bit stream
	SIGNAL sensor_l, sensor_r, sensor_m : std_logic;
	SIGNAL motor_l, motor_r : std_logic;
BEGIN
	C00 : systeem
	PORT MAP(
	TL_clk => clk, 
	TL_reset => reset, 
	TL_rx => rx, 
	TL_tx => tx, 
	TL_sensor_l => sensor_l, 
	TL_sensor_m => sensor_m, 
	TL_sensor_r => sensor_r, 
	TL_motor_l => motor_l, 
	TL_motor_r => motor_r
	);

	S00 : sensor_l <= '0'; -- Sensoren niet interessant
	S01 : sensor_r <= '0'; -- Sensoren niet interessant
	S02 : sensor_m <= '0'; -- Sensoren niet interessant

	S03 : clk <= '1' AFTER 0 ns, 
		'0' AFTER 10 ns WHEN clk /= '0' ELSE '1' AFTER 10 ns;

	S04 : reset <= '1' AFTER 0 ns, 
		'0' AFTER 100 ns;

	S05 : rx <= '1' AFTER 0 ns, 
		'1' AFTER 50 ns, -- IDLE
		'0' AFTER 104317 ns, -- Start bit
		'1' AFTER 208584 ns, -- LSB
		'0' AFTER 312851 ns, 
		'0' AFTER 417118 ns, 
		'0' AFTER 521385 ns, 
		'0' AFTER 625652 ns, 
		'0' AFTER 729919 ns, 
		'0' AFTER 834186 ns, 
		'0' AFTER 938453 ns, -- MSB
		'1' AFTER 1042720 ns; -- Stop bit 

END ARCHITECTURE systeem_tb;

