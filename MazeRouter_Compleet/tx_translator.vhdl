library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--============================
-- Relevante systeeminformatie:
--============================
-- Ingangen en uitgangen voor de buffer van de translator:
-- * Flag: Weergeeft of hij wel of niet klaar is met verzenden. Handig zodat we niet proberen om iets te verzenden als dat helemaal niet kan.
-- * din: 8-bit ingangspoort, zal in het buffer opgenomen op hoge klokflank 
-- * write_data: Schrijf de data van de buffer op de translator 



entity tx_translator is
	port(	clk, reset : in std_logic;
	      	control : in std_logic;
		new_control : in std_logic;
		flag : in std_logic;
		translator_out : out std_logic_vector(7 downto 0);
		send : out std_logic
);
end entity tx_translator;

architecture bh of tx_translator is
	type tx_translator_state is (idle, buffer_control, flag_wait);

	signal state_reg, state_next : tx_translator_state; -- Staat voor opslag huidige en volgende staat
	signal send_reg, send_next : std_logic; -- outputs synchroon!
	signal translator_reg, translator_next : std_logic_vector(7 downto 0); -- outputs synchroon!
	signal control_reg, control_next : std_logic; -- Bufferen van het controle signaal in geval van een vertraging doordat hij al aan het verzenden is
begin
	process(clk, reset) 
	begin
		if(reset = '1') then
			state_reg <= idle;
			send_reg <= '0';
			translator_reg <= (others => '0');
			control_reg <= '0';
		elsif(rising_edge(clk)) then
			state_reg <= state_next;
			send_reg <= send_next;
			translator_reg <= translator_next;
			control_reg <= control_next;
		end if;
	end process;

	process(clk, new_control, flag)
	begin
		state_next <= state_reg;
		send_next <= send_reg;
		translator_next <= translator_reg;
		control_next <= control_reg;
		case(state_reg) is
			when idle =>
				send_next <= '0'; -- Niks versturen
				if(new_control = '1') then
					state_next <= buffer_control;
				end if;
			when buffer_control => -- Er wordt puur gebufferd voor het geval dat tx nog steeds aan het versturen is.
				send_next <= '0'; -- Ter benadrukking, er wordt niks gestuurd
				control_next <= control; -- Buffer het signaal...
				state_next <= flag_wait; 
			when flag_wait =>
				if(flag = '0') then -- Als de tx niet aan het versturen is
					send_next <= '1';
					case(control_reg) is
						when '1' => translator_next <= "00110000"; -- signaal als er een mijn ligt
						when '0' => translator_next <= "00110001"; -- signaal als er geen mijn ligt
						when others => translator_next <= translator_reg; -- Doe niks joh.
					end case;
					state_next <= idle; -- Weer terug -> Send is een pulse.
				end if;
		end case;
	end process;

	send <= send_reg;
	translator_out <= translator_reg;
				

					

				
				
					

end bh;

