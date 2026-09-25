----------------------------------------------------------------------------------
-- Лабораторная работа №2, задание 3.2, вариант 7
-- Приоритетный шифратор 10-4
--
-- din(9..0) - входы запросов, din(9) имеет высший приоритет;
-- dout      - двоичный номер старшего активного входа.
-- Если активных входов нет (или активен только din(0)), dout = "0000".
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity encoder_12to4 is
    Port (
        din  : in  STD_LOGIC_VECTOR (9 downto 0); -- Входы (10 бит)
        dout : out STD_LOGIC_VECTOR (3 downto 0)  -- Выходы (4 бита)
    );
end encoder_12to4;

architecture Behavioral of encoder_12to4 is
begin

    dout <= "1001" when din(9) = '1' else
            "1000" when din(8) = '1' else
            "0111" when din(7) = '1' else
            "0110" when din(6) = '1' else
            "0101" when din(5) = '1' else
            "0100" when din(4) = '1' else
            "0011" when din(3) = '1' else
            "0010" when din(2) = '1' else
            "0001" when din(1) = '1' else
            "0000";

end Behavioral;
