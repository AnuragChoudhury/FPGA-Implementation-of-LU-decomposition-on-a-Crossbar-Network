
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.types.all;

entity LUDHardware is
    generic(
        ADDR_WIDTH : integer := 11;
        CTRL_WIDTH : integer := 373;
        AU_SEL_WIDTH : integer := 5;
        BRAM_SEL_WIDTH : integer := 5
    );
    port(
        CLK_100 : in std_logic;
        CLK_200 : in std_logic;
        locked : in std_logic;
        CTRL_Signal : in std_logic_vector(CTRL_WIDTH-1 downto 0);
        
        --These ports will be connected to the ZYNQ processing system
        bram_ZYNQ_block_A_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_A_din : in std_logic_vector(63 downto 0);
        bram_ZYNQ_block_A_dout : out std_logic_vector(63 downto 0);
        bram_ZYNQ_block_A_en : in std_logic;
        bram_ZYNQ_block_A_we : in std_logic;
                
        bram_ZYNQ_block_B_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_B_din : in std_logic_vector(63 downto 0);
        bram_ZYNQ_block_B_dout : out std_logic_vector(63 downto 0);
        bram_ZYNQ_block_B_en : in std_logic;
        bram_ZYNQ_block_B_we : in std_logic;
        
        bram_ZYNQ_block_C_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_C_din : in std_logic_vector(63 downto 0);
        bram_ZYNQ_block_C_dout : out std_logic_vector(63 downto 0);
        bram_ZYNQ_block_C_en : in std_logic;
        bram_ZYNQ_block_C_we : in std_logic;
        
        bram_ZYNQ_block_D_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_D_din : in std_logic_vector(63 downto 0);
        bram_ZYNQ_block_D_dout : out std_logic_vector(63 downto 0);
        bram_ZYNQ_block_D_en : in std_logic;
        bram_ZYNQ_block_D_we : in std_logic;
        
        bram_ZYNQ_sel : in std_logic
        
    );
end entity;

architecture yoStyle of LUDHardware is

    --Component decleration ********************************************************************************************************************************************************************
    component design_BRAM_A_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTA_0_en : in STD_LOGIC;
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 );
        BRAM_PORTB_0_addr : in STD_LOGIC_VECTOR ( 10 downto 0 );
        BRAM_PORTB_0_clk : in STD_LOGIC;
        BRAM_PORTB_0_din : in STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTB_0_dout : out STD_LOGIC_VECTOR ( 63 downto 0 );
        BRAM_PORTB_0_en : in STD_LOGIC;
        BRAM_PORTB_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component design_BRAM_A_wrapper;
    
    component design_MAC_wrapper is
    port (
        M_AXIS_RESULT_0_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
        M_AXIS_RESULT_0_tready : in STD_LOGIC;
        M_AXIS_RESULT_0_tvalid : out STD_LOGIC;
        S_AXIS_A_0_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
        S_AXIS_A_0_tready : out STD_LOGIC;
        S_AXIS_A_0_tvalid : in STD_LOGIC;
        S_AXIS_B_0_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
        S_AXIS_B_0_tready : out STD_LOGIC;
        S_AXIS_B_0_tvalid : in STD_LOGIC;
        S_AXIS_C_0_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
        S_AXIS_C_0_tready : out STD_LOGIC;
        S_AXIS_C_0_tvalid : in STD_LOGIC;
        S_AXIS_OPERATION_0_tdata : in STD_LOGIC_VECTOR ( 7 downto 0 );
        S_AXIS_OPERATION_0_tready : out STD_LOGIC;
        S_AXIS_OPERATION_0_tvalid : in STD_LOGIC;
        aclk_0 : in STD_LOGIC
    );
    end component design_MAC_wrapper;
    
    component design_DIV_wrapper is
    port (
        M_AXIS_RESULT_0_tdata : out STD_LOGIC_VECTOR ( 63 downto 0 );
        M_AXIS_RESULT_0_tready : in STD_LOGIC;
        M_AXIS_RESULT_0_tvalid : out STD_LOGIC;
        S_AXIS_A_0_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
        S_AXIS_A_0_tready : out STD_LOGIC;
        S_AXIS_A_0_tvalid : in STD_LOGIC;
        S_AXIS_B_0_tdata : in STD_LOGIC_VECTOR ( 63 downto 0 );
        S_AXIS_B_0_tready : out STD_LOGIC;
        S_AXIS_B_0_tvalid : in STD_LOGIC;
        aclk_0 : in STD_LOGIC
    );
    end component design_DIV_wrapper;
    
    --Component decleration ends ****************************************************************************************************************************************************************

    signal RST : std_logic;

    signal inputLocations : dataArray(24 downto 0);


    signal block_A_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_A_porta_din  : std_logic_vector(63 downto 0);
    signal block_A_porta_dout : std_logic_vector(63 downto 0);
    signal block_A_porta_en   : std_logic;
    signal block_A_porta_we   : std_logic;

    signal block_A_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_A_portb_din  : std_logic_vector(63 downto 0);
    signal block_A_portb_dout : std_logic_vector(63 downto 0);
    signal block_A_portb_en   : std_logic;
    signal block_A_portb_we   : std_logic;

    signal bram_A_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_A_porta_din  : std_logic_vector(63 downto 0);
    signal bram_A_porta_dout : std_logic_vector(63 downto 0);
    signal bram_A_porta_en   : std_logic;
    signal bram_A_porta_we   : std_logic;

    signal bram_A_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_A_portb_din  : std_logic_vector(63 downto 0);
    signal bram_A_portb_dout : std_logic_vector(63 downto 0);
    signal bram_A_portb_en   : std_logic;
    signal bram_A_portb_we   : std_logic;

    signal bram_A_portc_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_A_portc_din  : std_logic_vector(63 downto 0);
    signal bram_A_portc_dout : std_logic_vector(63 downto 0);
    signal bram_A_portc_en   : std_logic;
    signal bram_A_portc_we   : std_logic;

    signal bram_A_portd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_A_portd_din  : std_logic_vector(63 downto 0);
    signal bram_A_portd_dout : std_logic_vector(63 downto 0);
    signal bram_A_portd_en   : std_logic;
    signal bram_A_portd_we   : std_logic;

    signal block_B_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_B_porta_din  : std_logic_vector(63 downto 0);
    signal block_B_porta_dout : std_logic_vector(63 downto 0);
    signal block_B_porta_en   : std_logic;
    signal block_B_porta_we   : std_logic;

    signal block_B_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_B_portb_din  : std_logic_vector(63 downto 0);
    signal block_B_portb_dout : std_logic_vector(63 downto 0);
    signal block_B_portb_en   : std_logic;
    signal block_B_portb_we   : std_logic;

    signal bram_B_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_B_porta_din  : std_logic_vector(63 downto 0);
    signal bram_B_porta_dout : std_logic_vector(63 downto 0);
    signal bram_B_porta_en   : std_logic;
    signal bram_B_porta_we   : std_logic;

    signal bram_B_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_B_portb_din  : std_logic_vector(63 downto 0);
    signal bram_B_portb_dout : std_logic_vector(63 downto 0);
    signal bram_B_portb_en   : std_logic;
    signal bram_B_portb_we   : std_logic;

    signal bram_B_portc_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_B_portc_din  : std_logic_vector(63 downto 0);
    signal bram_B_portc_dout : std_logic_vector(63 downto 0);
    signal bram_B_portc_en   : std_logic;
    signal bram_B_portc_we   : std_logic;

    signal bram_B_portd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_B_portd_din  : std_logic_vector(63 downto 0);
    signal bram_B_portd_dout : std_logic_vector(63 downto 0);
    signal bram_B_portd_en   : std_logic;
    signal bram_B_portd_we   : std_logic;

    signal block_C_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_C_porta_din  : std_logic_vector(63 downto 0);
    signal block_C_porta_dout : std_logic_vector(63 downto 0);
    signal block_C_porta_en   : std_logic;
    signal block_C_porta_we   : std_logic;

    signal block_C_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_C_portb_din  : std_logic_vector(63 downto 0);
    signal block_C_portb_dout : std_logic_vector(63 downto 0);
    signal block_C_portb_en   : std_logic;
    signal block_C_portb_we   : std_logic;

    signal bram_C_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_C_porta_din  : std_logic_vector(63 downto 0);
    signal bram_C_porta_dout : std_logic_vector(63 downto 0);
    signal bram_C_porta_en   : std_logic;
    signal bram_C_porta_we   : std_logic;

    signal bram_C_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_C_portb_din  : std_logic_vector(63 downto 0);
    signal bram_C_portb_dout : std_logic_vector(63 downto 0);
    signal bram_C_portb_en   : std_logic;
    signal bram_C_portb_we   : std_logic;

    signal bram_C_portc_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_C_portc_din  : std_logic_vector(63 downto 0);
    signal bram_C_portc_dout : std_logic_vector(63 downto 0);
    signal bram_C_portc_en   : std_logic;
    signal bram_C_portc_we   : std_logic;

    signal bram_C_portd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_C_portd_din  : std_logic_vector(63 downto 0);
    signal bram_C_portd_dout : std_logic_vector(63 downto 0);
    signal bram_C_portd_en   : std_logic;
    signal bram_C_portd_we   : std_logic;

    signal block_D_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_D_porta_din  : std_logic_vector(63 downto 0);
    signal block_D_porta_dout : std_logic_vector(63 downto 0);
    signal block_D_porta_en   : std_logic;
    signal block_D_porta_we   : std_logic;

    signal block_D_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_D_portb_din  : std_logic_vector(63 downto 0);
    signal block_D_portb_dout : std_logic_vector(63 downto 0);
    signal block_D_portb_en   : std_logic;
    signal block_D_portb_we   : std_logic;

    signal bram_D_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_D_porta_din  : std_logic_vector(63 downto 0);
    signal bram_D_porta_dout : std_logic_vector(63 downto 0);
    signal bram_D_porta_en   : std_logic;
    signal bram_D_porta_we   : std_logic;

    signal bram_D_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_D_portb_din  : std_logic_vector(63 downto 0);
    signal bram_D_portb_dout : std_logic_vector(63 downto 0);
    signal bram_D_portb_en   : std_logic;
    signal bram_D_portb_we   : std_logic;

    signal bram_D_portc_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_D_portc_din  : std_logic_vector(63 downto 0);
    signal bram_D_portc_dout : std_logic_vector(63 downto 0);
    signal bram_D_portc_en   : std_logic;
    signal bram_D_portc_we   : std_logic;

    signal bram_D_portd_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal bram_D_portd_din  : std_logic_vector(63 downto 0);
    signal bram_D_portd_dout : std_logic_vector(63 downto 0);
    signal bram_D_portd_en   : std_logic;
    signal bram_D_portd_we   : std_logic;

    signal mac_A_result_tdata : std_logic_vector(63 downto 0);
    signal mac_A_result_tready : std_logic;
    signal mac_A_result_tvalid : std_logic;

    signal mac_A_a_tdata : std_logic_vector(63 downto 0);
    signal mac_A_a_tready : std_logic;
    signal mac_A_a_tvalid : std_logic;

    signal mac_A_b_tdata : std_logic_vector(63 downto 0);
    signal mac_A_b_tready : std_logic;
    signal mac_A_b_tvalid : std_logic;

    signal mac_A_c_tdata : std_logic_vector(63 downto 0);
    signal mac_A_c_tready : std_logic;
    signal mac_A_c_tvalid : std_logic;

    signal mac_A_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_A_operation_tready : std_logic;
    signal mac_A_operation_tvalid : std_logic;
    signal mac_A_a_signInv : std_logic;
    signal mac_A_a_tdataIN : std_logic_vector(63 downto 0);

    signal mac_B_result_tdata : std_logic_vector(63 downto 0);
    signal mac_B_result_tready : std_logic;
    signal mac_B_result_tvalid : std_logic;

    signal mac_B_a_tdata : std_logic_vector(63 downto 0);
    signal mac_B_a_tready : std_logic;
    signal mac_B_a_tvalid : std_logic;

    signal mac_B_b_tdata : std_logic_vector(63 downto 0);
    signal mac_B_b_tready : std_logic;
    signal mac_B_b_tvalid : std_logic;

    signal mac_B_c_tdata : std_logic_vector(63 downto 0);
    signal mac_B_c_tready : std_logic;
    signal mac_B_c_tvalid : std_logic;

    signal mac_B_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_B_operation_tready : std_logic;
    signal mac_B_operation_tvalid : std_logic;
    signal mac_B_a_signInv : std_logic;
    signal mac_B_a_tdataIN : std_logic_vector(63 downto 0);

    signal mac_C_result_tdata : std_logic_vector(63 downto 0);
    signal mac_C_result_tready : std_logic;
    signal mac_C_result_tvalid : std_logic;

    signal mac_C_a_tdata : std_logic_vector(63 downto 0);
    signal mac_C_a_tready : std_logic;
    signal mac_C_a_tvalid : std_logic;

    signal mac_C_b_tdata : std_logic_vector(63 downto 0);
    signal mac_C_b_tready : std_logic;
    signal mac_C_b_tvalid : std_logic;

    signal mac_C_c_tdata : std_logic_vector(63 downto 0);
    signal mac_C_c_tready : std_logic;
    signal mac_C_c_tvalid : std_logic;

    signal mac_C_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_C_operation_tready : std_logic;
    signal mac_C_operation_tvalid : std_logic;
    signal mac_C_a_signInv : std_logic;
    signal mac_C_a_tdataIN : std_logic_vector(63 downto 0);

    signal mac_D_result_tdata : std_logic_vector(63 downto 0);
    signal mac_D_result_tready : std_logic;
    signal mac_D_result_tvalid : std_logic;

    signal mac_D_a_tdata : std_logic_vector(63 downto 0);
    signal mac_D_a_tready : std_logic;
    signal mac_D_a_tvalid : std_logic;

    signal mac_D_b_tdata : std_logic_vector(63 downto 0);
    signal mac_D_b_tready : std_logic;
    signal mac_D_b_tvalid : std_logic;

    signal mac_D_c_tdata : std_logic_vector(63 downto 0);
    signal mac_D_c_tready : std_logic;
    signal mac_D_c_tvalid : std_logic;

    signal mac_D_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_D_operation_tready : std_logic;
    signal mac_D_operation_tvalid : std_logic;
    signal mac_D_a_signInv : std_logic;
    signal mac_D_a_tdataIN : std_logic_vector(63 downto 0);

    signal div_A_result_tdata : std_logic_vector(63 downto 0);
    signal div_A_result_tready : std_logic;
    signal div_A_result_tvalid : std_logic;

    signal div_A_a_tdata : std_logic_vector(63 downto 0);
    signal div_A_a_tready : std_logic;
    signal div_A_a_tvalid : std_logic;

    signal div_A_b_tdata : std_logic_vector(63 downto 0);
    signal div_A_b_tready : std_logic;
    signal div_A_b_tvalid : std_logic;

    signal div_B_result_tdata : std_logic_vector(63 downto 0);
    signal div_B_result_tready : std_logic;
    signal div_B_result_tvalid : std_logic;

    signal div_B_a_tdata : std_logic_vector(63 downto 0);
    signal div_B_a_tready : std_logic;
    signal div_B_a_tvalid : std_logic;

    signal div_B_b_tdata : std_logic_vector(63 downto 0);
    signal div_B_b_tready : std_logic;
    signal div_B_b_tvalid : std_logic;

    signal div_C_result_tdata : std_logic_vector(63 downto 0);
    signal div_C_result_tready : std_logic;
    signal div_C_result_tvalid : std_logic;

    signal div_C_a_tdata : std_logic_vector(63 downto 0);
    signal div_C_a_tready : std_logic;
    signal div_C_a_tvalid : std_logic;

    signal div_C_b_tdata : std_logic_vector(63 downto 0);
    signal div_C_b_tready : std_logic;
    signal div_C_b_tvalid : std_logic;

    signal div_D_result_tdata : std_logic_vector(63 downto 0);
    signal div_D_result_tready : std_logic;
    signal div_D_result_tvalid : std_logic;

    signal div_D_a_tdata : std_logic_vector(63 downto 0);
    signal div_D_a_tready : std_logic;
    signal div_D_a_tvalid : std_logic;

    signal div_D_b_tdata : std_logic_vector(63 downto 0);
    signal div_D_b_tready : std_logic;
    signal div_D_b_tvalid : std_logic;

    signal mac_A_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_A_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_A_c_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal mac_B_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_B_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_B_c_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal mac_C_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_C_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_C_c_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal mac_D_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_D_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal mac_D_c_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal div_A_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal div_A_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal div_B_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal div_B_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal div_C_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal div_C_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal div_D_a_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);
    signal div_D_b_sel : std_logic_vector(AU_SEL_WIDTH-1 downto 0);

    signal bram_A_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_A_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_A_c_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_A_d_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal bram_B_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_B_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_B_c_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_B_d_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal bram_C_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_C_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_C_c_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_C_d_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal bram_D_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_D_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_D_c_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal bram_D_d_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    --Mux signals for connection to ZYNQ system
    signal bram_mux_out_block_A_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_A_din : std_logic_vector(63 downto 0);
    signal bram_decoder_in_block_A : std_logic_vector(63 downto 0);  
    signal bram_mux_out_block_A_en : std_logic;
    signal bram_mux_out_block_A_we : std_logic;
    signal bram_mux_out_block_A_clock : std_logic;
    
    signal bram_mux_out_block_B_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_B_din : std_logic_vector(63 downto 0);
    signal bram_decoder_in_block_B : std_logic_vector(63 downto 0);  
    signal bram_mux_out_block_B_en : std_logic;
    signal bram_mux_out_block_B_we : std_logic;
    signal bram_mux_out_block_B_clock : std_logic;
    
    signal bram_mux_out_block_C_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_C_din : std_logic_vector(63 downto 0);
    signal bram_decoder_in_block_C : std_logic_vector(63 downto 0);  
    signal bram_mux_out_block_C_en : std_logic;
    signal bram_mux_out_block_C_we : std_logic;
    signal bram_mux_out_block_C_clock : std_logic;
    
    signal bram_mux_out_block_D_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_D_din : std_logic_vector(63 downto 0);
    signal bram_decoder_in_block_D : std_logic_vector(63 downto 0);  
    signal bram_mux_out_block_D_en : std_logic;
    signal bram_mux_out_block_D_we : std_logic;
    signal bram_mux_out_block_D_clock : std_logic;

begin

    BRAM_A : entity quadPortBRAM
    generic map(ADDR_WIDTH, 64)
    port MAP(
        CLK_1X          => CLK_100,
        CLK_2X          => CLK_200,
        RST             => RST,

        BRAM_PORTA_ADDR    => bram_A_porta_addr,
        BRAM_PORTA_DIN     => bram_A_porta_din,
        BRAM_PORTA_DOUT    => bram_A_porta_dout,
        BRAM_PORTA_EN      => bram_A_porta_en,
        BRAM_PORTA_WE      => bram_A_porta_we,

        BRAM_PORTB_ADDR    => bram_A_portb_addr,
        BRAM_PORTB_DIN     => bram_A_portb_din,
        BRAM_PORTB_DOUT    => bram_A_portb_dout,
        BRAM_PORTB_EN      => bram_A_portb_en,
        BRAM_PORTB_WE      => bram_A_portb_we,

        BRAM_PORTC_ADDR    => bram_A_portc_addr,
        BRAM_PORTC_DIN     => bram_A_portc_din,
        BRAM_PORTC_DOUT    => bram_A_portc_dout,
        BRAM_PORTC_EN      => bram_A_portc_en,
        BRAM_PORTC_WE      => bram_A_portc_we,

        BRAM_PORTD_ADDR    => bram_A_portd_addr,
        BRAM_PORTD_DIN     => bram_A_portd_din,
        BRAM_PORTD_DOUT    => bram_A_portd_dout,
        BRAM_PORTD_EN      => bram_A_portd_en,
        BRAM_PORTD_WE      => bram_A_portd_we,

        BLOCK_PORTA_ADDR    => block_A_porta_addr,
        BLOCK_PORTA_DIN     => block_A_porta_din,
        BLOCK_PORTA_DOUT    => block_A_porta_dout,
        BLOCK_PORTA_EN      => block_A_porta_en,
        BLOCK_PORTA_WE      => block_A_porta_we,

        BLOCK_PORTB_ADDR    => block_A_portb_addr,
        BLOCK_PORTB_DIN     => block_A_portb_din,
        BLOCK_PORTB_DOUT    => block_A_portb_dout,
        BLOCK_PORTB_EN      => block_A_portb_en,
        BLOCK_PORTB_WE      => block_A_portb_we
    );


    block_A : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_A_addr,
        BRAM_PORTA_0_clk      => CLK_200,
        BRAM_PORTA_0_din      => bram_mux_out_block_A_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_A,
        BRAM_PORTA_0_en       => bram_mux_out_block_A_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_A_we,
        BRAM_PORTB_0_addr     => block_A_portb_addr,
        BRAM_PORTB_0_clk      => CLK_200,
        BRAM_PORTB_0_din      => block_A_portb_din,
        BRAM_PORTB_0_dout     => block_A_portb_dout,
        BRAM_PORTB_0_en       => block_A_portb_en,
        BRAM_PORTB_0_we(0)    => block_A_portb_we
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
    generic map (width => 64)
    port map(decoder_in => bram_decoder_in_block_A,
          decoder_out_0 => bram_ZYNQ_block_A_dout,
          decoder_out_1 => block_A_porta_dout,
          sel => bram_ZYNQ_sel
          );

    BRAM_B : entity quadPortBRAM
    generic map(ADDR_WIDTH, 64)
    port MAP(
        CLK_1X          => CLK_100,
        CLK_2X          => CLK_200,
        RST             => RST,

        BRAM_PORTA_ADDR    => bram_B_porta_addr,
        BRAM_PORTA_DIN     => bram_B_porta_din,
        BRAM_PORTA_DOUT    => bram_B_porta_dout,
        BRAM_PORTA_EN      => bram_B_porta_en,
        BRAM_PORTA_WE      => bram_B_porta_we,

        BRAM_PORTB_ADDR    => bram_B_portb_addr,
        BRAM_PORTB_DIN     => bram_B_portb_din,
        BRAM_PORTB_DOUT    => bram_B_portb_dout,
        BRAM_PORTB_EN      => bram_B_portb_en,
        BRAM_PORTB_WE      => bram_B_portb_we,

        BRAM_PORTC_ADDR    => bram_B_portc_addr,
        BRAM_PORTC_DIN     => bram_B_portc_din,
        BRAM_PORTC_DOUT    => bram_B_portc_dout,
        BRAM_PORTC_EN      => bram_B_portc_en,
        BRAM_PORTC_WE      => bram_B_portc_we,

        BRAM_PORTD_ADDR    => bram_B_portd_addr,
        BRAM_PORTD_DIN     => bram_B_portd_din,
        BRAM_PORTD_DOUT    => bram_B_portd_dout,
        BRAM_PORTD_EN      => bram_B_portd_en,
        BRAM_PORTD_WE      => bram_B_portd_we,

        BLOCK_PORTA_ADDR    => block_B_porta_addr,
        BLOCK_PORTA_DIN     => block_B_porta_din,
        BLOCK_PORTA_DOUT    => block_B_porta_dout,
        BLOCK_PORTA_EN      => block_B_porta_en,
        BLOCK_PORTA_WE      => block_B_porta_we,

        BLOCK_PORTB_ADDR    => block_B_portb_addr,
        BLOCK_PORTB_DIN     => block_B_portb_din,
        BLOCK_PORTB_DOUT    => block_B_portb_dout,
        BLOCK_PORTB_EN      => block_B_portb_en,
        BLOCK_PORTB_WE      => block_B_portb_we
    );


    block_B : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_B_addr,
        BRAM_PORTA_0_clk      => CLK_200,
        BRAM_PORTA_0_din      => bram_mux_out_block_B_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_B,
        BRAM_PORTA_0_en       => bram_mux_out_block_B_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_B_we,
        BRAM_PORTB_0_addr     => block_B_portb_addr,
        BRAM_PORTB_0_clk      => CLK_200,
        BRAM_PORTB_0_din      => block_B_portb_din,
        BRAM_PORTB_0_dout     => block_B_portb_dout,
        BRAM_PORTB_0_en       => block_B_portb_en,
        BRAM_PORTB_0_we(0)    => block_B_portb_we
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
    generic map (width => 64)
    port map(decoder_in => bram_decoder_in_block_B,
        decoder_out_0 => bram_ZYNQ_block_B_dout,
        decoder_out_1 => block_B_porta_dout,
        sel => bram_ZYNQ_sel
        );

    BRAM_C : entity quadPortBRAM
    generic map(ADDR_WIDTH, 64)
    port MAP(
        CLK_1X          => CLK_100,
        CLK_2X          => CLK_200,
        RST             => RST,

        BRAM_PORTA_ADDR    => bram_C_porta_addr,
        BRAM_PORTA_DIN     => bram_C_porta_din,
        BRAM_PORTA_DOUT    => bram_C_porta_dout,
        BRAM_PORTA_EN      => bram_C_porta_en,
        BRAM_PORTA_WE      => bram_C_porta_we,

        BRAM_PORTB_ADDR    => bram_C_portb_addr,
        BRAM_PORTB_DIN     => bram_C_portb_din,
        BRAM_PORTB_DOUT    => bram_C_portb_dout,
        BRAM_PORTB_EN      => bram_C_portb_en,
        BRAM_PORTB_WE      => bram_C_portb_we,

        BRAM_PORTC_ADDR    => bram_C_portc_addr,
        BRAM_PORTC_DIN     => bram_C_portc_din,
        BRAM_PORTC_DOUT    => bram_C_portc_dout,
        BRAM_PORTC_EN      => bram_C_portc_en,
        BRAM_PORTC_WE      => bram_C_portc_we,

        BRAM_PORTD_ADDR    => bram_C_portd_addr,
        BRAM_PORTD_DIN     => bram_C_portd_din,
        BRAM_PORTD_DOUT    => bram_C_portd_dout,
        BRAM_PORTD_EN      => bram_C_portd_en,
        BRAM_PORTD_WE      => bram_C_portd_we,

        BLOCK_PORTA_ADDR    => block_C_porta_addr,
        BLOCK_PORTA_DIN     => block_C_porta_din,
        BLOCK_PORTA_DOUT    => block_C_porta_dout,
        BLOCK_PORTA_EN      => block_C_porta_en,
        BLOCK_PORTA_WE      => block_C_porta_we,

        BLOCK_PORTB_ADDR    => block_C_portb_addr,
        BLOCK_PORTB_DIN     => block_C_portb_din,
        BLOCK_PORTB_DOUT    => block_C_portb_dout,
        BLOCK_PORTB_EN      => block_C_portb_en,
        BLOCK_PORTB_WE      => block_C_portb_we
    );


    block_C : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_C_addr,
        BRAM_PORTA_0_clk      => CLK_200,
        BRAM_PORTA_0_din      => bram_mux_out_block_C_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_C,
        BRAM_PORTA_0_en       => bram_mux_out_block_C_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_C_we,
        BRAM_PORTB_0_addr     => block_C_portb_addr,
        BRAM_PORTB_0_clk      => CLK_200,
        BRAM_PORTB_0_din      => block_C_portb_din,
        BRAM_PORTB_0_dout     => block_C_portb_dout,
        BRAM_PORTB_0_en       => block_C_portb_en,
        BRAM_PORTB_0_we(0)    => block_C_portb_we
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
    generic map (width => 64)
    port map(decoder_in => bram_decoder_in_block_C,
        decoder_out_0 => bram_ZYNQ_block_C_dout,
        decoder_out_1 => block_C_porta_dout,
        sel => bram_ZYNQ_sel
        );

    BRAM_D : entity quadPortBRAM
    generic map(ADDR_WIDTH, 64)
    port MAP(
        CLK_1X          => CLK_100,
        CLK_2X          => CLK_200,
        RST             => RST,

        BRAM_PORTA_ADDR    => bram_D_porta_addr,
        BRAM_PORTA_DIN     => bram_D_porta_din,
        BRAM_PORTA_DOUT    => bram_D_porta_dout,
        BRAM_PORTA_EN      => bram_D_porta_en,
        BRAM_PORTA_WE      => bram_D_porta_we,

        BRAM_PORTB_ADDR    => bram_D_portb_addr,
        BRAM_PORTB_DIN     => bram_D_portb_din,
        BRAM_PORTB_DOUT    => bram_D_portb_dout,
        BRAM_PORTB_EN      => bram_D_portb_en,
        BRAM_PORTB_WE      => bram_D_portb_we,

        BRAM_PORTC_ADDR    => bram_D_portc_addr,
        BRAM_PORTC_DIN     => bram_D_portc_din,
        BRAM_PORTC_DOUT    => bram_D_portc_dout,
        BRAM_PORTC_EN      => bram_D_portc_en,
        BRAM_PORTC_WE      => bram_D_portc_we,

        BRAM_PORTD_ADDR    => bram_D_portd_addr,
        BRAM_PORTD_DIN     => bram_D_portd_din,
        BRAM_PORTD_DOUT    => bram_D_portd_dout,
        BRAM_PORTD_EN      => bram_D_portd_en,
        BRAM_PORTD_WE      => bram_D_portd_we,

        BLOCK_PORTA_ADDR    => block_D_porta_addr,
        BLOCK_PORTA_DIN     => block_D_porta_din,
        BLOCK_PORTA_DOUT    => block_D_porta_dout,
        BLOCK_PORTA_EN      => block_D_porta_en,
        BLOCK_PORTA_WE      => block_D_porta_we,

        BLOCK_PORTB_ADDR    => block_D_portb_addr,
        BLOCK_PORTB_DIN     => block_D_portb_din,
        BLOCK_PORTB_DOUT    => block_D_portb_dout,
        BLOCK_PORTB_EN      => block_D_portb_en,
        BLOCK_PORTB_WE      => block_D_portb_we
    );


    block_D : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_D_addr,
        BRAM_PORTA_0_clk      => CLK_200,
        BRAM_PORTA_0_din      => bram_mux_out_block_D_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_D,
        BRAM_PORTA_0_en       => bram_mux_out_block_D_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_D_we,
        BRAM_PORTB_0_addr     => block_D_portb_addr,
        BRAM_PORTB_0_clk      => CLK_200,
        BRAM_PORTB_0_din      => block_D_portb_din,
        BRAM_PORTB_0_dout     => block_D_portb_dout,
        BRAM_PORTB_0_en       => block_D_portb_en,
        BRAM_PORTB_0_we(0)    => block_D_portb_we
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
    generic map (width => 64)
    port map(decoder_in => bram_decoder_in_block_D,
        decoder_out_0 => bram_ZYNQ_block_D_dout,
        decoder_out_1 => block_D_porta_dout,
        sel => bram_ZYNQ_sel
        );


    MAC_A : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => mac_A_result_tdata,
        M_AXIS_RESULT_0_tready => mac_A_result_tready,
        M_AXIS_RESULT_0_tvalid => mac_A_result_tvalid,
        S_AXIS_A_0_tdata => mac_A_a_tdata,
        S_AXIS_A_0_tready => mac_A_a_tready,
        S_AXIS_A_0_tvalid => mac_A_a_tvalid,
        S_AXIS_B_0_tdata => mac_A_b_tdata,
        S_AXIS_B_0_tready => mac_A_b_tready,
        S_AXIS_B_0_tvalid => mac_A_b_tvalid,
        S_AXIS_C_0_tdata => mac_A_c_tdata,
        S_AXIS_C_0_tready => mac_A_c_tready,
        S_AXIS_C_0_tvalid => mac_A_c_tvalid,
        S_AXIS_OPERATION_0_tdata => mac_A_operation_tdata,
        S_AXIS_OPERATION_0_tready => mac_A_operation_tready,
        S_AXIS_OPERATION_0_tvalid => mac_A_operation_tvalid,
        aclk_0   => CLK_100
    );

    MAC_B : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => mac_B_result_tdata,
        M_AXIS_RESULT_0_tready => mac_B_result_tready,
        M_AXIS_RESULT_0_tvalid => mac_B_result_tvalid,
        S_AXIS_A_0_tdata => mac_B_a_tdata,
        S_AXIS_A_0_tready => mac_B_a_tready,
        S_AXIS_A_0_tvalid => mac_B_a_tvalid,
        S_AXIS_B_0_tdata => mac_B_b_tdata,
        S_AXIS_B_0_tready => mac_B_b_tready,
        S_AXIS_B_0_tvalid => mac_B_b_tvalid,
        S_AXIS_C_0_tdata => mac_B_c_tdata,
        S_AXIS_C_0_tready => mac_B_c_tready,
        S_AXIS_C_0_tvalid => mac_B_c_tvalid,
        S_AXIS_OPERATION_0_tdata => mac_B_operation_tdata,
        S_AXIS_OPERATION_0_tready => mac_B_operation_tready,
        S_AXIS_OPERATION_0_tvalid => mac_B_operation_tvalid,
        aclk_0   => CLK_100
    );

    MAC_C : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => mac_C_result_tdata,
        M_AXIS_RESULT_0_tready => mac_C_result_tready,
        M_AXIS_RESULT_0_tvalid => mac_C_result_tvalid,
        S_AXIS_A_0_tdata => mac_C_a_tdata,
        S_AXIS_A_0_tready => mac_C_a_tready,
        S_AXIS_A_0_tvalid => mac_C_a_tvalid,
        S_AXIS_B_0_tdata => mac_C_b_tdata,
        S_AXIS_B_0_tready => mac_C_b_tready,
        S_AXIS_B_0_tvalid => mac_C_b_tvalid,
        S_AXIS_C_0_tdata => mac_C_c_tdata,
        S_AXIS_C_0_tready => mac_C_c_tready,
        S_AXIS_C_0_tvalid => mac_C_c_tvalid,
        S_AXIS_OPERATION_0_tdata => mac_C_operation_tdata,
        S_AXIS_OPERATION_0_tready => mac_C_operation_tready,
        S_AXIS_OPERATION_0_tvalid => mac_C_operation_tvalid,
        aclk_0   => CLK_100
    );

    MAC_D : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => mac_D_result_tdata,
        M_AXIS_RESULT_0_tready => mac_D_result_tready,
        M_AXIS_RESULT_0_tvalid => mac_D_result_tvalid,
        S_AXIS_A_0_tdata => mac_D_a_tdata,
        S_AXIS_A_0_tready => mac_D_a_tready,
        S_AXIS_A_0_tvalid => mac_D_a_tvalid,
        S_AXIS_B_0_tdata => mac_D_b_tdata,
        S_AXIS_B_0_tready => mac_D_b_tready,
        S_AXIS_B_0_tvalid => mac_D_b_tvalid,
        S_AXIS_C_0_tdata => mac_D_c_tdata,
        S_AXIS_C_0_tready => mac_D_c_tready,
        S_AXIS_C_0_tvalid => mac_D_c_tvalid,
        S_AXIS_OPERATION_0_tdata => mac_D_operation_tdata,
        S_AXIS_OPERATION_0_tready => mac_D_operation_tready,
        S_AXIS_OPERATION_0_tvalid => mac_D_operation_tvalid,
        aclk_0   => CLK_100
    );

    DIV_A : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => div_A_result_tdata,
        M_AXIS_RESULT_0_tready => div_A_result_tready,
        M_AXIS_RESULT_0_tvalid => div_A_result_tvalid,
        S_AXIS_A_0_tdata => div_A_a_tdata,
        S_AXIS_A_0_tready => div_A_a_tready,
        S_AXIS_A_0_tvalid => div_A_a_tvalid,
        S_AXIS_B_0_tdata => div_A_b_tdata,
        S_AXIS_B_0_tready => div_A_b_tready,
        S_AXIS_B_0_tvalid => div_A_b_tvalid,
        aclk_0   => CLK_100
    );

    DIV_B : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => div_B_result_tdata,
        M_AXIS_RESULT_0_tready => div_B_result_tready,
        M_AXIS_RESULT_0_tvalid => div_B_result_tvalid,
        S_AXIS_A_0_tdata => div_B_a_tdata,
        S_AXIS_A_0_tready => div_B_a_tready,
        S_AXIS_A_0_tvalid => div_B_a_tvalid,
        S_AXIS_B_0_tdata => div_B_b_tdata,
        S_AXIS_B_0_tready => div_B_b_tready,
        S_AXIS_B_0_tvalid => div_B_b_tvalid,
        aclk_0   => CLK_100
    );

    DIV_C : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => div_C_result_tdata,
        M_AXIS_RESULT_0_tready => div_C_result_tready,
        M_AXIS_RESULT_0_tvalid => div_C_result_tvalid,
        S_AXIS_A_0_tdata => div_C_a_tdata,
        S_AXIS_A_0_tready => div_C_a_tready,
        S_AXIS_A_0_tvalid => div_C_a_tvalid,
        S_AXIS_B_0_tdata => div_C_b_tdata,
        S_AXIS_B_0_tready => div_C_b_tready,
        S_AXIS_B_0_tvalid => div_C_b_tvalid,
        aclk_0   => CLK_100
    );

    DIV_D : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_0_tdata => div_D_result_tdata,
        M_AXIS_RESULT_0_tready => div_D_result_tready,
        M_AXIS_RESULT_0_tvalid => div_D_result_tvalid,
        S_AXIS_A_0_tdata => div_D_a_tdata,
        S_AXIS_A_0_tready => div_D_a_tready,
        S_AXIS_A_0_tvalid => div_D_a_tvalid,
        S_AXIS_B_0_tdata => div_D_b_tdata,
        S_AXIS_B_0_tready => div_D_b_tready,
        S_AXIS_B_0_tvalid => div_D_b_tvalid,
        aclk_0   => CLK_100
    );

 -- input locations
    inputLocations(0) <= mac_A_result_tdata;
    inputLocations(1) <= mac_B_result_tdata;
    inputLocations(2) <= mac_C_result_tdata;
    inputLocations(3) <= mac_D_result_tdata;
    inputLocations(4) <= div_A_result_tdata;
    inputLocations(5) <= div_B_result_tdata;
    inputLocations(6) <= div_C_result_tdata;
    inputLocations(7) <= div_D_result_tdata;
    inputLocations(8) <= bram_A_porta_dout;
    inputLocations(8+1) <= bram_A_portb_dout;
    inputLocations(8+2) <= bram_A_portc_dout;
    inputLocations(8+3) <= bram_A_portd_dout;
    inputLocations(12) <= bram_B_porta_dout;
    inputLocations(12+1) <= bram_B_portb_dout;
    inputLocations(12+2) <= bram_B_portc_dout;
    inputLocations(12+3) <= bram_B_portd_dout;
    inputLocations(16) <= bram_C_porta_dout;
    inputLocations(16+1) <= bram_C_portb_dout;
    inputLocations(16+2) <= bram_C_portc_dout;
    inputLocations(16+3) <= bram_C_portd_dout;
    inputLocations(20) <= bram_D_porta_dout;
    inputLocations(20+1) <= bram_D_portb_dout;
    inputLocations(20+2) <= bram_D_portc_dout;
    inputLocations(20+3) <= bram_D_portd_dout;
    inputLocations(24) <= (others => '0');
        
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

    mac_A_a_signInv <= not mac_A_a_tdataIN(63);
    mac_A_a_tdata <= mac_A_a_signInv & mac_A_a_tdataIN(62 downto 0);

    MUX_MAC_IN_B_b : entity MUX_AU_IN
    port map(
        SEL => mac_B_b_sel,
        DIN => inputLocations,
        DOUT => mac_B_b_tdata
    );

    MUX_MAC_IN_B_c : entity MUX_AU_IN
    port map(
        SEL => mac_B_c_sel,
        DIN => inputLocations,
        DOUT => mac_B_c_tdata
    );

    MUX_MAC_IN_B_a : entity MUX_AU_IN
    port map(
        SEL => mac_B_a_sel,
        DIN => inputLocations,
        DOUT => mac_B_a_tdataIN
    );

    mac_B_a_signInv <= not mac_B_a_tdataIN(63);
    mac_B_a_tdata <= mac_B_a_signInv & mac_B_a_tdataIN(62 downto 0);

    MUX_MAC_IN_C_b : entity MUX_AU_IN
    port map(
        SEL => mac_C_b_sel,
        DIN => inputLocations,
        DOUT => mac_C_b_tdata
    );

    MUX_MAC_IN_C_c : entity MUX_AU_IN
    port map(
        SEL => mac_C_c_sel,
        DIN => inputLocations,
        DOUT => mac_C_c_tdata
    );

    MUX_MAC_IN_C_a : entity MUX_AU_IN
    port map(
        SEL => mac_C_a_sel,
        DIN => inputLocations,
        DOUT => mac_C_a_tdataIN
    );

    mac_C_a_signInv <= not mac_C_a_tdataIN(63);
    mac_C_a_tdata <= mac_C_a_signInv & mac_C_a_tdataIN(62 downto 0);

    MUX_MAC_IN_D_b : entity MUX_AU_IN
    port map(
        SEL => mac_D_b_sel,
        DIN => inputLocations,
        DOUT => mac_D_b_tdata
    );

    MUX_MAC_IN_D_c : entity MUX_AU_IN
    port map(
        SEL => mac_D_c_sel,
        DIN => inputLocations,
        DOUT => mac_D_c_tdata
    );

    MUX_MAC_IN_D_a : entity MUX_AU_IN
    port map(
        SEL => mac_D_a_sel,
        DIN => inputLocations,
        DOUT => mac_D_a_tdataIN
    );

    mac_D_a_signInv <= not mac_D_a_tdataIN(63);
    mac_D_a_tdata <= mac_D_a_signInv & mac_D_a_tdataIN(62 downto 0);

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

    MUX_DIV_IN_B_a : entity MUX_AU_IN
    port map(
        SEL => div_B_a_sel,
        DIN => inputLocations,
        DOUT => div_B_a_tdata
    );

    MUX_DIV_IN_B_b : entity MUX_AU_IN
    port map(
        SEL => div_B_b_sel,
        DIN => inputLocations,
        DOUT => div_B_b_tdata
    );

    MUX_DIV_IN_C_a : entity MUX_AU_IN
    port map(
        SEL => div_C_a_sel,
        DIN => inputLocations,
        DOUT => div_C_a_tdata
    );

    MUX_DIV_IN_C_b : entity MUX_AU_IN
    port map(
        SEL => div_C_b_sel,
        DIN => inputLocations,
        DOUT => div_C_b_tdata
    );

    MUX_DIV_IN_D_a : entity MUX_AU_IN
    port map(
        SEL => div_D_a_sel,
        DIN => inputLocations,
        DOUT => div_D_a_tdata
    );

    MUX_DIV_IN_D_b : entity MUX_AU_IN
    port map(
        SEL => div_D_b_sel,
        DIN => inputLocations,
        DOUT => div_D_b_tdata
    );

    MUX_BRAM_A_a_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_A_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_A_porta_din
    );

    MUX_BRAM_A_b_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_A_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_A_portb_din
    );

    MUX_BRAM_A_c_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_A_c_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_A_portc_din
    );

    MUX_BRAM_A_d_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_A_d_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_A_portd_din
    );

    MUX_BRAM_B_a_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_B_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_B_porta_din
    );

    MUX_BRAM_B_b_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_B_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_B_portb_din
    );

    MUX_BRAM_B_c_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_B_c_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_B_portc_din
    );

    MUX_BRAM_B_d_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_B_d_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_B_portd_din
    );

    MUX_BRAM_C_a_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_C_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_C_porta_din
    );

    MUX_BRAM_C_b_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_C_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_C_portb_din
    );

    MUX_BRAM_C_c_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_C_c_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_C_portc_din
    );

    MUX_BRAM_C_d_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_C_d_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_C_portd_din
    );

    MUX_BRAM_D_a_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_D_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_D_porta_din
    );

    MUX_BRAM_D_b_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_D_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_D_portb_din
    );

    MUX_BRAM_D_c_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_D_c_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_D_portc_din
    );

    MUX_BRAM_D_d_in : entity MUX_BRAM_IN
    port map(
        SEL => bram_D_d_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => bram_D_portd_din
    );

    bram_A_porta_addr <= CTRL_Signal(CTRL_WIDTH-1 downto CTRL_WIDTH-ADDR_WIDTH);
    bram_A_porta_we <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-1);
    bram_A_portb_addr <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-2 downto CTRL_WIDTH-2*ADDR_WIDTH-1);
    bram_A_portb_we <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-2);
    bram_A_portc_addr <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-3 downto CTRL_WIDTH-3*ADDR_WIDTH-2);
    bram_A_portc_we <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-3);
    bram_A_portd_addr <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-4 downto CTRL_WIDTH-4*ADDR_WIDTH-3);
    bram_A_portd_we <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-4);
    bram_B_porta_addr <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5 downto CTRL_WIDTH-5*ADDR_WIDTH-4);
    bram_B_porta_we <= CTRL_Signal(CTRL_WIDTH-5*ADDR_WIDTH-5);
    bram_B_portb_addr <= CTRL_Signal(CTRL_WIDTH-5*ADDR_WIDTH-6 downto CTRL_WIDTH-6*ADDR_WIDTH-5);
    bram_B_portb_we <= CTRL_Signal(CTRL_WIDTH-6 *ADDR_WIDTH-6);
    bram_B_portc_addr <= CTRL_Signal(CTRL_WIDTH-6 *ADDR_WIDTH-7 downto CTRL_WIDTH-7*ADDR_WIDTH-6);
    bram_B_portc_we <= CTRL_Signal(CTRL_WIDTH-7*ADDR_WIDTH-7);
    bram_B_portd_addr <= CTRL_Signal(CTRL_WIDTH-7*ADDR_WIDTH-8 downto CTRL_WIDTH-8*ADDR_WIDTH-7);
    bram_B_portd_we <= CTRL_Signal(CTRL_WIDTH-8*ADDR_WIDTH-8);
    bram_C_porta_addr <= CTRL_Signal(CTRL_WIDTH-8*ADDR_WIDTH-9 downto CTRL_WIDTH-9*ADDR_WIDTH-8);
    bram_C_porta_we <= CTRL_Signal(CTRL_WIDTH-9*ADDR_WIDTH-9);
    bram_C_portb_addr <= CTRL_Signal(CTRL_WIDTH-9*ADDR_WIDTH-10 downto CTRL_WIDTH-10*ADDR_WIDTH-9);
    bram_C_portb_we <= CTRL_Signal(CTRL_WIDTH-10*ADDR_WIDTH-10);
    bram_C_portc_addr <= CTRL_Signal(CTRL_WIDTH-10*ADDR_WIDTH-11 downto CTRL_WIDTH-11*ADDR_WIDTH-10);
    bram_C_portc_we <= CTRL_Signal(CTRL_WIDTH-11*ADDR_WIDTH-11);
    bram_C_portd_addr <= CTRL_Signal(CTRL_WIDTH-11*ADDR_WIDTH-12 downto CTRL_WIDTH-12*ADDR_WIDTH-11);
    bram_C_portd_we <= CTRL_Signal(CTRL_WIDTH-12*ADDR_WIDTH-12);
    bram_D_porta_addr <= CTRL_Signal(CTRL_WIDTH-12*ADDR_WIDTH-13 downto CTRL_WIDTH-13*ADDR_WIDTH-12);
    bram_D_porta_we <= CTRL_Signal(CTRL_WIDTH-13*ADDR_WIDTH-13);
    bram_D_portb_addr <= CTRL_Signal(CTRL_WIDTH-13*ADDR_WIDTH-14 downto CTRL_WIDTH-14*ADDR_WIDTH-13);
    bram_D_portb_we <= CTRL_Signal(CTRL_WIDTH-14*ADDR_WIDTH-14);
    bram_D_portc_addr <= CTRL_Signal(CTRL_WIDTH-14*ADDR_WIDTH-15 downto CTRL_WIDTH-15*ADDR_WIDTH-14);
    bram_D_portc_we <= CTRL_Signal(CTRL_WIDTH-15*ADDR_WIDTH-15);
    bram_D_portd_addr <= CTRL_Signal(CTRL_WIDTH-15*ADDR_WIDTH-16 downto CTRL_WIDTH-16*ADDR_WIDTH-15);
    bram_D_portd_we <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-16);
    mac_A_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-AU_SEL_WIDTH-16);
    mac_A_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-2*AU_SEL_WIDTH-16);
    mac_A_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-2*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-3*AU_SEL_WIDTH-16);
    mac_B_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-3*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-4*AU_SEL_WIDTH-16);
    mac_B_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-4*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-5*AU_SEL_WIDTH-16);
    mac_B_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-5*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-6*AU_SEL_WIDTH-16);
    mac_C_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-6*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-7*AU_SEL_WIDTH-16);
    mac_C_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-7*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-8*AU_SEL_WIDTH-16);
    mac_C_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-8*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-9*AU_SEL_WIDTH-16);
    mac_D_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-9*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-10*AU_SEL_WIDTH-16);
    mac_D_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-10*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-11*AU_SEL_WIDTH-16);
    mac_D_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-11*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-12*AU_SEL_WIDTH-16);
    div_A_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-12*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-13*AU_SEL_WIDTH-16);
    div_A_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-13*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-14*AU_SEL_WIDTH-16);
    div_B_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-14*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-15*AU_SEL_WIDTH-16);
    div_B_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-15*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-16*AU_SEL_WIDTH-16);
    div_C_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-16*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-17*AU_SEL_WIDTH-16);
    div_C_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-17*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-18*AU_SEL_WIDTH-16);
    div_D_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-18*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-19*AU_SEL_WIDTH-16);
    div_D_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-19*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-16);
    bram_A_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-BRAM_SEL_WIDTH-16);
    bram_A_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-16);
    bram_A_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-16);
    bram_A_d_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-4*BRAM_SEL_WIDTH-16);
    bram_B_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-4*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-5*BRAM_SEL_WIDTH-16);
    bram_B_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-5*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-6*BRAM_SEL_WIDTH-16);
    bram_B_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-6*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-7*BRAM_SEL_WIDTH-16);
    bram_B_d_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-7*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-8*BRAM_SEL_WIDTH-16);
    bram_C_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-8*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-9*BRAM_SEL_WIDTH-16);
    bram_C_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-9*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-10*BRAM_SEL_WIDTH-16);
    bram_C_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-10*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-11*BRAM_SEL_WIDTH-16);
    bram_C_d_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-11*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-12*BRAM_SEL_WIDTH-16);
    bram_D_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-12*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-13*BRAM_SEL_WIDTH-16);
    bram_D_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-13*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-14*BRAM_SEL_WIDTH-16);
    bram_D_c_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-14*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-15*BRAM_SEL_WIDTH-16);
    bram_D_d_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-15*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-16*BRAM_SEL_WIDTH-16);
--  CTRL_Signal(0) is actually a complete signal which is required by this module during debugging
    bram_A_porta_en <= locked;
    bram_A_portb_en <= locked;
    bram_A_portc_en <= locked;
    bram_A_portd_en <= locked;
    bram_B_porta_en <= locked;
    bram_B_portb_en <= locked;
    bram_B_portc_en <= locked;
    bram_B_portd_en <= locked;
    bram_C_porta_en <= locked;
    bram_C_portb_en <= locked;
    bram_C_portc_en <= locked;
    bram_C_portd_en <= locked;
    bram_D_porta_en <= locked;
    bram_D_portb_en <= locked;
    bram_D_portc_en <= locked;
    bram_D_portd_en <= locked;

    RST <= not locked;

    mac_A_a_tvalid <= locked;
    mac_A_b_tvalid <= locked;
    mac_A_c_tvalid <= locked;
    mac_A_operation_tvalid <= locked;
    mac_A_operation_tdata <= "00000000"; --Indicates substraction(AB-C). 1 indicates addition(AB+C)
    mac_A_result_tready <= locked;
    mac_B_a_tvalid <= locked;
    mac_B_b_tvalid <= locked;
    mac_B_c_tvalid <= locked;
    mac_B_operation_tvalid <= locked;
    mac_B_operation_tdata <= "00000000";--Indicates substraction. 1 indicates addition(AB+C)
    mac_B_result_tready <= locked;
    mac_C_a_tvalid <= locked;
    mac_C_b_tvalid <= locked;
    mac_C_c_tvalid <= locked;
    mac_C_operation_tvalid <= locked;
    mac_C_operation_tdata <= "00000000";--Indicates substraction. 1 indicates addition(AB+C)
    mac_C_result_tready <= locked;
    mac_D_a_tvalid <= locked;
    mac_D_b_tvalid <= locked;
    mac_D_c_tvalid <= locked;
    mac_D_operation_tvalid <= locked;
    mac_D_operation_tdata <= "00000000";--Indicates substraction. 1 indicates addition(AB+C)
    mac_D_result_tready <= locked;

    div_A_a_tvalid <= locked;
    div_A_b_tvalid <= locked;
    div_A_result_tready <= locked;
    div_B_a_tvalid <= locked;
    div_B_b_tvalid <= locked;
    div_B_result_tready <= locked;
    div_C_a_tvalid <= locked;
    div_C_b_tvalid <= locked;
    div_C_result_tready <= locked;
    div_D_a_tvalid <= locked;
    div_D_b_tvalid <= locked;
    div_D_result_tready <= locked;

end architecture;
