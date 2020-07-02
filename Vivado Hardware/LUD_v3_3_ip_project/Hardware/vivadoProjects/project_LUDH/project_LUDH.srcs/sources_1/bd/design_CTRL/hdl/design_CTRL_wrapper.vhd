--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Sat May  2 13:12:18 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_CTRL_wrapper.bd
--Design      : design_CTRL_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_CTRL_wrapper is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 13 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 79 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 79 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end design_CTRL_wrapper;

architecture STRUCTURE of design_CTRL_wrapper is
  component design_CTRL is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 13 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 79 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 79 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_CTRL;
begin
design_CTRL_i: component design_CTRL
     port map (
      BRAM_PORTA_0_addr(13 downto 0) => BRAM_PORTA_0_addr(13 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_0_clk,
      BRAM_PORTA_0_din(79 downto 0) => BRAM_PORTA_0_din(79 downto 0),
      BRAM_PORTA_0_dout(79 downto 0) => BRAM_PORTA_0_dout(79 downto 0),
      BRAM_PORTA_0_en => BRAM_PORTA_0_en,
      BRAM_PORTA_0_we(0) => BRAM_PORTA_0_we(0)
    );
end STRUCTURE;
