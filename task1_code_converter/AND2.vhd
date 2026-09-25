library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Элемент "И" на 2 входа
entity AND2 is
    Port (a : in  STD_LOGIC;
          b : in  STD_LOGIC;
          c : out STD_LOGIC);
end AND2;

architecture arch1 of AND2 is
begin
    c <= a and b;
end arch1;
