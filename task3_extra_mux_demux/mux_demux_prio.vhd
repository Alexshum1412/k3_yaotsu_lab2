----------------------------------------------------------------------------------
-- Лабораторная работа №2, задание 3.3 (дополнительное)
-- Универсальный мультиплексор/демультиплексор с приоритетизацией входов
--
-- MODE = '0' - режим мультиплексора:   Y      <= X(канал)
-- MODE = '1' - режим демультиплексора: Q(канал) <= DIN, остальные Q = '0'
--
-- Выбор канала:
--   PRIO = '0' - канал задаётся адресом SEL (обычная адресация);
--   PRIO = '1' - приоритетный режим: канал выбирается по линиям запросов REQ,
--                обслуживается запрос с НАИБОЛЬШИМ номером (REQ(N-1) имеет
--                высший приоритет, REQ(0) - низший). Адрес SEL игнорируется.
--
-- STB   - строб: при STB = '0' все выходы неактивны (Y = '0', Q = 0, VALID = '0').
-- CH    - номер обслуживаемого канала.
-- VALID - признак того, что канал выбран (в приоритетном режиме VALID = '0',
--         если нет ни одного запроса).
--
-- Разрядность задаётся параметром N (по умолчанию 8 каналов), W = log2(N).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux_demux_prio is
    generic (
        N : integer := 8;   -- число каналов
        W : integer := 3    -- разрядность адреса
    );
    port (
        MODE  : in  STD_LOGIC;                        -- 0 - MUX, 1 - DEMUX
        PRIO  : in  STD_LOGIC;                        -- 1 - приоритетный выбор
        STB   : in  STD_LOGIC;                        -- строб
        SEL   : in  STD_LOGIC_VECTOR(W-1 downto 0);   -- адрес канала
        REQ   : in  STD_LOGIC_VECTOR(N-1 downto 0);   -- запросы каналов
        X     : in  STD_LOGIC_VECTOR(N-1 downto 0);   -- входы мультиплексора
        DIN   : in  STD_LOGIC;                        -- вход демультиплексора
        Y     : out STD_LOGIC;                        -- выход мультиплексора
        Q     : out STD_LOGIC_VECTOR(N-1 downto 0);   -- выходы демультиплексора
        CH    : out STD_LOGIC_VECTOR(W-1 downto 0);   -- номер выбранного канала
        VALID : out STD_LOGIC                         -- канал выбран
    );
end mux_demux_prio;

architecture Behavioral of mux_demux_prio is
begin
    process(MODE, PRIO, STB, SEL, REQ, X, DIN)
        variable ch_v    : integer range 0 to N-1;
        variable found_v : boolean;
    begin
        -- значения по умолчанию
        Y     <= '0';
        Q     <= (others => '0');
        CH    <= (others => '0');
        VALID <= '0';

        -- 1) определение обслуживаемого канала
        ch_v    := 0;
        found_v := false;
        if PRIO = '1' then
            -- приоритетный шифратор: просмотр от старшего запроса к младшему,
            -- первый найденный запрос (с высшим приоритетом) обслуживается
            for i in N-1 downto 0 loop
                if REQ(i) = '1' then
                    ch_v    := i;
                    found_v := true;
                    exit;
                end if;
            end loop;
        else
            ch_v    := to_integer(unsigned(SEL));
            found_v := true;
        end if;

        -- 2) коммутация данных
        if STB = '1' and found_v then
            CH    <= STD_LOGIC_VECTOR(to_unsigned(ch_v, W));
            VALID <= '1';
            if MODE = '0' then
                Y <= X(ch_v);          -- мультиплексор
            else
                Q(ch_v) <= DIN;        -- демультиплексор
            end if;
        end if;
    end process;
end Behavioral;
