LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


ENTITY sensor IS
port ( sensor_in : in std_logic;
		count_reset : in std_logic;
            clk : in std_logic;
            sensor_out : out std_logic
          );
END ENTITY sensor;

ARCHITECTURE bh OF sensor IS   
    signal new_count, count: unsigned(13 downto 0);

    begin

    process (clk, sensor_in)
    begin
        if (rising_edge (clk) ) then
            if (sensor_in = '1' OR count_reset='1') then
                count <= (others => '0');
            else 
                count <= new_count;
      end if;
    end if;
end process;

process (count)
    begin
        new_count <= count + 1;
end process;

process (count)
    begin
    if (count > 4300 ) then --4391
        sensor_out <= '1';
    else
        sensor_out <= '0';
    end if;
end process;
END ARCHITECTURE;