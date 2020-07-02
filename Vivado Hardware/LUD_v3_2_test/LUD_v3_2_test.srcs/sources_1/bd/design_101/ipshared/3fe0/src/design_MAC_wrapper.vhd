--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.2.2 (win64) Build 2348494 Mon Oct  1 18:25:44 MDT 2018
--Date        : Sun Jan  5 19:02:39 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_MAC_wrapper.bd
--Design      : design_MAC_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_MAC_wrapper is
  port (
    M_AXIS_RESULT_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_RESULT_tready : in STD_LOGIC;
    M_AXIS_RESULT_tvalid : out STD_LOGIC;
    S_AXIS_A_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_A_tready : out STD_LOGIC;
    S_AXIS_A_tvalid : in STD_LOGIC;
    S_AXIS_B_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_B_tready : out STD_LOGIC;
    S_AXIS_B_tvalid : in STD_LOGIC;
    S_AXIS_C_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_C_tready : out STD_LOGIC;
    S_AXIS_C_tvalid : in STD_LOGIC;
    S_AXIS_OPERATION_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXIS_OPERATION_tready : out STD_LOGIC;
    S_AXIS_OPERATION_tvalid : in STD_LOGIC;
    aclk : in STD_LOGIC
  );
end design_MAC_wrapper;

architecture STRUCTURE of design_MAC_wrapper is
  component design_MAC is
  port (
    aclk_0 : in STD_LOGIC;
    M_AXIS_RESULT_0_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 );
    M_AXIS_RESULT_0_tready : in STD_LOGIC;
    M_AXIS_RESULT_0_tvalid : out STD_LOGIC;
    S_AXIS_A_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_A_0_tready : out STD_LOGIC;
    S_AXIS_A_0_tvalid : in STD_LOGIC;
    S_AXIS_B_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_B_0_tready : out STD_LOGIC;
    S_AXIS_B_0_tvalid : in STD_LOGIC;
    S_AXIS_C_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_C_0_tready : out STD_LOGIC;
    S_AXIS_C_0_tvalid : in STD_LOGIC;
    S_AXIS_OPERATION_0_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXIS_OPERATION_0_tready : out STD_LOGIC;
    S_AXIS_OPERATION_0_tvalid : in STD_LOGIC
  );
  end component design_MAC;
begin
design_MAC_i: component design_MAC
     port map (
      M_AXIS_RESULT_0_tdata(31 downto 0) => M_AXIS_RESULT_tdata(31 downto 0),
      M_AXIS_RESULT_0_tready => M_AXIS_RESULT_tready,
      M_AXIS_RESULT_0_tvalid => M_AXIS_RESULT_tvalid,
      S_AXIS_A_0_tdata(31 downto 0) => S_AXIS_A_tdata(31 downto 0),
      S_AXIS_A_0_tready => S_AXIS_A_tready,
      S_AXIS_A_0_tvalid => S_AXIS_A_tvalid,
      S_AXIS_B_0_tdata(31 downto 0) => S_AXIS_B_tdata(31 downto 0),
      S_AXIS_B_0_tready => S_AXIS_B_tready,
      S_AXIS_B_0_tvalid => S_AXIS_B_tvalid,
      S_AXIS_C_0_tdata(31 downto 0) => S_AXIS_C_tdata(31 downto 0),
      S_AXIS_C_0_tready => S_AXIS_C_tready,
      S_AXIS_C_0_tvalid => S_AXIS_C_tvalid,
      S_AXIS_OPERATION_0_tdata(7 downto 0) => S_AXIS_OPERATION_tdata(7 downto 0),
      S_AXIS_OPERATION_0_tready => S_AXIS_OPERATION_tready,
      S_AXIS_OPERATION_0_tvalid => S_AXIS_OPERATION_tvalid,
      aclk_0 => aclk
    );
end STRUCTURE;
