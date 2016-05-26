library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is 
end entity tb;

architecture uart_bench of tb is
	component uart is
	port (
		clk, reset: in std_logic;
		rx: in std_logic; --input bit stream
		tx: out std_logic; --output bit stream
		uart_in: in std_logic_vector(7 downto 0); --byte to be sent
		uart_out: out std_logic_vector(7 downto 0); --received byte
		write_data: in std_logic; --write to transmitter buffer 
		read_data: in std_logic; --read from receiver buffer 
		receiver_flag: out std_logic
		);
	end component uart;
	component rx_translator is
	port (	receiver_in	: in std_logic_vector(7 downto 0); -- input van de receiver
		flag_in		: in std_logic; -- weergeeft of er een nieuw signaal wacht om gelezen te worden
 	       	clk, reset	: in std_logic; -- Vanzelfsprekend 
		flag_reset	: out std_logic; -- als het nieuwe signaal gelezen is, stel de flag op '0'.
		translator_out	: out std_logic_vector(3 downto 0); -- output, vertaald volgens bovenstaand protocol
		receiver_check	: out std_logic_vector(7 downto 0); -- Stuur de gelezen input naar de transmitter
		send_check	: out std_logic; -- Zorg dat die daadwerkelijk stuurt!
		translator_out_reset : in std_logic
		);
	end component rx_translator;

	signal	clk		: std_logic;
       	signal	reset		: std_logic;
	signal	rx		: std_logic; --input bit stream
	signal	tx		: std_logic; --output bit stream
	signal	uart_in		: std_logic_vector(7 downto 0); --byte to be sent
	signal	uart_out	: std_logic_vector(7 downto 0); --received byte
	signal	write_data	: std_logic; --write to transmitter buffer 
	signal	read_data	: std_logic; --read from receiver buffers
	signal	receiver_flag	: std_logic;
	signal  translator_out	: std_logic_vector(3 downto 0);
	signal	reset_translator: std_logic;
	

begin

C00:	uart 	port map (	clk		=>	clk,
				reset		=>	reset,
				rx		=>	rx,
				tx		=>	tx,
				uart_in		=>	uart_in,
				uart_out	=>	uart_out,
				write_data	=>	write_data,
				read_data	=>	read_data,
				receiver_flag 	=>	receiver_flag
			);
C01:	rx_translator port map (receiver_in	=> uart_out,
	       			flag_in		=> receiver_flag,
				clk		=> clk,
				translator_out_reset => reset_translator,
				reset		=> reset, 
				flag_reset	=> read_data,
				translator_out	=> translator_out,
				receiver_check	=> uart_in,
				send_check	=> write_data
			);

KLK:	clk		<=	'1' after 0 ns,
	       			'0' after 10 ns when clk /= '0' else '1' after 10 ns;
rst:	reset		<=	'1' after 0 ns,
			 	'0' after 100 ns;
s1:	rx		<=	'1' after 0 ns,
				'1' after 50 ns, 
				'0' after 104317 ns, -- start
				'1' after 208584 ns,
				'0' after 312851 ns,
				'0' after 417118 ns,
				'0' after 521385 ns,
				'0' after 625652 ns,
				'0' after 729919 ns,
				'0' after 834186 ns,
				'0' after 938453 ns,
			        '1' after 1042720 ns;	
s2:	reset_translator  <=	'0' after 0 ns,
			   	'1' after 1400001 ns,
				'0' after 1400030 ns;
end architecture uart_bench;
