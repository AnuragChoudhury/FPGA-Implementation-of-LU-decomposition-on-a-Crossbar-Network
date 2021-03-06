--Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
--Date        : Thu Apr 23 23:19:51 2020
--Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
--Command     : generate_target design_BRAM_D.bd
--Design      : design_BRAM_D
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity design_BRAM_D is
  port (
    BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    BRAM_PORTA_0_clk : in STD_LOGIC;
    BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTA_0_en : in STD_LOGIC;
    BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
    BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 9 downto 0 );
    BRAM_PORTB_0_clk : in STD_LOGIC;
    BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    BRAM_PORTB_0_en : in STD_LOGIC;
    BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
  );
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of design_BRAM_D : entity is "design_BRAM_D,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=design_BRAM_D,x_ipVersion=1.00.a,x_ipLanguage=VHDL,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=0,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}";
  attribute HW_HANDOFF : string;
  attribute HW_HANDOFF of design_BRAM_D : entity is "design_BRAM_D.hwdef";
end design_BRAM_D;

architecture STRUCTURE of design_BRAM_D is
  component design_BRAM_D_blk_mem_gen_0_0 is
  port (
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 31 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 31 downto 0 );
    clkb : in STD_LOGIC;
    enb : in STD_LOGIC;
    web : in STD_LOGIC_VECTOR ( 0 to 0 );
    addrb : in STD_LOGIC_VECTOR ( 9 downto 0 );
    dinb : in STD_LOGIC_VECTOR ( 31 downto 0 );
    doutb : out STD_LOGIC_VECTOR ( 31 downto 0 )
  );
  end component design_BRAM_D_blk_mem_gen_0_0;
  signal BRAM_PORTA_0_1_ADDR : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal BRAM_PORTA_0_1_CLK : STD_LOGIC;
  signal BRAM_PORTA_0_1_DIN : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTA_0_1_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTA_0_1_EN : STD_LOGIC;
  signal BRAM_PORTA_0_1_WE : STD_LOGIC_VECTOR ( 0 to 0 );
  signal BRAM_PORTB_0_1_ADDR : STD_LOGIC_VECTOR ( 9 downto 0 );
  signal BRAM_PORTB_0_1_CLK : STD_LOGIC;
  signal BRAM_PORTB_0_1_DIN : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTB_0_1_DOUT : STD_LOGIC_VECTOR ( 31 downto 0 );
  signal BRAM_PORTB_0_1_EN : STD_LOGIC;
  signal BRAM_PORTB_0_1_WE : STD_LOGIC_VECTOR ( 0 to 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_clk : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 CLK";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 EN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_clk : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 CLK";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_en : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 EN";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 ADDR";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of BRAM_PORTA_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTA_0, MASTER_TYPE OTHER, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTA_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTA_0 WE";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_addr : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 ADDR";
  attribute X_INTERFACE_PARAMETER of BRAM_PORTB_0_addr : signal is "XIL_INTERFACENAME BRAM_PORTB_0, MASTER_TYPE OTHER, MEM_ECC NONE, MEM_SIZE 8192, MEM_WIDTH 32, READ_LATENCY 1";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_din : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DIN";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_dout : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 DOUT";
  attribute X_INTERFACE_INFO of BRAM_PORTB_0_we : signal is "xilinx.com:interface:bram:1.0 BRAM_PORTB_0 WE";
begin
  BRAM_PORTA_0_1_ADDR(9 downto 0) <= BRAM_PORTA_0_addr(9 downto 0);
  BRAM_PORTA_0_1_CLK <= BRAM_PORTA_0_clk;
  BRAM_PORTA_0_1_DIN(31 downto 0) <= BRAM_PORTA_0_din(31 downto 0);
  BRAM_PORTA_0_1_EN <= BRAM_PORTA_0_en;
  BRAM_PORTA_0_1_WE(0) <= BRAM_PORTA_0_we(0);
  BRAM_PORTA_0_dout(31 downto 0) <= BRAM_PORTA_0_1_DOUT(31 downto 0);
  BRAM_PORTB_0_1_ADDR(9 downto 0) <= BRAM_PORTB_0_addr(9 downto 0);
  BRAM_PORTB_0_1_CLK <= BRAM_PORTB_0_clk;
  BRAM_PORTB_0_1_DIN(31 downto 0) <= BRAM_PORTB_0_din(31 downto 0);
  BRAM_PORTB_0_1_EN <= BRAM_PORTB_0_en;
  BRAM_PORTB_0_1_WE(0) <= BRAM_PORTB_0_we(0);
  BRAM_PORTB_0_dout(31 downto 0) <= BRAM_PORTB_0_1_DOUT(31 downto 0);
blk_mem_gen_0: component design_BRAM_D_blk_mem_gen_0_0
     port map (
      addra(9 downto 0) => BRAM_PORTA_0_1_ADDR(9 downto 0),
      addrb(9 downto 0) => BRAM_PORTB_0_1_ADDR(9 downto 0),
      clka => BRAM_PORTA_0_1_CLK,
      clkb => BRAM_PORTB_0_1_CLK,
      dina(31 downto 0) => BRAM_PORTA_0_1_DIN(31 downto 0),
      dinb(31 downto 0) => BRAM_PORTB_0_1_DIN(31 downto 0),
      douta(31 downto 0) => BRAM_PORTA_0_1_DOUT(31 downto 0),
      doutb(31 downto 0) => BRAM_PORTB_0_1_DOUT(31 downto 0),
      ena => BRAM_PORTA_0_1_EN,
      enb => BRAM_PORTB_0_1_EN,
      wea(0) => BRAM_PORTA_0_1_WE(0),
      web(0) => BRAM_PORTB_0_1_WE(0)
    );
end STRUCTURE;
