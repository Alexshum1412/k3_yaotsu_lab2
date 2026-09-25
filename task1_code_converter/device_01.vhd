----------------------------------------------------------------------------------
-- Лабораторная работа №2, задание 3.1, вариант 7
-- Преобразователь кода 2421 -> код Грея
--
-- x(3..0) - входной код 2421 (x(3) - старший разряд)
-- y3..y0  - выходной код Грея (y3 - старший разряд)
--
-- Логические функции (коды 2421 0101..1010 не используются - безразличные наборы):
--   y0 = x0 xor x1 xor x3
--   y1 = (not x2 and x1) or (not x3 and x2)
--   y2 = x3 or x2
--   y3 = x1 and x2
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity device_01 is
    port (x : in std_logic_vector(3 downto 0);
          y0, y1, y2, y3 : out std_logic);
end device_01;

architecture Beh4 of device_01 is
    signal f1, f3, f4 : std_logic;
    signal nx3, nx2   : std_logic;
begin
    nx2 <= not x(2);
    nx3 <= not x(3);
    u1: entity work.XOR2(arch3) port map(a => x(0), b => x(1), c => f1);
    u2: entity work.XOR2(arch3) port map(a => f1,   b => x(3), c => y0);
    u3: entity work.AND2(arch1) port map(a => nx2,  b => x(1), c => f3);
    u4: entity work.AND2(arch1) port map(a => nx3,  b => x(2), c => f4);
    u5: entity work.OR2(arch2)  port map(a => f3,   b => f4,   c => y1);
    u6: entity work.OR2(arch2)  port map(a => x(3), b => x(2), c => y2);
    u7: entity work.AND2(arch1) port map(a => x(1), b => x(2), c => y3);
end Beh4;
