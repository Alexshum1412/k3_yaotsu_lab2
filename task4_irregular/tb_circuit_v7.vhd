----------------------------------------------------------------------------------
-- Тестирующая программа для нерегулярной схемы (вариант 7)
--
-- * Одновременно моделируются обе архитектуры: Structural (DUT_S) и
--   Behavioral (DUT_B).
-- * Перебираются все 16 наборов входных переменных x1x2x3x4 = 0000..1111
--   (x1 - старший разряд). Каждый набор удерживается 25 нс - больше
--   задержки критического пути (19 нс), поэтому схема успевает установиться.
-- * Для каждого набора:
--     - определяется задержка схемы - время от смены входного набора до
--       последнего изменения любого из выходов структурной модели
--       (через атрибут 'last_event вектора выходов);
--     - установившиеся выходы обеих моделей сравниваются друг с другом и
--       с эталонной таблицей истинности.
-- * Перед перебором на входы подаётся набор 1111, чтобы на наборе 0000
--   тоже происходило переключение входов.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_circuit_v7 is
end tb_circuit_v7;

architecture Behavioral of tb_circuit_v7 is
    constant T_HOLD : time := 25 ns;

    signal test_x : STD_LOGIC_VECTOR(1 to 4) := "1111";   -- x1..x4
    signal ys     : STD_LOGIC_VECTOR(1 to 4);             -- выходы Structural
    signal yb     : STD_LOGIC_VECTOR(1 to 4);             -- выходы Behavioral

    -- эталонная таблица истинности y1y2y3y4 для наборов 0..15
    type tt_t is array (0 to 15) of STD_LOGIC_VECTOR(1 to 4);
    constant TT : tt_t := (
        "0010", "0100", "0101", "0000",   -- 0000 .. 0011
        "1001", "1101", "1100", "1100",   -- 0100 .. 0111
        "0100", "0000", "0001", "0000",   -- 1000 .. 1011
        "1001", "1011", "1000", "1100");  -- 1100 .. 1111

    function to_str(v : STD_LOGIC_VECTOR) return string is
        variable s : string(1 to v'length);
        variable k : integer := 1;
    begin
        for i in v'range loop
            s(k) := STD_LOGIC'image(v(i))(2);
            k := k + 1;
        end loop;
        return s;
    end function;
begin

    DUT_S: entity work.circuit_v7(Structural)
        port map (x1 => test_x(1), x2 => test_x(2), x3 => test_x(3), x4 => test_x(4),
                  y1 => ys(1), y2 => ys(2), y3 => ys(3), y4 => ys(4));

    DUT_B: entity work.circuit_v7(Behavioral)
        port map (x1 => test_x(1), x2 => test_x(2), x3 => test_x(3), x4 => test_x(4),
                  y1 => yb(1), y2 => yb(2), y3 => yb(3), y4 => yb(4));

    stimulus: process
        variable dmax    : time;
        variable dmax_all : time := 0 ns;
        variable errors  : integer := 0;
    begin
        wait for 50 ns;   -- установка схемы на начальном наборе 1111

        report "Input x1x2x3x4 | Structural y1y2y3y4 | Behavioral y1y2y3y4 | Delay";
        for i in 0 to 15 loop
            test_x <= STD_LOGIC_VECTOR(to_unsigned(i, 4));
            wait for T_HOLD;

            -- задержка набора: время от смены входов до последнего
            -- изменения любого из выходов (атрибут вектора выходов 'last_event)
            if ys'last_event < T_HOLD then
                dmax := T_HOLD - ys'last_event;
            else
                dmax := 0 ns;   -- выходы не изменились
            end if;
            if dmax > dmax_all then dmax_all := dmax; end if;

            if ys /= TT(i) or yb /= TT(i) then
                errors := errors + 1;
                report "ERROR at input " & to_str(test_x) severity error;
            end if;

            report "     " & to_str(test_x) & "     |        " & to_str(ys) &
                   "         |        " & to_str(yb) & "         | " &
                   integer'image(dmax / 1 ns) & " ns";
        end loop;

        report "Max circuit delay: " & integer'image(dmax_all / 1 ns) & " ns" &
               ". Errors: " & integer'image(errors);
        wait;
    end process stimulus;

end Behavioral;
