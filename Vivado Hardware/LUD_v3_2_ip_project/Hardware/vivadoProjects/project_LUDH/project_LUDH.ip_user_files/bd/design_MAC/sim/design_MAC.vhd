--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Thu May  7 13:06:46 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_MAC.bd
--Design      : design_MAC
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_MAC is
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
    S_AXIS_C_0_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXIS_C_0_tready : out STD_LOGIC;
    S_AXIS_C_0_tvalid : in STD_LOGIC;
    S_AXIS_OPERATION_0_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    S_AXIS_OPERATION_0_tready : out STD_LOGIC;
    S_AXIS_OPERATION_0_tvalid : in STD_LOGIC;
    aclk_0 : in STD_LOGIC
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_MAC : entity is "design_MAC,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_MAC,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_MAC : entity is "design_MAC.hwdef";
end design_MAC;

architecture STRUCTURE of design_MAC is
  component design_MAC_floating_point_0_0 is
  port (
    aclk : in STD_LOGIC;
    s_axis_a_tvalid : in STD_LOGIC;
    s_axis_a_tready : out STD_LOGIC;
    s_axis_a_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_b_tvalid : in STD_LOGIC;
    s_axis_b_tready : out STD_LOGIC;
    s_axis_b_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_c_tvalid : in STD_LOGIC;
    s_axis_c_tready : out STD_LOGIC;
    s_axis_c_tdata : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_operation_tvalid : in STD_LOGIC;
    s_axis_operation_tready : out STD_LOGIC;
    s_axis_operation_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
    m_axis_result_tvalid : out STD_LOGIC;
    m_axis_result_tready : in STD_LOGIC;
    m_axis_result_tdata : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component design_MAC_floating_point_0_0;
  signal S_AXIS_A_0_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXIS_A_0_1_TREADY : STD_LOGIC;
  signal S_AXIS_A_0_1_TVALID : STD_LOGIC;
  signal S_AXIS_B_0_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXIS_B_0_1_TREADY : STD_LOGIC;
  signal S_AXIS_B_0_1_TVALID : STD_LOGIC;
  signal S_AXIS_C_0_1_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal S_AXIS_C_0_1_TREADY : STD_LOGIC;
  signal S_AXIS_C_0_1_TVALID : STD_LOGIC;
  signal S_AXIS_OPERATION_0_1_TDATA : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal S_AXIS_OPERATION_0_1_TREADY : STD_LOGIC;
  signal S_AXIS_OPERATION_0_1_TVALID : STD_LOGIC;
  signal aclk_0_1 : STD_LOGIC;
  signal floating_point_0_M_AXIS_RESULT_TDATA : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal floating_point_0_M_AXIS_RESULT_TREADY : STD_LOGIC;
  signal floating_point_0_M_AXIS_RESULT_TVALID : STD_LOGIC;
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of M_AXIS_RESULT_0_tready : signal is "xilinx.com:interface:axis:1.0 M_AXIS_RESULT_0 TREADY";
  attribute X_INTERFACE_INFO of M_AXIS_RESULT_0_tvalid : signal is "xilinx.com:interface:axis:1.0 M_AXIS_RESULT_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_A_0_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_A_0 TREADY";
  attribute X_INTERFACE_INFO of S_AXIS_A_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_A_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_B_0_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_B_0 TREADY";
  attribute X_INTERFACE_INFO of S_AXIS_B_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_B_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_C_0_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_C_0 TREADY";
  attribute X_INTERFACE_INFO of S_AXIS_C_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_C_0 TVALID";
  attribute X_INTERFACE_INFO of S_AXIS_OPERATION_0_tready : signal is "xilinx.com:interface:axis:1.0 S_AXIS_OPERATION_0 TREADY";
  attribute X_INTERFACE_INFO of S_AXIS_OPERATION_0_tvalid : signal is "xilinx.com:interface:axis:1.0 S_AXIS_OPERATION_0 TVALID";
  attribute X_INTERFACE_INFO of aclk_0 : signal is "xilinx.com:signal:clock:1.0 CLK.ACLK_0 CLK";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of aclk_0 : signal is "XIL_INTERFACENAME CLK.ACLK_0, ASSOCIATED_BUSIF M_AXIS_RESULT_0:S_AXIS_A_0:S_AXIS_B_0:S_AXIS_C_0:S_AXIS_OPERATION_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, INSERT_VIP 0, PHASE 0.000";
  attribute X_INTERFACE_INFO of M_AXIS_RESULT_0_tdata : signal is "xilinx.com:interface:axis:1.0 M_AXIS_RESULT_0 TDATA";
  attribute X_INTERFACE_PARAMETER of M_AXIS_RESULT_0_tdata : signal is "XIL_INTERFACENAME M_AXIS_RESULT_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA xilinx.com:interface:datatypes:1.0 {TDATA {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value data} bitwidth {attribs {resolve_type generated dependency width format long minimum {} maximum {}} value 32} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} real {float {sigwidth {attribs {resolve_type generated dependency fractwidth format long minimum {} maximum {}} value 24}}}}} TDATA_WIDTH 32 TUSER {datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type automatic dependency {} format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0} struct {field_underflow {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value underflow} enabled {attribs {resolve_type generated dependency underflow_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency underflow_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type immediate dependency {} format long minimum {} maximum {}} value 0}}} field_overflow {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value overflow} enabled {attribs {resolve_type generated dependency overflow_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency overflow_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency overflow_bitoffset format long minimum {} maximum {}} value 0}}} field_invalid_op {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value invalid_op} enabled {attribs {resolve_type generated dependency invalid_op_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency invalid_op_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency invalid_op_bitoffset format long minimum {} maximum {}} value 0}}} field_div_by_zero {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value div_by_zero} enabled {attribs {resolve_type generated dependency div_by_zero_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency div_by_zero_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency div_by_zero_bitoffset format long minimum {} maximum {}} value 0}}} field_accum_input_overflow {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value accum_input_overflow} enabled {attribs {resolve_type generated dependency accum_input_overflow_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency accum_input_overflow_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency accum_input_overflow_bitoffset format long minimum {} maximum {}} value 0}}} field_accum_overflow {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value accum_overflow} enabled {attribs {resolve_type generated dependency accum_overflow_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency accum_overflow_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency accum_overflow_bitoffset format long minimum {} maximum {}} value 0}}} field_a_tuser {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value a_tuser} enabled {attribs {resolve_type generated dependency a_tuser_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency a_tuser_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency a_tuser_bitoffset format long minimum {} maximum {}} value 0}}} field_b_tuser {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value b_tuser} enabled {attribs {resolve_type generated dependency b_tuser_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency b_tuser_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency b_tuser_bitoffset format long minimum {} maximum {}} value 0}}} field_c_tuser {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value c_tuser} enabled {attribs {resolve_type generated dependency c_tuser_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency c_tuser_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency c_tuser_bitoffset format long minimum {} maximum {}} value 0}}} field_operation_tuser {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value operation_tuser} enabled {attribs {resolve_type generated dependency operation_tuser_enabled format bool minimum {} maximum {}} value false} datatype {name {attribs {resolve_type immediate dependency {} format string minimum {} maximum {}} value {}} bitwidth {attribs {resolve_type generated dependency operation_tuser_bitwidth format long minimum {} maximum {}} value 0} bitoffset {attribs {resolve_type generated dependency operation_tuser_bitoffset format long minimum {} maximum {}} value 0}}}}}} TUSER_WIDTH 0}, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXIS_A_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_A_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_A_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_A_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXIS_B_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_B_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_B_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_B_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXIS_C_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_C_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_C_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_C_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 4, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
  attribute X_INTERFACE_INFO of S_AXIS_OPERATION_0_tdata : signal is "xilinx.com:interface:axis:1.0 S_AXIS_OPERATION_0 TDATA";
  attribute X_INTERFACE_PARAMETER of S_AXIS_OPERATION_0_tdata : signal is "XIL_INTERFACENAME S_AXIS_OPERATION_0, CLK_DOMAIN design_MAC_aclk_0, FREQ_HZ 10000000, HAS_TKEEP 0, HAS_TLAST 0, HAS_TREADY 1, HAS_TSTRB 0, INSERT_VIP 0, LAYERED_METADATA undef, PHASE 0.000, TDATA_NUM_BYTES 1, TDEST_WIDTH 0, TID_WIDTH 0, TUSER_WIDTH 0";
begin
  M_AXIS_RESULT_0_tdata(31 downto 0) <= floating_point_0_M_AXIS_RESULT_TDATA(31 downto 0);
  M_AXIS_RESULT_0_tvalid <= floating_point_0_M_AXIS_RESULT_TVALID;
  S_AXIS_A_0_1_TDATA(31 downto 0) <= S_AXIS_A_0_tdata(31 downto 0);
  S_AXIS_A_0_1_TVALID <= S_AXIS_A_0_tvalid;
  S_AXIS_A_0_tready <= S_AXIS_A_0_1_TREADY;
  S_AXIS_B_0_1_TDATA(31 downto 0) <= S_AXIS_B_0_tdata(31 downto 0);
  S_AXIS_B_0_1_TVALID <= S_AXIS_B_0_tvalid;
  S_AXIS_B_0_tready <= S_AXIS_B_0_1_TREADY;
  S_AXIS_C_0_1_TDATA(31 downto 0) <= S_AXIS_C_0_tdata(31 downto 0);
  S_AXIS_C_0_1_TVALID <= S_AXIS_C_0_tvalid;
  S_AXIS_C_0_tready <= S_AXIS_C_0_1_TREADY;
  S_AXIS_OPERATION_0_1_TDATA(7 downto 0) <= S_AXIS_OPERATION_0_tdata(7 downto 0);
  S_AXIS_OPERATION_0_1_TVALID <= S_AXIS_OPERATION_0_tvalid;
  S_AXIS_OPERATION_0_tready <= S_AXIS_OPERATION_0_1_TREADY;
  aclk_0_1 <= aclk_0;
  floating_point_0_M_AXIS_RESULT_TREADY <= M_AXIS_RESULT_0_tready;
floating_point_0: component design_MAC_floating_point_0_0
     port map (
      aclk => aclk_0_1,
      m_axis_result_tdata(31 downto 0) => floating_point_0_M_AXIS_RESULT_TDATA(31 downto 0),
      m_axis_result_tready => floating_point_0_M_AXIS_RESULT_TREADY,
      m_axis_result_tvalid => floating_point_0_M_AXIS_RESULT_TVALID,
      s_axis_a_tdata(31 downto 0) => S_AXIS_A_0_1_TDATA(31 downto 0),
      s_axis_a_tready => S_AXIS_A_0_1_TREADY,
      s_axis_a_tvalid => S_AXIS_A_0_1_TVALID,
      s_axis_b_tdata(31 downto 0) => S_AXIS_B_0_1_TDATA(31 downto 0),
      s_axis_b_tready => S_AXIS_B_0_1_TREADY,
      s_axis_b_tvalid => S_AXIS_B_0_1_TVALID,
      s_axis_c_tdata(31 downto 0) => S_AXIS_C_0_1_TDATA(31 downto 0),
      s_axis_c_tready => S_AXIS_C_0_1_TREADY,
      s_axis_c_tvalid => S_AXIS_C_0_1_TVALID,
      s_axis_operation_tdata(7 downto 0) => S_AXIS_OPERATION_0_1_TDATA(7 downto 0),
      s_axis_operation_tready => S_AXIS_OPERATION_0_1_TREADY,
      s_axis_operation_tvalid => S_AXIS_OPERATION_0_1_TVALID
    );
end STRUCTURE;
