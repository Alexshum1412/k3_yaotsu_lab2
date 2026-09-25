----------------------------------------------------------------------------------
-- Элемент NA3: y = not(A B C)
-- Задержка (таблица 1): 3 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NA3 is
    generic (T : time := 3 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NA3;

architecture Behavioral of NA3 is
begin
    Y <= not (A and B and C) after T;
end Behavioral;
