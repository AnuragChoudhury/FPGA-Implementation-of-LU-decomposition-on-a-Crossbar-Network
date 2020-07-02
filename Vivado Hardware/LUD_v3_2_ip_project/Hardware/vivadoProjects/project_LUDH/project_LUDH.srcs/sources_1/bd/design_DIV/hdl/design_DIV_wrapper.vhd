--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Fri May  1 23:10:49 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_DIV_wrapper.bd
--Design      : design_DIV_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_DIV_wrapper is
  port (
    M_AXIS_RESULT_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_RESULT_0_tready : in STD_LOGIC;
    M_AXIS_RESULT_0_tvalid : out STD_LOGIC;
    S_AXIS_A_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_A_0_tready : out STD_LOGIC;
    S_AXIS_A_0_tvalid : in STD_LOGIC;
    S_AXIS_B_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_B_0_tready : out STD_LOGIC;
    S_AXIS_B_0_tvalid : in STD_LOGIC;
    aclk_0 : in STD_LOGIC
  );
end design_DIV_wrapper;

architecture STRUCTURE of design_DIV_wrapper is
  component design_DIV is
  port (
    aclk_0 : in STD_LOGIC;
    M_AXIS_RESULT_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_RESULT_0_tready : in STD_LOGIC;
    M_AXIS_RESULT_0_tvalid : out STD_LOGIC;
    S_AXIS_B_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_B_0_tready : out STD_LOGIC;
    S_AXIS_B_0_tvalid : in STD_LOGIC;
    S_AXIS_A_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_A_0_tready : out STD_LOGIC;
    S_AXIS_A_0_tvalid : in STD_LOGIC
  );
  end component design_DIV;
begin
design_DIV_i: component design_DIV
     port map (
      M_AXIS_RESULT_0_tdata(31 downto 0) => M_AXIS_RESULT_0_tdata(31 downto 0),
      M_AXIS_RESULT_0_tready => M_AXIS_RESULT_0_tready,
      M_AXIS_RESULT_0_tvalid => M_AXIS_RESULT_0_tvalid,
      S_AXIS_A_0_tdata(31 downto 0) => S_AXIS_A_0_tdata(31 downto 0),
      S_AXIS_A_0_tready => S_AXIS_A_0_tready,
      S_AXIS_A_0_tvalid => S_AXIS_A_0_tvalid,
      S_AXIS_B_0_tdata(31 downto 0) => S_AXIS_B_0_tdata(31 downto 0),
      S_AXIS_B_0_tready => S_AXIS_B_0_tready,
      S_AXIS_B_0_tvalid => S_AXIS_B_0_tvalid,
      aclk_0 => aclk_0
    );
end STRUCTURE;
