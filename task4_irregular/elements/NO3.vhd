----------------------------------------------------------------------------------
-- Элемент NO3: y = not(A v B v C)
-- Задержка (таблица 1): 4 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NO3 is
    generic (T : time := 4 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NO3;

architecture Behavioral of NO3 is
begin
    Y <= not (A or B or C) after T;
end Behavioral;
