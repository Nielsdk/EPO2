library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
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
end uart;

architecture st of uart is
-- Component declarations
component uart_rx is
   port(
      clk, reset: in std_logic;
      rx: in std_logic; -- icoming serial bit stream
      s_tick: in std_logic; -- sampling tick from baud rate generator
      rx_done_tick: out std_logic; -- data frame completion tick
      dout: out std_logic_vector(7 downto 0) -- data byte
   );
end component uart_rx;
component uart_tx is
   port(
      clk, reset: in std_logic;
      tx_start: in std_logic; -- if '1' transmission starts
      s_tick: in std_logic; -- sampling tick from baud rate generator
      din: in std_logic_vector(7 downto 0); -- incoming data byte
      tx_done_tick: out std_logic; -- data frame completion tick 
      tx: out std_logic -- outcoming bit stream
   );
end component uart_tx ;
component buf_reg is
   port(
      clk, reset: in std_logic;
      clr_flag, set_flag: in std_logic; 
      din: in std_logic_vector(7 downto 0);
      dout: out std_logic_vector(7 downto 0);
      flag: out std_logic
   );
end component buf_reg;
component baud_gen is
   generic( 
	M: integer := 326
	);
   port(
      clk, reset: in std_logic;
      s_tick: out std_logic -- sampling tick
   );
end component baud_gen;
--==========================================
--# Signal Declaration
--==========================================
signal s_tick		:	std_logic;
signal rx_done_tick	:	std_logic;
signal tx_done_tick	:	std_logic;
signal d_buf_tx		:	std_logic_vector(7 downto 0);
signal d_rx_buf		:	std_logic_vector(7 downto 0);
signal flag_tx_start	:	std_logic;
signal sseg_enable	:	std_logic;
begin
--==========================================
--# Receiver port map
--==========================================
L00:	uart_rx		port map (	clk		=>	clk,
					reset		=>	reset,
					rx		=>	rx,
					s_tick		=>	s_tick,
					rx_done_tick	=>	rx_done_tick,
					dout		=>	d_rx_buf
				);	
--==========================================
--# Transmitter port map
--==========================================
L01:	uart_tx		port map (	clk		=>	clk,
					reset		=>	reset,
					tx		=>	tx,
					tx_start	=>	flag_tx_start,
					tx_done_tick	=>	tx_done_tick,
					s_tick		=>	s_tick,
					din		=>	d_buf_tx
				);

--==========================================
--# Baud gen @ 9600
--==========================================
L02:	baud_gen	port map (	clk		=>	clk,
					reset		=>	reset,
					s_tick		=>	s_tick
				);
--==========================================
--# Buffer register for Receiver
--# Flag vastgemaakt aan display via tussensignal
--==========================================
L03:	buf_reg		port map (	clk		=>	clk,
					reset		=>	reset,
					clr_flag	=>	read_data,
					set_flag	=>	rx_done_tick,
					din		=>	d_rx_buf,
					dout		=>	uart_out,
					flag		=>	receiver_flag
				);
-- L03a:	sseg(6)	<= sseg_enable;
-- L03b:	sseg(3) <= sseg_enable;
-- L03c:	an(0)	<= sseg_enable;
--==========================================
--# Buffer register for Transmitter
--==========================================
L04:	buf_reg		port map (	clk		=>	clk,
					reset		=>	reset,
					clr_flag	=>	tx_done_tick,
					set_flag	=>	write_data,
					din		=>	uart_in,
					dout		=>	d_buf_tx,
					flag		=>	flag_tx_start
				);
end architecture st;

	
