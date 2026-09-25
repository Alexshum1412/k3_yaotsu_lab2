library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Элемент "исключающее ИЛИ" на 2 входа
entity XOR2 is
    Port (a : in  STD_LOGIC;
          b : in  STD_LOGIC;
          c : out STD_LOGIC);
end XOR2;

architecture arch3 of XOR2 is
begin
    c <= a xor b;
end arch3;
