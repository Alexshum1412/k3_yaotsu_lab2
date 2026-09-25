----------------------------------------------------------------------------------
-- Элемент NMX2: y = not((A v not V)(B v V)) - инверсный мультиплексор 2-1:
--                V=1 -> y = not A, V=0 -> y = not B
-- Задержка (таблица 1): 6 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NMX2 is
    generic (T : time := 6 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        V : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NMX2;

architecture Behavioral of NMX2 is
begin
    Y <= not ((A or not V) and (B or V)) after T;
end Behavioral;
