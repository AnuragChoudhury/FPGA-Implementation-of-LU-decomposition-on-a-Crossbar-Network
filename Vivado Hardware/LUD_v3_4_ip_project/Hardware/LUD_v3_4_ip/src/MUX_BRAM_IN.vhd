
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.types.all;

entity MUX_BRAM_IN is
    port(
        SEL  : in  std_logic_vector(5-1 downto 0);
        DIN  : in  dataArray(23 downto 0);
        DOUT : out std_logic_vector(63 downto 0)
    );
end entity;

architecture behav of MUX_BRAM_IN is
begin
sel_process : process(SEL, DIN)
    begin
    case SEL is
        when "00000" => DOUT <= DIN(0);
        when "00001" => DOUT <= DIN(1);
        when "00010" => DOUT <= DIN(2);
        when "00011" => DOUT <= DIN(3);
        when "00100" => DOUT <= DIN(4);
        when "00101" => DOUT <= DIN(5);
        when "00110" => DOUT <= DIN(6);
        when "00111" => DOUT <= DIN(7);
        when "01000" => DOUT <= DIN(8);
        when "01001" => DOUT <= DIN(9);
        when "01010" => DOUT <= DIN(10);
        when "01011" => DOUT <= DIN(11);
        when "01100" => DOUT <= DIN(12);
        when "01101" => DOUT <= DIN(13);
        when "01110" => DOUT <= DIN(14);
        when "01111" => DOUT <= DIN(15);
        when "10000" => DOUT <= DIN(16);
        when "10001" => DOUT <= DIN(17);
        when "10010" => DOUT <= DIN(18);
        when "10011" => DOUT <= DIN(19);
        when "10100" => DOUT <= DIN(20);
        when "10101" => DOUT <= DIN(21);
        when "10110" => DOUT <= DIN(22);
        when "10111" => DOUT <= DIN(23);
        when others => DOUT <= (others => 'X');
    end case;
end process;
end architecture;
