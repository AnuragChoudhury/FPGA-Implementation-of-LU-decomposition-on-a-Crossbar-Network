
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.types.all;

entity LUDHardware is
    generic(
        ADDR_WIDTH : integer := 12; --BRAM Address width
        CTRL_WIDTH : integer := 80;
        AU_SEL_WIDTH : integer := 3;
        BRAM_SEL_WIDTH : integer := 3
    );
    port(
        CLK_100 : in std_logic;
        locked : in std_logic;
        CTRL_Signal : in std_logic_vector(CTRL_WIDTH-1 downto 0);
        
        --These ports will be connected to the ZYNQ processing system
        bram_ZYNQ_block_A_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_A_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_A_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_A_en : in std_logic;
        bram_ZYNQ_block_A_we : in std_logic;
                
        bram_ZYNQ_block_B_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_B_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_B_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_B_en : in std_logic;
        bram_ZYNQ_block_B_we : in std_logic;
        
        bram_ZYNQ_block_C_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_C_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_C_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_C_en : in std_logic;
        bram_ZYNQ_block_C_we : in std_logic;
        
        bram_ZYNQ_block_D_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_D_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_D_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_D_en : in std_logic;
        bram_ZYNQ_block_D_we : in std_logic;
        
        bram_ZYNQ_sel : in std_logic
        
    );
end entity;

architecture yoStyle of LUDHardware is

    --Component decleration ********************************************************************************************************************************************************************
    component design_BRAM_A_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 11 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
        BRAM_PORTA_0_en : in STD_LOGIC;
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component design_BRAM_A_wrapper;
    
    component design_MAC_wrapper is
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
    end component design_MAC_wrapper;
    
    component design_DIV_wrapper is
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
        aclk : in STD_LOGIC
    );
    end component design_DIV_wrapper;
    --Component decleration ends ****************************************************************************************************************************************************************


    signal RST : std_logic;

    signal inputLocations : dataArray(6 downto 0);


    signal block_A_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_A_porta_din  : std_logic_vector(31 downto 0);
    signal block_A_porta_dout : std_logic_vector(31 downto 0);
    signal block_A_porta_en   : std_logic;
    signal block_A_porta_we   : std_logic;

    signal block_B_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_B_porta_din  : std_logic_vector(31 downto 0);
    signal block_B_porta_dout : std_logic_vector(31 downto 0);
    signal block_B_porta_en   : std_logic;
    signal block_B_porta_we   : std_logic;

    signal block_C_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_C_porta_din  : std_logic_vector(31 downto 0);
    signal block_C_porta_dout : std_logic_vector(31 downto 0);
    signal block_C_porta_en   : std_logic;
    signal block_C_porta_we   : std_logic;

    signal block_D_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_D_porta_din  : std_logic_vector(31 downto 0);
    signal block_D_porta_dout : std_logic_vector(31 downto 0);
    signal block_D_porta_en   : std_logic;
    signal block_D_porta_we   : std_logic;

    signal mac_A_result_tdata : std_logic_vector(31 downto 0);
    signal mac_A_result_tready : std_logic;
    signal mac_A_result_tvalid : std_logic;

    signal mac_A_a_tdata : std_logic_vector(31 downto 0);
    signal mac_A_a_tready : std_logic;
    signal mac_A_a_tvalid : std_logic;

    signal mac_A_b_tdata : std_logic_vector(31 downto 0);
    signal mac_A_b_tready : std_logic;
    signal mac_A_b_tvalid : std_logic;

    signal mac_A_c_tdata : std_logic_vector(31 downto 0);
    signal mac_A_c_tready : std_logic;
    signal mac_A_c_tvalid : std_logic;

    signal mac_A_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_A_operation_tready : std_logic;
    signal mac_A_operation_tvalid : std_logic;
    signal mac_A_a_signInv : std_logic;
    signal mac_A_a_tdataIN : std_logic_vector(31 downto 0);

    signal div_A_result_tdata : std_logic_vector(31 downto 0);
    signal div_A_result_tready : std_logic;
    signal div_A_result_tvalid : std_logic;

    signal div_A_a_tdata : std_logic_vector(31 downto 0);
    signal div_A_a_tready : std_logic;
    signal div_A_a_tvalid : std_logic;

    signal div_A_b_tdata : std_logic_vector(31 downto 0);
    signal div_A_b_tready : std_logic;
    signal div_A_b_tvalid : std_logic;

    signal mac_A_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_A_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_A_c_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal div_A_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal div_A_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal block_A_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_B_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal block_C_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_D_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    --Mux signals for connection to ZYNQ system
    signal bram_mux_out_block_A_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_A_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_A : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_A_en : std_logic;
    signal bram_mux_out_block_A_we : std_logic;
    
    signal bram_mux_out_block_B_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_B_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_B : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_B_en : std_logic;
    signal bram_mux_out_block_B_we : std_logic;
    
    signal bram_mux_out_block_C_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_C_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_C : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_C_en : std_logic;
    signal bram_mux_out_block_C_we : std_logic;
    
    signal bram_mux_out_block_D_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_D_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_D : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_D_en : std_logic;
    signal bram_mux_out_block_D_we : std_logic;

begin

    block_A : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_A_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_A_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_A,
        BRAM_PORTA_0_en       => bram_mux_out_block_A_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_A_we
    );
    
    bram_ZYNQ_mux_A : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_A_addr,
          bram_din_0 => bram_ZYNQ_block_A_din,
          bram_en_0 => bram_ZYNQ_block_A_en,
          bram_we_0 => bram_ZYNQ_block_A_we,
          bram_addr_1 => block_A_porta_addr,
          bram_din_1 => block_A_porta_din,
          bram_en_1 => block_A_porta_en,
          bram_we_1 => block_A_porta_we,
          bram_addr_out => bram_mux_out_block_A_addr,
          bram_din_out => bram_mux_out_block_A_din,
          bram_en_out => bram_mux_out_block_A_en,
          bram_we_out => bram_mux_out_block_A_we,
          sel => bram_ZYNQ_sel
          );
    bram_ZYNQ_decoder_A :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_A,
          decoder_out_0 => bram_ZYNQ_block_A_dout,
          decoder_out_1 => block_A_porta_dout,
          sel => bram_ZYNQ_sel
          );

    block_B : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_B_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_B_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_B,
        BRAM_PORTA_0_en       => bram_mux_out_block_B_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_B_we
    );
    
    bram_ZYNQ_mux_B : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_B_addr,
        bram_din_0 => bram_ZYNQ_block_B_din,
        bram_en_0 => bram_ZYNQ_block_B_en,
        bram_we_0 => bram_ZYNQ_block_B_we,
        bram_addr_1 => block_B_porta_addr,
        bram_din_1 => block_B_porta_din,
        bram_en_1 => block_B_porta_en,
        bram_we_1 => block_B_porta_we,
        bram_addr_out => bram_mux_out_block_B_addr,
        bram_din_out => bram_mux_out_block_B_din,
        bram_en_out => bram_mux_out_block_B_en,
        bram_we_out => bram_mux_out_block_B_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_B :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_B,
        decoder_out_0 => bram_ZYNQ_block_B_dout,
        decoder_out_1 => block_B_porta_dout,
        sel => bram_ZYNQ_sel
        );

    block_C : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_C_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_C_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_C,
        BRAM_PORTA_0_en       => bram_mux_out_block_C_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_C_we
    );
  
    bram_ZYNQ_mux_C : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_C_addr,
        bram_din_0 => bram_ZYNQ_block_C_din,
        bram_en_0 => bram_ZYNQ_block_C_en,
        bram_we_0 => bram_ZYNQ_block_C_we,
        bram_addr_1 => block_C_porta_addr,
        bram_din_1 => block_C_porta_din,
        bram_en_1 => block_C_porta_en,
        bram_we_1 => block_C_porta_we,
        bram_addr_out => bram_mux_out_block_C_addr,
        bram_din_out => bram_mux_out_block_C_din,
        bram_en_out => bram_mux_out_block_C_en,
        bram_we_out => bram_mux_out_block_C_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_C :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_C,
        decoder_out_0 => bram_ZYNQ_block_C_dout,
        decoder_out_1 => block_C_porta_dout,
        sel => bram_ZYNQ_sel
        );


    block_D : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_D_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_D_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_D,
        BRAM_PORTA_0_en       => bram_mux_out_block_D_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_D_we
    );
    bram_ZYNQ_mux_D : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_D_addr,
        bram_din_0 => bram_ZYNQ_block_D_din,
        bram_en_0 => bram_ZYNQ_block_D_en,
        bram_we_0 => bram_ZYNQ_block_D_we,
        bram_addr_1 => block_D_porta_addr,
        bram_din_1 => block_D_porta_din,
        bram_en_1 => block_D_porta_en,
        bram_we_1 => block_D_porta_we,
        bram_addr_out => bram_mux_out_block_D_addr,
        bram_din_out => bram_mux_out_block_D_din,
        bram_en_out => bram_mux_out_block_D_en,
        bram_we_out => bram_mux_out_block_D_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_D :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_D,
        decoder_out_0 => bram_ZYNQ_block_D_dout,
        decoder_out_1 => block_D_porta_dout,
        sel => bram_ZYNQ_sel
        );

    MAC_A : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_tdata => mac_A_result_tdata,
        M_AXIS_RESULT_tready => mac_A_result_tready,
        M_AXIS_RESULT_tvalid => mac_A_result_tvalid,
        S_AXIS_A_tdata => mac_A_a_tdata,
        S_AXIS_A_tready => mac_A_a_tready,
        S_AXIS_A_tvalid => mac_A_a_tvalid,
        S_AXIS_B_tdata => mac_A_b_tdata,
        S_AXIS_B_tready => mac_A_b_tready,
        S_AXIS_B_tvalid => mac_A_b_tvalid,
        S_AXIS_C_tdata => mac_A_c_tdata,
        S_AXIS_C_tready => mac_A_c_tready,
        S_AXIS_C_tvalid => mac_A_c_tvalid,
        S_AXIS_OPERATION_tdata => mac_A_operation_tdata,
        S_AXIS_OPERATION_tready => mac_A_operation_tready,
        S_AXIS_OPERATION_tvalid => mac_A_operation_tvalid,
        aclk   => CLK_100
    );

    DIV_A : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_tdata => div_A_result_tdata,
        M_AXIS_RESULT_tready => div_A_result_tready,
        M_AXIS_RESULT_tvalid => div_A_result_tvalid,
        S_AXIS_A_tdata => div_A_a_tdata,
        S_AXIS_A_tready => div_A_a_tready,
        S_AXIS_A_tvalid => div_A_a_tvalid,
        S_AXIS_B_tdata => div_A_b_tdata,
        S_AXIS_B_tready => div_A_b_tready,
        S_AXIS_B_tvalid => div_A_b_tvalid,
        aclk   => CLK_100
    );

 -- input locations
    inputLocations(0) <= mac_A_result_tdata;
    inputLocations(1) <= div_A_result_tdata;
    inputLocations(2) <= block_A_porta_dout;
    inputLocations(3) <= block_B_porta_dout;
    inputLocations(4) <= block_C_porta_dout;
    inputLocations(5) <= block_D_porta_dout;
    inputLocations(6) <= (others => '0');
        
    MUX_MAC_IN_A_b : entity MUX_AU_IN
    port map(
        SEL => mac_A_b_sel,
        DIN => inputLocations,
        DOUT => mac_A_b_tdata
    );

    MUX_MAC_IN_A_c : entity MUX_AU_IN
    port map(
        SEL => mac_A_c_sel,
        DIN => inputLocations,
        DOUT => mac_A_c_tdata
    );

    MUX_MAC_IN_A_a : entity MUX_AU_IN
    port map(
        SEL => mac_A_a_sel,
        DIN => inputLocations,
        DOUT => mac_A_a_tdataIN
    );

    mac_A_a_signInv <= not mac_A_a_tdataIN(31);
    mac_A_a_tdata <= mac_A_a_signInv & mac_A_a_tdataIN(30 downto 0);

    MUX_DIV_IN_A_a : entity MUX_AU_IN
    port map(
        SEL => div_A_a_sel,
        DIN => inputLocations,
        DOUT => div_A_a_tdata
    );

    MUX_DIV_IN_A_b : entity MUX_AU_IN
    port map(
        SEL => div_A_b_sel,
        DIN => inputLocations,
        DOUT => div_A_b_tdata
    );

    MUX_BRAM_A_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_A_a_sel,
        DIN => inputLocations(5 downto 0),
        DOUT => block_A_porta_din
    );

    MUX_BRAM_B_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_B_a_sel,
        DIN => inputLocations(5 downto 0),
        DOUT => block_B_porta_din
    );

    MUX_BRAM_C_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_C_a_sel,
        DIN => inputLocations(5 downto 0),
        DOUT => block_C_porta_din
    );

    MUX_BRAM_D_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_D_a_sel,
        DIN => inputLocations(5 downto 0),
        DOUT => block_D_porta_din
    );

    block_A_porta_addr <= CTRL_Signal(CTRL_WIDTH-1 downto CTRL_WIDTH-ADDR_WIDTH);
    block_A_porta_we <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-1);
    block_B_porta_addr <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-2 downto CTRL_WIDTH-2*ADDR_WIDTH-1);
    block_B_porta_we <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-2);
    block_C_porta_addr <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-3 downto CTRL_WIDTH-3*ADDR_WIDTH-2);
    block_C_porta_we <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-3);
    block_D_porta_addr <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-4 downto CTRL_WIDTH-4*ADDR_WIDTH-3);
    block_D_porta_we <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-4);
    mac_A_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-AU_SEL_WIDTH-4);
    mac_A_b_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-AU_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-2*AU_SEL_WIDTH-4);
    mac_A_c_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-2*AU_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-3*AU_SEL_WIDTH-4);
    div_A_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-3*AU_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-4*AU_SEL_WIDTH-4);
    div_A_b_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-4*AU_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-4);
    block_A_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-BRAM_SEL_WIDTH-4);
    block_B_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-BRAM_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-4);
    block_C_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-4);
    block_D_a_sel <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-5 downto CTRL_WIDTH-4*ADDR_WIDTH-5*AU_SEL_WIDTH-4*BRAM_SEL_WIDTH-4);
    
--  CTRL_Signal(0) is actually a complete signal which is required by this module during debugging
    block_A_porta_en <= locked;
    block_B_porta_en <= locked;
    block_C_porta_en <= locked;
    block_D_porta_en <= locked;

    RST <= not locked;

    mac_A_a_tvalid <= locked;
    mac_A_b_tvalid <= locked;
    mac_A_c_tvalid <= locked;
    mac_A_operation_tvalid <= locked;
    mac_A_operation_tdata <= "00000000"; --Indicates substraction(AB-C). 1 indicates addition(AB+C)
    mac_A_result_tready <= locked;

    div_A_a_tvalid <= locked;
    div_A_b_tvalid <= locked;
    div_A_result_tready <= locked;

end architecture;
