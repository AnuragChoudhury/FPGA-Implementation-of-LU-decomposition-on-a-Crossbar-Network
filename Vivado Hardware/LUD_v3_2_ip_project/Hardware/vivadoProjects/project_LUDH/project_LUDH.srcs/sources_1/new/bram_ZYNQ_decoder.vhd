----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/15/2019 12:35:02 AM
-- Design Name: 
-- Module Name: bram_ZYNQ_decoder - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity bram_ZYNQ_decoder is
generic (width:integer := 32);
Port (decoder_in : in std_logic_vector(width - 1 downto 0);
      decoder_out_0 : out std_logic_vector(width - 1 downto 0);
      decoder_out_1 : out std_logic_vector(width - 1 downto 0);
      sel : in std_logic
);
end bram_ZYNQ_decoder;

architecture Behavioral of bram_ZYNQ_decoder is

begin

process(sel, decoder_in)
begin
if(sel = '0')then
decoder_out_0 <= decoder_in;
decoder_out_1 <= (others => '0');
else
decoder_out_0 <= (others => '0');
decoder_out_1 <= decoder_in;
end if;
end process;

end Behavioral;
