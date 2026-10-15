library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

-- Lee vectores.txt (una prueba por linea):
--   int1 frac1 sign1 int2 frac2 sign2 oper
-- y escribe resultados.txt con el resultado en hexadecimal.
entity tb_ADDMult is end tb_ADDMult;

architecture sim of tb_ADDMult is
    signal Int1, Int2   : std_logic_vector(31 downto 0) := (others => '0');
    signal Frac1, Frac2 : std_logic_vector(13 downto 0) := (others => '0');
    signal Sign1, Sign2, Oper : std_logic := '0';
    signal Result : std_logic_vector(31 downto 0);
begin
    dut: entity work.ADDMult
        port map (Int1 => Int1, Int2 => Int2, Frac1 => Frac1, Frac2 => Frac2,
                  Sign1 => Sign1, Sign2 => Sign2, Oper => Oper, Result => Result);

    process
        file fin  : text open read_mode  is "vectores.txt";
        file fout : text open write_mode is "resultados.txt";
        variable l, lo : line;
        variable i1, f1, s1, i2, f2, s2, op : integer;
    begin
        while not endfile(fin) loop
            readline(fin, l);
            read(l, i1); read(l, f1); read(l, s1);
            read(l, i2); read(l, f2); read(l, s2); read(l, op);
            Int1  <= std_logic_vector(to_unsigned(i1, 32));
            Frac1 <= std_logic_vector(to_unsigned(f1, 14));
            if s1 = 1 then Sign1 <= '1'; else Sign1 <= '0'; end if;
            Int2  <= std_logic_vector(to_unsigned(i2, 32));
            Frac2 <= std_logic_vector(to_unsigned(f2, 14));
            if s2 = 1 then Sign2 <= '1'; else Sign2 <= '0'; end if;
            if op = 1 then Oper <= '1'; else Oper <= '0'; end if;
            wait for 10 ns;
            write(lo, to_hstring(Result));
            writeline(fout, lo);
        end loop;
        wait;
    end process;
end sim;
