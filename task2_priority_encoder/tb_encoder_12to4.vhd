----------------------------------------------------------------------------------
-- Тестирующая программа для приоритетного шифратора 10-4
--
-- Часть 1 (0..140 нс) - наглядные наборы: каждый вход по отдельности
--   и несколько одновременных запросов для проверки приоритета.
-- Часть 2 - полный перебор всех 2^10 = 1024 входных наборов с автоматическим
--   сравнением с эталоном (номер старшего активного входа).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- У testbench нет портов
entity tb_encoder_12to4 is
end tb_encoder_12to4;

architecture Behavioral of tb_encoder_12to4 is

    signal din  : STD_LOGIC_VECTOR (9 downto 0) := (others => '0');
    signal dout : STD_LOGIC_VECTOR (3 downto 0);

begin

    DUT: entity work.encoder_12to4
        port map (
            din  => din,
            dout => dout
        );

    stim_proc: process
        variable expected : integer;
        variable errors   : integer := 0;
    begin
        ------------------------------------------------------------------
        -- Часть 1. Наглядные наборы
        ------------------------------------------------------------------
        -- Тест 0: все входы в нуле -> ожидаем 0000 (неоднозначно с din(0))
        din <= "0000000000"; wait for 10 ns;
        -- Тесты 1..10: активен один вход -> ожидаем его номер
        din <= "0000000001"; wait for 10 ns;   -- 0000
        din <= "0000000010"; wait for 10 ns;   -- 0001
        din <= "0000000100"; wait for 10 ns;   -- 0010
        din <= "0000001000"; wait for 10 ns;   -- 0011
        din <= "0000010000"; wait for 10 ns;   -- 0100
        din <= "0000100000"; wait for 10 ns;   -- 0101
        din <= "0001000000"; wait for 10 ns;   -- 0110
        din <= "0010000000"; wait for 10 ns;   -- 0111
        din <= "0100000000"; wait for 10 ns;   -- 1000
        din <= "1000000000"; wait for 10 ns;   -- 1001
        -- === Тесты на приоритет ===
        din <= "0010001000"; wait for 10 ns;   -- активны 3 и 7    -> 0111
        din <= "1000100100"; wait for 10 ns;   -- активны 2, 5, 9  -> 1001
        din <= "1000000001"; wait for 10 ns;   -- активны 0 и 9    -> 1001

        ------------------------------------------------------------------
        -- Часть 2. Полный перебор 1024 наборов
        ------------------------------------------------------------------
        for i in 0 to 1023 loop
            din <= STD_LOGIC_VECTOR(to_unsigned(i, 10));
            wait for 10 ns;
            expected := 0;
            for k in 9 downto 1 loop
                if to_unsigned(i, 10)(k) = '1' then
                    expected := k;
                    exit;
                end if;
            end loop;
            if to_integer(unsigned(dout)) /= expected then
                errors := errors + 1;
                report "ERROR at din = " & integer'image(i) severity error;
            end if;
        end loop;

        report "Simulation finished. Vectors checked: 1024, errors: "
               & integer'image(errors);
        wait;
    end process;

end Behavioral;
