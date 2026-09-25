----------------------------------------------------------------------------------
-- Тестирующая программа для мультиплексора 45-1 со стробированием
--
-- Полный перебор 2^52 комбинаций (45 бит данных + 6 бит адреса + строб)
-- физически невозможен, поэтому перебираются все значимые наборы:
--   * оба значения строба STB = '0' / '1';
--   * все 64 значения адреса A = 0..63 (включая неиспользуемые 45..63);
--   * для каждого адреса выбранный вход принимает оба значения '0' и '1'
--     на "противоположном" фоне остальных входов:
--       - "бегущая единица": D = 0...010...0 (единица только на входе A),
--       - "бегущий ноль":    D = 1...101...1 (ноль только на входе A).
-- Итого 2 * 64 * 2 = 256 тестовых наборов. Каждый результат проверяется
-- оператором assert, в конце выводится число ошибок.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mux45_1 is
end tb_mux45_1;

architecture Behavioral of tb_mux45_1 is
    signal D   : STD_LOGIC_VECTOR(44 downto 0) := (others => '0');
    signal A   : STD_LOGIC_VECTOR(5 downto 0)  := (others => '0');
    signal STB : STD_LOGIC := '0';
    signal Y   : STD_LOGIC;
begin

    DUT: entity work.mux45_1(Behavioral)
        port map (D => D, A => A, STB => STB, Y => Y);

    stimulus: process
        variable expected : STD_LOGIC;
        variable errors   : integer := 0;
        variable pattern  : STD_LOGIC_VECTOR(44 downto 0);
    begin
        for s in 0 to 1 loop                       -- строб
            for addr in 0 to 63 loop               -- все адреса
                for bitval in 1 downto 0 loop      -- значение выбранного входа
                    -- формирование набора данных
                    if bitval = 1 then
                        pattern := (others => '0');       -- бегущая единица
                        if addr <= 44 then pattern(addr) := '1'; end if;
                    else
                        pattern := (others => '1');       -- бегущий ноль
                        if addr <= 44 then pattern(addr) := '0'; end if;
                    end if;

                    if s = 1 then STB <= '1'; else STB <= '0'; end if;
                    A <= STD_LOGIC_VECTOR(to_unsigned(addr, 6));
                    D <= pattern;
                    wait for 10 ns;

                    -- эталонное значение
                    if s = 1 and addr <= 44 then
                        if bitval = 1 then expected := '1'; else expected := '0'; end if;
                    else
                        expected := '0';
                    end if;

                    if Y /= expected then
                        errors := errors + 1;
                        report "ERROR: STB=" & integer'image(s) &
                               " A=" & integer'image(addr) &
                               " D(A)=" & integer'image(bitval) &
                               " Y=" & STD_LOGIC'image(Y)
                            severity error;
                    end if;
                end loop;
            end loop;
        end loop;

        report "Simulation finished. Vectors checked: 256, errors: "
               & integer'image(errors) severity note;
        wait;
    end process stimulus;

end Behavioral;
