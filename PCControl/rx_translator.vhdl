library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rx_translator is
	generic ( HANDSHAKE : integer := 0);
	port (	receiver_in	: in std_logic_vector(7 downto 0); -- input van de receiver
		flag_in		: in std_logic; -- weergeeft of er een nieuw signaal wacht om gelezen te worden
 	       	clk, reset	: in std_logic; -- Vanzelfsprekend 
		translator_out_reset : in std_logic;
		flag_reset	: out std_logic; -- als het nieuwe signaal gelezen is, stel de flag op '0'.

		translator_out	: out std_logic_vector(3 downto 0); -- output, vertaald volgens bovenstaand protocol

		receiver_check	: out std_logic_vector(7 downto 0); -- Stuur de gelezen input naar de transmitter
		send_check	: out std_logic -- Zorg dat die daadwerkelijk stuurt!
		);
end entity rx_translator;

architecture bh of rx_translator is
	type state_type is (	idle, -- Wachten op signaal
				check, -- Controle of het wel goed is aangekomen
				forward, backward, stop,
				right90, right, fastright,
				left90, left, fastleft,
				reset_output
			);
	signal translator_reg, translator_next : std_logic_vector(3 downto 0);
	signal receiver_check_reg, receiver_check_next : std_logic_vector(7 downto 0);
	signal receiver_in_reg, receiver_in_next : std_logic_vector(7 downto 0);
	signal state_reg, state_next : state_type;
	signal flag_reg, flag_next : std_logic;
begin
	process(clk, reset)
	begin
		if(reset='1') then
			state_reg <= idle;
			receiver_check_reg <= (others=>'0');
			receiver_in_reg <= (others=>'0');
			translator_reg <= (others=>'0');
			flag_reg <= '1';
		elsif(translator_out_reset = '1' and rising_edge(clk)) then
		        state_reg <= reset_output;
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
			receiver_check_reg <= receiver_check_next;
			receiver_in_reg <= receiver_in_next;
			translator_reg <= translator_next;
			flag_reg <= flag_next;
		end if;
	end process;

	process(flag_reg, state_reg, receiver_check_reg, translator_reg, flag_in, clk)
	begin
		state_next <= state_reg;
		receiver_check_next <= receiver_check_reg;
		receiver_in_next <= receiver_in_reg;
		translator_next <= translator_reg;
		flag_next <= '0';
		send_check <= '0';

		case state_reg is
			when idle =>
				flag_next <= '0';
				if(flag_in = '1') then
					state_next <= check;
					receiver_in_next <= receiver_in;
					flag_next <= '1';
					receiver_check_next <= receiver_in;
					send_check <= '1';
				end if;
			when check =>
				if(flag_in = '1' or HANDSHAKE = 0) then
					if(receiver_in = "10000000" or HANDSHAKE = 0) then
						case receiver_in_reg is
							when "00000001" => state_next <= forward;
							when "00000010" => state_next <= right;
							when "00000011" => state_next <= fastright;
							when "00000100" => state_next <= right90;
							when "00000101" => state_next <= left;
							when "00000110" => state_next <= fastleft;
							when "00000111" => state_next <= left90;
							when "00001000" => state_next <= backward;
							when "00000000" => state_next <= stop;
							when others => state_next <= idle;
						end case;
					else
						state_next <= idle;
					end if;
				end if;
			when forward =>
				translator_next <= "0001";
				state_next <= idle;
			when right =>
				translator_next <= "0010";
				state_next <= idle;
			when fastright =>
				translator_next <= "0011";
				state_next <= idle;
			when right90 =>
				translator_next <= "0100";
				state_next <= idle;
			when left =>
				translator_next <= "0101";
				state_next <= idle;
			when fastleft =>
				translator_next <= "0110";
				state_next <= idle;
			when left90=>
				translator_next <= "0111";
				state_next <= idle;
			when backward =>
				translator_next <= "1000";
				state_next <= idle;
			when reset_output =>
				translator_next <= "0000";
				state_next <= idle; 
			when others =>
				translator_next <= "0000";
				state_next <= idle; 
		end case;
	end process;
	translator_out <= translator_reg;
	receiver_check <= receiver_check_reg;
	flag_reset <= flag_reg;
end architecture bh;


	
	

