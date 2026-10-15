library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ADDMult is
    Port (
        Int1  : in  std_logic_vector(31 downto 0);  -- Entero 1
        Int2  : in  std_logic_vector(31 downto 0);  -- Entero 2
        Frac1 : in  std_logic_vector(13 downto 0);  -- Fraccionario 1 (4 decimales)
        Frac2 : in  std_logic_vector(13 downto 0);  -- Fraccionario 2 (4 decimales)
        Sign1 : in  std_logic;
        Sign2 : in  std_logic;
        Oper  : in  std_logic;                      -- Oper = 0: Suma, Oper = 1: Mult
        Result : out std_logic_vector(31 downto 0)
    );
end ADDMult;

architecture Behavioral of ADDMult is
    component IEEE754ConvComb is
        Port (
            Int      : in  std_logic_vector(31 downto 0);
            Frac     : in  std_logic_vector(13 downto 0);
            Mantisa  : out unsigned(22 downto 0);
            Exponent : out unsigned(7 downto 0)
        );
    end component;

    -- Senales para la conversion del numero
    signal Mant1     : unsigned(23 downto 0) := (others => '0');
    signal Mant2     : unsigned(23 downto 0) := (others => '0');
    signal Exponent1 : unsigned(7 downto 0)  := (others => '0');
    signal Exponent2 : unsigned(7 downto 0)  := (others => '0');

    -- Senales para la suma
    signal MantAdd     : unsigned(24 downto 0) := (others => '0');
    signal MantAddSign : unsigned(24 downto 0) := (others => '0');

    -- La diferencia de exponentes puede llegar a 45 (113..158), por eso
    -- el rango original (0 to 31) se amplia a 0 to 255.
    signal alignAdd : natural range 0 to 255;
    signal selctAdd : natural range 0 to 3;
    signal signAdd  : std_logic;

    signal MantalignAdd1 : unsigned(24 downto 0) := (others => '0');
    signal MantalignAdd2 : unsigned(24 downto 0) := (others => '0');

    signal Op1Add : unsigned(24 downto 0) := (others => '0');
    signal Op2Add : unsigned(24 downto 0) := (others => '0');
    signal ShiftResult_Add : natural range 0 to 31;
    signal ResultMantAdd   : unsigned(22 downto 0) := (others => '0');

    signal ExponentAdd       : unsigned(7 downto 0) := (others => '0');
    signal ResultExponentAdd : unsigned(7 downto 0) := (others => '0');

    signal ResultAdd : unsigned(31 downto 0) := (others => '0');

    -- Senales para multiplicacion
    signal signMult    : std_logic;
    signal MMTemp      : unsigned(47 downto 0) := (others => '0');
    signal MultExpNorm : unsigned(7 downto 0)  := (others => '0');
    signal MultExp     : unsigned(7 downto 0)  := (others => '0');
    signal MantMult    : unsigned(22 downto 0) := (others => '0');

    signal IEEE754_Num1 : std_logic_vector(31 downto 0);
    signal IEEE754_Num2 : std_logic_vector(31 downto 0);
    signal ResultMult   : unsigned(31 downto 0) := (others => '0');

begin
    -- Conversiones
    Conv1: IEEE754ConvComb port map (Int => Int1, Frac => Frac1, Mantisa => Mant1(22 downto 0), Exponent => Exponent1);
    Conv2: IEEE754ConvComb port map (Int => Int2, Frac => Frac2, Mantisa => Mant2(22 downto 0), Exponent => Exponent2);

    -- Codigo para la suma y resta
    -- Poner los 1 implicitos en las mantisas
    Mant1(23) <= '1' when Exponent1 > 0 else '0';
    Mant2(23) <= '1' when Exponent2 > 0 else '0';

    -- El caso 0 era inalcanzable (si los exponentes son iguales ya cae en 1)
    -- y dejaba la asignacion sin 'else' final (latch); ahora queda completa.
    selctAdd <= 1 when Exponent1 = Exponent2 else
                2 when Exponent1 > Exponent2 else
                3 when Exponent1 < Exponent2 else
                0;

    alignAdd <= to_integer(Exponent1 - Exponent2) when selctAdd = 2 else
                to_integer(Exponent2 - Exponent1) when selctAdd = 3 else 0;

    MantalignAdd1 <= '0' & Mant1 when selctAdd = 2 or selctAdd = 1 else
                     '0' & shift_right(Mant1, alignAdd) when selctAdd = 3 else (others => '0');

    MantalignAdd2 <= '0' & Mant2 when selctAdd = 1 or selctAdd = 3 else
                     '0' & shift_right(Mant2, alignAdd) when selctAdd = 2 else (others => '0');

    ExponentAdd <= (Exponent1 - 24) when selctAdd = 2 or selctAdd = 1 else
                   (Exponent2 - 24) when selctAdd = 3 else (others => '0');

    signAdd <= Sign1 when MantalignAdd1 > MantalignAdd2 and MantAdd /= 0 else
               Sign2 when MantalignAdd1 <= MantalignAdd2 and MantAdd /= 0 else '0';

    -- Complementos
    Op1Add <= not(MantalignAdd1) + 1 when Sign1 = '1' else MantalignAdd1;
    Op2Add <= not(MantalignAdd2) + 1 when Sign2 = '1' else MantalignAdd2;

    MantAdd <= Op1Add + Op2Add when selctAdd > 0 else (others => '0');

    MantAddSign <= not(MantAdd) + 1 when signAdd = '1' else MantAdd;

    ShiftResult_Add <=
                   25 when MantAddSign(24) = '1' else
                   24 when MantAddSign(23) = '1' else
                   23 when MantAddSign(22) = '1' else
                   22 when MantAddSign(21) = '1' else
                   21 when MantAddSign(20) = '1' else
                   20 when MantAddSign(19) = '1' else
                   19 when MantAddSign(18) = '1' else
                   18 when MantAddSign(17) = '1' else
                   17 when MantAddSign(16) = '1' else
                   16 when MantAddSign(15) = '1' else
                   15 when MantAddSign(14) = '1' else
                   14 when MantAddSign(13) = '1' else
                   13 when MantAddSign(12) = '1' else
                   12 when MantAddSign(11) = '1' else
                   11 when MantAddSign(10) = '1' else
                   10 when MantAddSign(9) = '1' else
                    9 when MantAddSign(8) = '1' else
                    8 when MantAddSign(7) = '1' else
                    7 when MantAddSign(6) = '1' else
                    6 when MantAddSign(5) = '1' else
                    5 when MantAddSign(4) = '1' else
                    4 when MantAddSign(3) = '1' else
                    3 when MantAddSign(2) = '1' else
                    2 when MantAddSign(1) = '1' else
                    1 when MantAddSign(0) = '1' else
                    0;  -- Caso del cero

    ResultExponentAdd <= X"FF" when (ExponentAdd + ShiftResult_Add) >= 159 else
                         ExponentAdd + ShiftResult_Add when ShiftResult_Add > 0 else (others => '0');

    ResultMantAdd <= resize(shift_right(MantAddSign, ShiftResult_Add - 24), 23) when ShiftResult_Add >= 24 and ResultExponentAdd < 159 else
                     shift_left(MantAddSign(22 downto 0), 24 - ShiftResult_Add) when ShiftResult_Add > 0 and ResultExponentAdd < 159 else
                     (others => '0');

    ResultAdd <= signAdd & ResultExponentAdd & ResultMantAdd;

    -- Multiplicacion
    signMult <= Sign1 xor Sign2;

    MMTemp <= Mant2 * Mant1;

    MultExpNorm <= Exponent1 + Exponent2 - to_unsigned(126, 8) when (Exponent1 /= 0 and Exponent2 /= 0) and MMTemp(47) = '1' else
                   Exponent1 + Exponent2 - to_unsigned(127, 8) when (Exponent1 /= 0 and Exponent2 /= 0) and MMTemp > 0 else (others => '0');

    MantMult <= MMTemp(46 downto 24) when MMTemp(47) = '1' and MultExpNorm < 159 else
                MMTemp(45 downto 23) when MMTemp > 0 and MultExpNorm < 159 else
                (others => '0');

    MultExp <= X"FF" when MultExpNorm >= 159 else MultExpNorm;

    IEEE754_Num1 <= Sign1 & std_logic_vector(Exponent1) & std_logic_vector(Mant1(22 downto 0));
    IEEE754_Num2 <= Sign2 & std_logic_vector(Exponent2) & std_logic_vector(Mant2(22 downto 0));

    ResultMult <= signMult & MultExp & MantMult;

    Result <= std_logic_vector(ResultMult) when Oper = '1' else std_logic_vector(ResultAdd);

end Behavioral;
