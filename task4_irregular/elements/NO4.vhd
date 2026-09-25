----------------------------------------------------------------------------------
-- Элемент NO4: y = not(A v B v C v D)
-- Задержка (таблица 1): 5 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NO4 is
    generic (T : time := 5 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        D : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NO4;

architecture Behavioral of NO4 is
begin
    Y <= not (A or B or C or D) after T;
end Behavioral;
