----------------------------------------------------------------------------------
-- Элемент NAO22: y = not((A v B)(C v D))
-- Задержка (таблица 1): 3 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NAO22 is
    generic (T : time := 3 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        D : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NAO22;

architecture Behavioral of NAO22 is
begin
    Y <= not ((A or B) and (C or D)) after T;
end Behavioral;
