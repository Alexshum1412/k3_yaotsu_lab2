----------------------------------------------------------------------------------
-- Элемент NOAO2: y = not(A v B(C v D))
-- Задержка (таблица 1): 4 нс
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity NOAO2 is
    generic (T : time := 4 ns);   -- задержка элемента
    port (
        A : in  STD_LOGIC;
        B : in  STD_LOGIC;
        C : in  STD_LOGIC;
        D : in  STD_LOGIC;
        Y : out STD_LOGIC
    );
end NOAO2;

architecture Behavioral of NOAO2 is
begin
    Y <= not (A or (B and (C or D))) after T;
end Behavioral;
