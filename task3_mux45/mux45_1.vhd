----------------------------------------------------------------------------------
-- Лабораторная работа №2, задание 3.3, вариант 7
-- Мультиплексор 45-1 со стробированием
--
-- D   - 45 информационных входов D(44..0)
-- A   - 6-разрядный адрес (2^6 = 64 >= 45), рабочие адреса 0..44
-- STB - стробирующий (разрешающий) вход:
--         STB = '1' - мультиплексор работает, Y = D(A);
--         STB = '0' - выход заблокирован, Y = '0'.
-- Y   - выход
-- Для неиспользуемых адресов 45..63 выход Y = '0'.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux45_1 is
    port (
        D   : in  STD_LOGIC_VECTOR(44 downto 0); -- Информационные входы
        A   : in  STD_LOGIC_VECTOR(5 downto 0);  -- Адресные входы
        STB : in  STD_LOGIC;                     -- Строб (разрешение)
        Y   : out STD_LOGIC                      -- Выход
    );
end mux45_1;

architecture Behavioral of mux45_1 is
begin
    process(D, A, STB)
        variable idx : integer range 0 to 63;
    begin
        idx := to_integer(unsigned(A));
        if STB = '1' and idx <= 44 then
            Y <= D(idx);
        else
            Y <= '0';
        end if;
    end process;
end Behavioral;
