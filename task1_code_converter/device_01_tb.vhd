----------------------------------------------------------------------------------
-- Тестирующая программа для преобразователя кода 2421 -> код Грея
--
-- Перебираются все 16 возможных значений входа x = 0000..1111.
-- Для 10 разрешённых кодов 2421 (цифры 0..9) результат автоматически
-- сравнивается с эталонным кодом Грея; 6 неиспользуемых кодов
-- (0101..1010) являются безразличными наборами и не проверяются.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity device_01_tb is
end device_01_tb;

architecture Behavioral of device_01_tb is
    signal test_x : std_logic_vector(3 downto 0) := "0000";
    signal test_y0, test_y1, test_y2, test_y3 : std_logic;

    type code_t is array (0 to 9) of std_logic_vector(3 downto 0);
    -- цифры 0..9 в коде 2421 и в коде Грея
    constant C2421 : code_t := ("0000", "0001", "0010", "0011", "0100",
                                "1011", "1100", "1101", "1110", "1111");
    constant GRAY  : code_t := ("0000", "0001", "0011", "0010", "0110",
                                "0111", "0101", "0100", "1100", "1101");
begin

    DUT: entity work.device_01(Beh4)
        port map (x => test_x, y0 => test_y0, y1 => test_y1,
                  y2 => test_y2, y3 => test_y3);

    stimulus: process
        variable y      : std_logic_vector(3 downto 0);
        variable errors : integer := 0;
    begin
        for i in 0 to 15 loop
            test_x <= std_logic_vector(to_unsigned(i, 4));
            wait for 10 ns;
            y := test_y3 & test_y2 & test_y1 & test_y0;
            for d in 0 to 9 loop
                if test_x = C2421(d) and y /= GRAY(d) then
                    errors := errors + 1;
                    report "ERROR: digit " & integer'image(d) severity error;
                end if;
            end loop;
        end loop;
        report "Simulation finished. Errors: " & integer'image(errors);
        wait;
    end process;

end Behavioral;
