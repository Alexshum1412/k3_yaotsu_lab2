----------------------------------------------------------------------------------
-- Лабораторная работа №2, задание 3.4, вариант 7
-- Нерегулярная логическая схема: 4 входа (x1..x4), 4 выхода (y1..y4)
--
-- Один интерфейс (entity) и две архитектуры:
--   Structural - структурное описание: схема собрана из моделей элементов
--                N, O2, NA3, NAO22, NO3, NO4, NO3A2, NOAO2, NMX2 с задержками
--                из таблицы 1;
--   Behavioral - поведенческое описание: процесс, вычисляющий выходы по
--                минимизированным логическим уравнениям схемы; каждый выход
--                формируется с задержкой, равной задержке самого длинного
--                пути схемы до этого выхода.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity circuit_v7 is
    port (
        x1, x2, x3, x4 : in  STD_LOGIC;
        y1, y2, y3, y4 : out STD_LOGIC
    );
end circuit_v7;

----------------------------------------------------------------------------------
-- Структурное описание
--
--  Элемент  Тип     Входы (A, B, C, D / V)            Выход     t, нс
--  DD1      N       x2                                nx2       1
--  DD2      N       x3                                nx3       1
--  DD3      O2      x4, x2                            s_o2      2
--  DD4      NA3     x2, x4, x1                        s_na3     3
--  DD5      NOAO2   x3, s_na3, x1, s_o2               s_noao2   4  (= y3)
--  DD6      NMX2    A=s_o2, B=nx2, V=x3               s_nmx2    6  (= y4)
--  DD7      NAO22   x3, x1, nx2, s_noao2              s_nao22   3
--  DD8      NO3     x1, nx3, x4                       s_no3     4
--  DD9      NO4     x4, x2, s_nmx2, s_noao2           s_no4     5
--  DD10     NO3A2   s_no3, s_no4, x4, s_nao22         s_no3a2   5
--  DD11     N       s_no3a2                           y2        1
--  y1 = x2 (выход соединён непосредственно со входом x2)
----------------------------------------------------------------------------------
architecture Structural of circuit_v7 is
    signal nx2, nx3                       : STD_LOGIC;
    signal s_o2, s_na3, s_noao2, s_nmx2   : STD_LOGIC;
    signal s_nao22, s_no3, s_no4, s_no3a2 : STD_LOGIC;
begin
    DD1:  entity work.N     port map (A => x2, Y => nx2);
    DD2:  entity work.N     port map (A => x3, Y => nx3);
    DD3:  entity work.O2    port map (A => x4, B => x2, Y => s_o2);
    DD4:  entity work.NA3   port map (A => x2, B => x4, C => x1, Y => s_na3);
    DD5:  entity work.NOAO2 port map (A => x3, B => s_na3, C => x1, D => s_o2,
                                      Y => s_noao2);
    DD6:  entity work.NMX2  port map (A => s_o2, B => nx2, V => x3, Y => s_nmx2);
    DD7:  entity work.NAO22 port map (A => x3, B => x1, C => nx2, D => s_noao2,
                                      Y => s_nao22);
    DD8:  entity work.NO3   port map (A => x1, B => nx3, C => x4, Y => s_no3);
    DD9:  entity work.NO4   port map (A => x4, B => x2, C => s_nmx2, D => s_noao2,
                                      Y => s_no4);
    DD10: entity work.NO3A2 port map (A => s_no3, B => s_no4, C => x4, D => s_nao22,
                                      Y => s_no3a2);
    DD11: entity work.N     port map (A => s_no3a2, Y => y2);

    y1 <= x2;
    y3 <= s_noao2;
    y4 <= s_nmx2;
end Structural;

----------------------------------------------------------------------------------
-- Поведенческое описание
--
-- Минимизированные уравнения (получены из таблицы истинности схемы):
--   y1 = x2
--   y2 = x2 x3 x4 v !x1 x3 !x4 v !x1 !x3 x4 v x1 !x2 !x3 !x4
--   y3 = x1 x2 !x3 x4 v !x1 !x2 !x3 !x4
--   y4 = x2 !x3 v !x2 x3 !x4
--
-- Задержки выходов = задержки самых длинных путей схемы:
--   y1: 0 нс  (прямая связь)
--   y2: 19 нс (O2 -> NMX2 -> NO4 -> NO3A2 -> N = 2+6+5+5+1) - критический путь
--   y3: 7 нс  (NA3 -> NOAO2 = 3+4)
--   y4: 8 нс  (O2 -> NMX2 = 2+6)
----------------------------------------------------------------------------------
architecture Behavioral of circuit_v7 is
    constant T_Y2 : time := 19 ns;
    constant T_Y3 : time := 7 ns;
    constant T_Y4 : time := 8 ns;
begin
    process(x1, x2, x3, x4)
        variable v2, v3, v4 : STD_LOGIC;
    begin
        v2 := (x2 and x3 and x4)
           or (not x1 and x3 and not x4)
           or (not x1 and not x3 and x4)
           or (x1 and not x2 and not x3 and not x4);

        v3 := (x1 and x2 and not x3 and x4)
           or (not x1 and not x2 and not x3 and not x4);

        v4 := (x2 and not x3)
           or (not x2 and x3 and not x4);

        y1 <= x2;
        y2 <= v2 after T_Y2;
        y3 <= v3 after T_Y3;
        y4 <= v4 after T_Y4;
    end process;
end Behavioral;
