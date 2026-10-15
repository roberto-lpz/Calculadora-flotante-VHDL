library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity IEEE754ConvComb is
Port (
        Int: in std_logic_vector(31 downto 0);   -- 4-bits input A
        Frac: in std_logic_vector(13 downto 0);   -- 4-bits input B
        Mantisa: out Unsigned(22 downto 0);   -- 4-bit sum output
        Exponent: out Unsigned(7 downto 0)
        );
end IEEE754ConvComb;

architecture Behavioral of IEEE754ConvComb is
--  Precision de 10000
--  Signals for convertidor fraccionaria 
constant Maxdfrac: unsigned(14 downto 0):= to_unsigned(10000, 15);  
type shift_array is array (0 to 36) of unsigned(14 downto 0);
signal shfrc : shift_array;
signal start: unsigned(14 downto 0);  

--  Q32.23  Para la parte fraccionaria
signal DecFrac: unsigned(68 downto 0):= (others => '0');  
signal shift_value: natural range 0 to 31;
begin

-- Convertidor Fraccionario 

start <= unsigned(Frac(13 downto 0)) & '0';
    
shfrc(0) <= start sll 1  when start < Maxdfrac else 
         (start - Maxdfrac) sll 1;

GEN_SHIFT: for i in 1 to 36 generate
    begin
        shfrc(i) <= shfrc(i-1) sll 1 when shfrc(i-1) < Maxdfrac else
                    (shfrc(i-1) - Maxdfrac) sll 1;
    end generate GEN_SHIFT;


DecFrac(36) <= '1' when start >= Maxdfrac else '0';

GEN_BinFrac: for i in 1 to 36 generate
    begin
        DecFrac(36-i) <= '1' when shfrc(i-1) >= Maxdfrac else '0';
    end generate GEN_BinFrac;

-- Convertidor IEEE754

DecFrac(68 downto 37) <= UNSIGNED(Int);

shift_value <= 68 when DecFrac(68) = '1' else
               67 when DecFrac(67) = '1' else
               66 when DecFrac(66) = '1' else
               65 when DecFrac(65) = '1' else
               64 when DecFrac(64) = '1' else
               63 when DecFrac(63) = '1' else
               62 when DecFrac(62) = '1' else
               61 when DecFrac(61) = '1' else
               60 when DecFrac(60) = '1' else
               59 when DecFrac(59) = '1' else
               58 when DecFrac(58) = '1' else
               57 when DecFrac(57) = '1' else
               56 when DecFrac(56) = '1' else
               55 when DecFrac(55) = '1' else
               54 when DecFrac(54) = '1' else
               53 when DecFrac(53) = '1' else
               52 when DecFrac(52) = '1' else
               51 when DecFrac(51) = '1' else
               50 when DecFrac(50) = '1' else
               49 when DecFrac(49) = '1' else
               48 when DecFrac(48) = '1' else
               47 when DecFrac(47) = '1' else
               46 when DecFrac(46) = '1' else
               45 when DecFrac(45) = '1' else
               44 when DecFrac(44) = '1' else
               43 when DecFrac(43) = '1' else
               42 when DecFrac(42) = '1' else
               41 when DecFrac(41) = '1' else
               40 when DecFrac(40) = '1' else
               39 when DecFrac(39) = '1' else
               38 when DecFrac(38) = '1' else
               37 when DecFrac(37) = '1' else
               36 when DecFrac(36) = '1' else
               35 when DecFrac(35) = '1' else
               34 when DecFrac(34) = '1' else
               33 when DecFrac(33) = '1' else
               32 when DecFrac(32) = '1' else
               31 when DecFrac(31) = '1' else
               30 when DecFrac(30) = '1' else
               29 when DecFrac(29) = '1' else
               28 when DecFrac(28) = '1' else
               27 when DecFrac(27) = '1' else
               26 when DecFrac(26) = '1' else
               25 when DecFrac(25) = '1' else
               24 when DecFrac(24) = '1' else
               23 when DecFrac(23) = '1' else
               22 when DecFrac(22) = '1' else 0;              -- fallback when no bits are set

Mantisa <=  resize(shift_right(DecFrac, shift_value- 23), 23) when shift_value > 22 else (others => '0');

-- Caso 1 el exponente es  mayor que 21, entonces 127 - 37 + shift_value
Exponent <= to_unsigned(90, 8) + shift_value when shift_value > 22 else (others => '0'); 

end Behavioral;