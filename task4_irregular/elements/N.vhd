----------------------------------------------------------------------------------
-- Элемент N: y = not A
-- Задержка (таблица 1): 1 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity N is
    generic (T : time := 1 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end N;

architecture Behavioral of N is
begin
    Y <= not A after T;
end Behavioral;
