
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity MUX_AU_IN is
    port(
        SEL  : in  std_logic_vector(2 downto 0);
        DIN  : in  dataArray(6 downto 0);
        DOUT : out std_logic_vector(31 downto 0)
    );
end entity;

architecture behav of MUX_AU_IN is
begin
sel_process : process(SEL, DIN)
    begin
    case SEL is
        when "000" => DOUT <= DIN(0);
        when "001" => DOUT <= DIN(1);
        when "010" => DOUT <= DIN(2);
        when "011" => DOUT <= DIN(3);
        when "100" => DOUT <= DIN(4);
        when "101" => DOUT <= DIN(5);
        when "110" => DOUT <= DIN(6);
        when others => DOUT <= (others => 'X');
    end case;
end process;
end architecture;
