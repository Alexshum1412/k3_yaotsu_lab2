library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Элемент "ИЛИ" на 2 входа
entity OR2 is
    Port (a : in  STD_LOGIC;
          b : in  STD_LOGIC;
          c : out STD_LOGIC);
end OR2;

architecture arch2 of OR2 is
begin
    c <= a or b;
end arch2;
