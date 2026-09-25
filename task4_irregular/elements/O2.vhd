----------------------------------------------------------------------------------
-- Элемент O2: y = A v B
-- Задержка (таблица 1): 2 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity O2 is
    generic (T : time := 2 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end O2;

architecture Behavioral of O2 is
begin
    Y <= A or B after T;
end Behavioral;
