----------------------------------------------------------------------------------
-- Элемент NO3A2: y = not(A v B v CD)
-- Задержка (таблица 1): 5 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NO3A2 is
    generic (T : time := 5 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        D : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NO3A2;

architecture Behavioral of NO3A2 is
begin
    Y <= not (A or B or (C and D)) after T;
end Behavioral;
