----------------------------------------------------------------------------------
-- Тестирующая программа для универсального MUX/DEMUX с приоритетизацией
--
-- Часть 1 (0..400 нс) - наглядные наборы для временной диаграммы:
--   адресный MUX, адресный DEMUX, приоритетный MUX/DEMUX, работа строба.
-- Часть 2 - автоматическая проверка: перебор MODE, PRIO, STB, всех адресов
--   SEL (8), всех комбинаций запросов REQ (256), DIN (2) и двух наборов
--   данных X - всего 2*2*2*8*256*2*2 = 65536 наборов. Результат сравнивается
--   с эталонной моделью, вычисленной в самой тестирующей программе.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_mux_demux_prio is
end tb_mux_demux_prio;

architecture Behavioral of tb_mux_demux_prio is
    constant N : integer := 8;
    constant W : integer := 3;

    signal MODE, PRIO, STB, DIN : STD_LOGIC := '0';
    signal SEL   : STD_LOGIC_VECTOR(W-1 downto 0) := (others => '0');
    signal REQ   : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal X     : STD_LOGIC_VECTOR(N-1 downto 0) := (others => '0');
    signal Y     : STD_LOGIC;
    signal Q     : STD_LOGIC_VECTOR(N-1 downto 0);
    signal CH    : STD_LOGIC_VECTOR(W-1 downto 0);
    signal VALID : STD_LOGIC;

    function sl(b : boolean) return STD_LOGIC is
    begin
        if b then return '1'; else return '0'; end if;
    end function;
begin

    DUT: entity work.mux_demux_prio(Behavioral)
        generic map (N => N, W => W)
        port map (MODE => MODE, PRIO => PRIO, STB => STB, SEL => SEL,
                  REQ => REQ, X => X, DIN => DIN,
                  Y => Y, Q => Q, CH => CH, VALID => VALID);

    stimulus: process
        variable e_y     : STD_LOGIC;
        variable e_q     : STD_LOGIC_VECTOR(N-1 downto 0);
        variable e_ch    : integer;
        variable e_valid : STD_LOGIC;
        variable errors  : integer := 0;
        variable cnt     : integer := 0;
        type pat_t is array (0 to 1) of STD_LOGIC_VECTOR(N-1 downto 0);
        constant XPAT : pat_t := ("10110010", "01001101");
    begin
        ------------------------------------------------------------------
        -- Часть 1. Наглядные наборы
        ------------------------------------------------------------------
        STB <= '1'; X <= "10110010";
        -- адресный мультиплексор: перебор адресов 0..7
        MODE <= '0'; PRIO <= '0';
        for i in 0 to 7 loop
            SEL <= STD_LOGIC_VECTOR(to_unsigned(i, W)); wait for 10 ns;
        end loop;
        -- адресный демультиплексор: DIN = '1', перебор адресов
        MODE <= '1'; DIN <= '1';
        for i in 0 to 7 loop
            SEL <= STD_LOGIC_VECTOR(to_unsigned(i, W)); wait for 10 ns;
        end loop;
        -- приоритетный мультиплексор: несколько одновременных запросов
        MODE <= '0'; PRIO <= '1'; SEL <= "000";
        REQ <= "00000000"; wait for 10 ns;   -- нет запросов -> VALID = 0
        REQ <= "00000110"; wait for 10 ns;   -- обслуживается канал 2
        REQ <= "00101001"; wait for 10 ns;   -- обслуживается канал 5
        REQ <= "10000001"; wait for 10 ns;   -- обслуживается канал 7
        REQ <= "00011000"; wait for 10 ns;   -- обслуживается канал 4
        -- приоритетный демультиплексор
        MODE <= '1'; DIN <= '1';
        REQ <= "00000110"; wait for 10 ns;   -- DIN -> Q(2)
        REQ <= "01010000"; wait for 10 ns;   -- DIN -> Q(6)
        REQ <= "11111111"; wait for 10 ns;   -- DIN -> Q(7)
        DIN <= '0';        wait for 10 ns;   -- Q(7) = DIN = 0
        -- строб выключен: все выходы неактивны
        DIN <= '1'; STB <= '0'; wait for 10 ns;
        MODE <= '0';            wait for 10 ns;
        STB <= '1';             wait for 10 ns;
        wait for 40 ns;

        ------------------------------------------------------------------
        -- Часть 2. Автоматическая проверка с эталонной моделью
        ------------------------------------------------------------------
        for m in 0 to 1 loop
        for p in 0 to 1 loop
        for s in 0 to 1 loop
        for a in 0 to N-1 loop
        for r in 0 to 2**N-1 loop
        for d in 0 to 1 loop
        for xp in 0 to 1 loop
            MODE <= sl(m = 1); PRIO <= sl(p = 1); STB <= sl(s = 1);
            SEL  <= STD_LOGIC_VECTOR(to_unsigned(a, W));
            REQ  <= STD_LOGIC_VECTOR(to_unsigned(r, N));
            DIN  <= sl(d = 1);
            X    <= XPAT(xp);
            wait for 1 ns;

            -- эталон
            e_y := '0'; e_q := (others => '0'); e_ch := 0; e_valid := '0';
            if p = 1 then
                e_ch := -1;
                for i in N-1 downto 0 loop
                    if to_unsigned(r, N)(i) = '1' then e_ch := i; exit; end if;
                end loop;
            else
                e_ch := a;
            end if;
            if s = 1 and e_ch >= 0 then
                e_valid := '1';
                if m = 0 then e_y := XPAT(xp)(e_ch);
                else          e_q(e_ch) := sl(d = 1);
                end if;
            else
                e_ch := 0;
            end if;

            cnt := cnt + 1;
            if Y /= e_y or Q /= e_q or VALID /= e_valid or
               to_integer(unsigned(CH)) /= e_ch then
                errors := errors + 1;
                report "ERROR at vector " & integer'image(cnt) severity error;
            end if;
        end loop; end loop; end loop; end loop; end loop; end loop; end loop;

        report "Self-check finished. Vectors: " & integer'image(cnt)
               & ", errors: " & integer'image(errors) severity note;
        wait;
    end process stimulus;

end Behavioral;
