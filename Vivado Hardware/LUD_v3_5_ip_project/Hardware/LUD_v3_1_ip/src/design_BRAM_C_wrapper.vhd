--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.2.2 (win64) Build 2348494 Mon Oct  1 18:25:44 MDT 2018
--Date        : Sun Jan  5 17:16:01 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_BRAM_C_wrapper.bd
--Design      : design_BRAM_C_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_BRAM_C_wrapper is
  port (
    BRAM_PORTA_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
    BRAM_PORTA_clk : in STD_LOGIC;
    BRAM_PORTA_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_en : in STD_LOGIC;
    BRAM_PORTA_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
    BRAM_PORTB_clk : in STD_LOGIC;
    BRAM_PORTB_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_en : in STD_LOGIC;
    BRAM_PORTB_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
end design_BRAM_C_wrapper;

architecture STRUCTURE of design_BRAM_C_wrapper is
  component design_BRAM_C is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  end component design_BRAM_C;
begin
design_BRAM_C_i: component design_BRAM_C
     port map (
      BRAM_PORTA_0_addr(10 downto 0) => BRAM_PORTA_addr(10 downto 0),
      BRAM_PORTA_0_clk => BRAM_PORTA_clk,
      BRAM_PORTA_0_din(31 downto 0) => BRAM_PORTA_din(31 downto 0),
      BRAM_PORTA_0_dout(31 downto 0) => BRAM_PORTA_dout(31 downto 0),
      BRAM_PORTA_0_en => BRAM_PORTA_en,
      BRAM_PORTA_0_we(0) => BRAM_PORTA_we(0),
      BRAM_PORTB_0_addr(10 downto 0) => BRAM_PORTB_addr(10 downto 0),
      BRAM_PORTB_0_clk => BRAM_PORTB_clk,
      BRAM_PORTB_0_din(31 downto 0) => BRAM_PORTB_din(31 downto 0),
      BRAM_PORTB_0_dout(31 downto 0) => BRAM_PORTB_dout(31 downto 0),
      BRAM_PORTB_0_en => BRAM_PORTB_en,
      BRAM_PORTB_0_we(0) => BRAM_PORTB_we(0)
    );
end STRUCTURE;
