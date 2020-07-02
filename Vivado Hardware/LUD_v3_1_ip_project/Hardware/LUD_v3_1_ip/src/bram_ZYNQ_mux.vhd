----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/13/2019 07:41:18 PM
-- Design Name: 
-- Module Name: bram_mux - Behavioral
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

entity bram_ZYNQ_mux is
generic(
        ADDR_WIDTH : integer := 11
    );
port (bram_addr_0 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      bram_din_0 : in std_logic_vector(31 downto 0);
      bram_en_0 : in std_logic;
      bram_we_0 : in std_logic;
      bram_addr_1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
      bram_din_1 : in std_logic_vector(31 downto 0);
      bram_en_1 : in std_logic;
      bram_we_1 : in std_logic;
      bram_addr_out : out std_logic_vector(ADDR_WIDTH - 1 downto 0);
      bram_din_out : out std_logic_vector(31 downto 0);
      bram_en_out : out std_logic;
      bram_we_out : out std_logic;
      sel : in std_logic
      );
end bram_ZYNQ_mux;

architecture Behavioral of bram_ZYNQ_mux is

begin

process(sel, bram_addr_0, bram_din_0, bram_en_0, bram_we_0, bram_addr_1, bram_din_1, bram_en_1, bram_we_1)
begin
if(sel = '0') then
bram_addr_out <= bram_addr_0;
bram_din_out <= bram_din_0;
bram_en_out <= bram_en_0;
bram_we_out <= bram_we_0;
else
bram_addr_out <= bram_addr_1;
bram_din_out <= bram_din_1;
bram_en_out <= bram_en_1;
bram_we_out <= bram_we_1;
end if;
end process;


end Behavioral;
