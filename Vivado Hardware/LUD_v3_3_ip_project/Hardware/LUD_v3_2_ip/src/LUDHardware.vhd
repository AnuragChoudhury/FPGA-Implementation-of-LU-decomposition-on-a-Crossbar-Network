
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.types.all;

entity LUDHardware is
    generic(
        ADDR_WIDTH : integer := 10;
        CTRL_WIDTH : integer := 357;
        AU_SEL_WIDTH : integer := 5;
        BRAM_SEL_WIDTH : integer := 5
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
        
        bram_ZYNQ_block_E_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_E_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_E_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_E_en : in std_logic;
        bram_ZYNQ_block_E_we : in std_logic;
        
        bram_ZYNQ_block_F_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_F_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_F_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_F_en : in std_logic;
        bram_ZYNQ_block_F_we : in std_logic;
        
        bram_ZYNQ_block_G_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_G_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_G_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_G_en : in std_logic;
        bram_ZYNQ_block_G_we : in std_logic;
        
        bram_ZYNQ_block_H_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_block_H_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_H_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_H_en : in std_logic;
        bram_ZYNQ_block_H_we : in std_logic;
        
        bram_ZYNQ_sel : in std_logic
        
    );
end entity;

architecture yoStyle of LUDHardware is

    --Component decleration ********************************************************************************************************************************************************************
    component design_BRAM_A_wrapper is
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
    end component design_BRAM_A_wrapper;
    
    component design_BRAM_B_wrapper is
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
    end component design_BRAM_B_wrapper;
    
    component design_BRAM_C_wrapper is
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
    end component design_BRAM_C_wrapper;
    
    component design_BRAM_D_wrapper is
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
    end component design_BRAM_D_wrapper;
    
    component design_BRAM_E_wrapper is
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
    end component design_BRAM_E_wrapper;
    
    component design_BRAM_F_wrapper is
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
    end component design_BRAM_F_wrapper;
    
    component design_BRAM_G_wrapper is
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
    end component design_BRAM_G_wrapper;
    
    component design_BRAM_H_wrapper is
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
    end component design_BRAM_H_wrapper;
    
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

    signal inputLocations : dataArray(24 downto 0);


    signal block_A_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_A_porta_din  : std_logic_vector(31 downto 0);
    signal block_A_porta_dout : std_logic_vector(31 downto 0);
    signal block_A_porta_en   : std_logic;
    signal block_A_porta_we   : std_logic;

    signal block_A_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_A_portb_din  : std_logic_vector(31 downto 0);
    signal block_A_portb_dout : std_logic_vector(31 downto 0);
    signal block_A_portb_en   : std_logic;
    signal block_A_portb_we   : std_logic;

    signal block_B_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_B_porta_din  : std_logic_vector(31 downto 0);
    signal block_B_porta_dout : std_logic_vector(31 downto 0);
    signal block_B_porta_en   : std_logic;
    signal block_B_porta_we   : std_logic;

    signal block_B_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_B_portb_din  : std_logic_vector(31 downto 0);
    signal block_B_portb_dout : std_logic_vector(31 downto 0);
    signal block_B_portb_en   : std_logic;
    signal block_B_portb_we   : std_logic;

    signal block_C_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_C_porta_din  : std_logic_vector(31 downto 0);
    signal block_C_porta_dout : std_logic_vector(31 downto 0);
    signal block_C_porta_en   : std_logic;
    signal block_C_porta_we   : std_logic;

    signal block_C_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_C_portb_din  : std_logic_vector(31 downto 0);
    signal block_C_portb_dout : std_logic_vector(31 downto 0);
    signal block_C_portb_en   : std_logic;
    signal block_C_portb_we   : std_logic;

    signal block_D_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_D_porta_din  : std_logic_vector(31 downto 0);
    signal block_D_porta_dout : std_logic_vector(31 downto 0);
    signal block_D_porta_en   : std_logic;
    signal block_D_porta_we   : std_logic;

    signal block_D_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_D_portb_din  : std_logic_vector(31 downto 0);
    signal block_D_portb_dout : std_logic_vector(31 downto 0);
    signal block_D_portb_en   : std_logic;
    signal block_D_portb_we   : std_logic;
    
    signal block_E_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_E_porta_din  : std_logic_vector(31 downto 0);
    signal block_E_porta_dout : std_logic_vector(31 downto 0);
    signal block_E_porta_en   : std_logic;
    signal block_E_porta_we   : std_logic;

    signal block_E_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_E_portb_din  : std_logic_vector(31 downto 0);
    signal block_E_portb_dout : std_logic_vector(31 downto 0);
    signal block_E_portb_en   : std_logic;
    signal block_E_portb_we   : std_logic;
    
    signal block_F_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_F_porta_din  : std_logic_vector(31 downto 0);
    signal block_F_porta_dout : std_logic_vector(31 downto 0);
    signal block_F_porta_en   : std_logic;
    signal block_F_porta_we   : std_logic;

    signal block_F_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_F_portb_din  : std_logic_vector(31 downto 0);
    signal block_F_portb_dout : std_logic_vector(31 downto 0);
    signal block_F_portb_en   : std_logic;
    signal block_F_portb_we   : std_logic;
    
    signal block_G_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_G_porta_din  : std_logic_vector(31 downto 0);
    signal block_G_porta_dout : std_logic_vector(31 downto 0);
    signal block_G_porta_en   : std_logic;
    signal block_G_porta_we   : std_logic;

    signal block_G_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_G_portb_din  : std_logic_vector(31 downto 0);
    signal block_G_portb_dout : std_logic_vector(31 downto 0);
    signal block_G_portb_en   : std_logic;
    signal block_G_portb_we   : std_logic;
    
    signal block_H_porta_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_H_porta_din  : std_logic_vector(31 downto 0);
    signal block_H_porta_dout : std_logic_vector(31 downto 0);
    signal block_H_porta_en   : std_logic;
    signal block_H_porta_we   : std_logic;

    signal block_H_portb_addr : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal block_H_portb_din  : std_logic_vector(31 downto 0);
    signal block_H_portb_dout : std_logic_vector(31 downto 0);
    signal block_H_portb_en   : std_logic;
    signal block_H_portb_we   : std_logic;

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

    signal mac_B_result_tdata : std_logic_vector(31 downto 0);
    signal mac_B_result_tready : std_logic;
    signal mac_B_result_tvalid : std_logic;

    signal mac_B_a_tdata : std_logic_vector(31 downto 0);
    signal mac_B_a_tready : std_logic;
    signal mac_B_a_tvalid : std_logic;

    signal mac_B_b_tdata : std_logic_vector(31 downto 0);
    signal mac_B_b_tready : std_logic;
    signal mac_B_b_tvalid : std_logic;

    signal mac_B_c_tdata : std_logic_vector(31 downto 0);
    signal mac_B_c_tready : std_logic;
    signal mac_B_c_tvalid : std_logic;

    signal mac_B_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_B_operation_tready : std_logic;
    signal mac_B_operation_tvalid : std_logic;
    signal mac_B_a_signInv : std_logic;
    signal mac_B_a_tdataIN : std_logic_vector(31 downto 0);

    signal mac_C_result_tdata : std_logic_vector(31 downto 0);
    signal mac_C_result_tready : std_logic;
    signal mac_C_result_tvalid : std_logic;

    signal mac_C_a_tdata : std_logic_vector(31 downto 0);
    signal mac_C_a_tready : std_logic;
    signal mac_C_a_tvalid : std_logic;

    signal mac_C_b_tdata : std_logic_vector(31 downto 0);
    signal mac_C_b_tready : std_logic;
    signal mac_C_b_tvalid : std_logic;

    signal mac_C_c_tdata : std_logic_vector(31 downto 0);
    signal mac_C_c_tready : std_logic;
    signal mac_C_c_tvalid : std_logic;

    signal mac_C_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_C_operation_tready : std_logic;
    signal mac_C_operation_tvalid : std_logic;
    signal mac_C_a_signInv : std_logic;
    signal mac_C_a_tdataIN : std_logic_vector(31 downto 0);

    signal mac_D_result_tdata : std_logic_vector(31 downto 0);
    signal mac_D_result_tready : std_logic;
    signal mac_D_result_tvalid : std_logic;

    signal mac_D_a_tdata : std_logic_vector(31 downto 0);
    signal mac_D_a_tready : std_logic;
    signal mac_D_a_tvalid : std_logic;

    signal mac_D_b_tdata : std_logic_vector(31 downto 0);
    signal mac_D_b_tready : std_logic;
    signal mac_D_b_tvalid : std_logic;

    signal mac_D_c_tdata : std_logic_vector(31 downto 0);
    signal mac_D_c_tready : std_logic;
    signal mac_D_c_tvalid : std_logic;

    signal mac_D_operation_tdata : std_logic_vector(7 downto 0);
    signal mac_D_operation_tready : std_logic;
    signal mac_D_operation_tvalid : std_logic;
    signal mac_D_a_signInv : std_logic;
    signal mac_D_a_tdataIN : std_logic_vector(31 downto 0);

    signal div_A_result_tdata : std_logic_vector(31 downto 0);
    signal div_A_result_tready : std_logic;
    signal div_A_result_tvalid : std_logic;

    signal div_A_a_tdata : std_logic_vector(31 downto 0);
    signal div_A_a_tready : std_logic;
    signal div_A_a_tvalid : std_logic;

    signal div_A_b_tdata : std_logic_vector(31 downto 0);
    signal div_A_b_tready : std_logic;
    signal div_A_b_tvalid : std_logic;

    signal div_B_result_tdata : std_logic_vector(31 downto 0);
    signal div_B_result_tready : std_logic;
    signal div_B_result_tvalid : std_logic;

    signal div_B_a_tdata : std_logic_vector(31 downto 0);
    signal div_B_a_tready : std_logic;
    signal div_B_a_tvalid : std_logic;

    signal div_B_b_tdata : std_logic_vector(31 downto 0);
    signal div_B_b_tready : std_logic;
    signal div_B_b_tvalid : std_logic;

    signal div_C_result_tdata : std_logic_vector(31 downto 0);
    signal div_C_result_tready : std_logic;
    signal div_C_result_tvalid : std_logic;

    signal div_C_a_tdata : std_logic_vector(31 downto 0);
    signal div_C_a_tready : std_logic;
    signal div_C_a_tvalid : std_logic;

    signal div_C_b_tdata : std_logic_vector(31 downto 0);
    signal div_C_b_tready : std_logic;
    signal div_C_b_tvalid : std_logic;

    signal div_D_result_tdata : std_logic_vector(31 downto 0);
    signal div_D_result_tready : std_logic;
    signal div_D_result_tvalid : std_logic;

    signal div_D_a_tdata : std_logic_vector(31 downto 0);
    signal div_D_a_tready : std_logic;
    signal div_D_a_tvalid : std_logic;

    signal div_D_b_tdata : std_logic_vector(31 downto 0);
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

    signal block_A_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_A_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_B_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_B_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal block_C_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_C_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_D_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_D_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal block_E_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_E_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_F_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_F_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);

    signal block_G_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_G_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    signal block_H_a_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    signal block_H_b_sel : std_logic_vector(BRAM_SEL_WIDTH-1 downto 0);
    
    --Mux signals for connection to ZYNQ system
    signal bram_mux_out_block_A_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_A_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_A : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_A_en : std_logic;
    signal bram_mux_out_block_A_we : std_logic;
    signal bram_mux_out_block_A_clock : std_logic;
    
    signal bram_mux_out_block_B_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_B_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_B : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_B_en : std_logic;
    signal bram_mux_out_block_B_we : std_logic;
    signal bram_mux_out_block_B_clock : std_logic;
    
    signal bram_mux_out_block_C_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_C_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_C : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_C_en : std_logic;
    signal bram_mux_out_block_C_we : std_logic;
    signal bram_mux_out_block_C_clock : std_logic;
    
    signal bram_mux_out_block_D_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_D_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_D : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_D_en : std_logic;
    signal bram_mux_out_block_D_we : std_logic;
    signal bram_mux_out_block_D_clock : std_logic;
    
    signal bram_mux_out_block_E_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_E_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_E : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_E_en : std_logic;
    signal bram_mux_out_block_E_we : std_logic;
    signal bram_mux_out_block_E_clock : std_logic;
    
    signal bram_mux_out_block_F_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_F_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_F : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_F_en : std_logic;
    signal bram_mux_out_block_F_we : std_logic;
    signal bram_mux_out_block_F_clock : std_logic;
    
    signal bram_mux_out_block_G_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_G_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_G : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_G_en : std_logic;
    signal bram_mux_out_block_G_we : std_logic;
    signal bram_mux_out_block_G_clock : std_logic;
    
    signal bram_mux_out_block_H_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal bram_mux_out_block_H_din : std_logic_vector(31 downto 0);
    signal bram_decoder_in_block_H : std_logic_vector(31 downto 0);  
    signal bram_mux_out_block_H_en : std_logic;
    signal bram_mux_out_block_H_we : std_logic;
    signal bram_mux_out_block_H_clock : std_logic;

begin

    block_A : design_BRAM_A_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_A_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_A_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_A,
        BRAM_PORTA_0_en       => bram_mux_out_block_A_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_A_we,
        BRAM_PORTB_0_addr     => block_A_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
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
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_A,
          decoder_out_0 => bram_ZYNQ_block_A_dout,
          decoder_out_1 => block_A_porta_dout,
          sel => bram_ZYNQ_sel
          );

    block_B : design_BRAM_B_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_B_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_B_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_B,
        BRAM_PORTA_0_en       => bram_mux_out_block_B_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_B_we,
        BRAM_PORTB_0_addr     => block_B_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
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
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_B,
        decoder_out_0 => bram_ZYNQ_block_B_dout,
        decoder_out_1 => block_B_porta_dout,
        sel => bram_ZYNQ_sel
        );

    block_C : design_BRAM_C_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_C_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_C_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_C,
        BRAM_PORTA_0_en       => bram_mux_out_block_C_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_C_we,
        BRAM_PORTB_0_addr     => block_C_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
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
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_C,
        decoder_out_0 => bram_ZYNQ_block_C_dout,
        decoder_out_1 => block_C_porta_dout,
        sel => bram_ZYNQ_sel
        );


    block_D : design_BRAM_D_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_D_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_D_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_D,
        BRAM_PORTA_0_en       => bram_mux_out_block_D_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_D_we,
        BRAM_PORTB_0_addr     => block_D_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
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
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_D,
        decoder_out_0 => bram_ZYNQ_block_D_dout,
        decoder_out_1 => block_D_porta_dout,
        sel => bram_ZYNQ_sel
        );

    block_E : design_BRAM_E_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_E_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_E_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_E,
        BRAM_PORTA_0_en       => bram_mux_out_block_E_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_E_we,
        BRAM_PORTB_0_addr     => block_E_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
        BRAM_PORTB_0_din      => block_E_portb_din,
        BRAM_PORTB_0_dout     => block_E_portb_dout,
        BRAM_PORTB_0_en       => block_E_portb_en,
        BRAM_PORTB_0_we(0)    => block_E_portb_we
    );
    bram_ZYNQ_mux_E : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_E_addr,
        bram_din_0 => bram_ZYNQ_block_E_din,
        bram_en_0 => bram_ZYNQ_block_E_en,
        bram_we_0 => bram_ZYNQ_block_E_we,
        bram_addr_1 => block_E_porta_addr,
        bram_din_1 => block_E_porta_din,
        bram_en_1 => block_E_porta_en,
        bram_we_1 => block_E_porta_we,
        bram_addr_out => bram_mux_out_block_E_addr,
        bram_din_out => bram_mux_out_block_E_din,
        bram_en_out => bram_mux_out_block_E_en,
        bram_we_out => bram_mux_out_block_E_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_E :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_E,
        decoder_out_0 => bram_ZYNQ_block_E_dout,
        decoder_out_1 => block_E_porta_dout,
        sel => bram_ZYNQ_sel
        );
        
    block_F : design_BRAM_F_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_F_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_F_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_F,
        BRAM_PORTA_0_en       => bram_mux_out_block_F_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_F_we,
        BRAM_PORTB_0_addr     => block_F_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
        BRAM_PORTB_0_din      => block_F_portb_din,
        BRAM_PORTB_0_dout     => block_F_portb_dout,
        BRAM_PORTB_0_en       => block_F_portb_en,
        BRAM_PORTB_0_we(0)    => block_F_portb_we
    );
    bram_ZYNQ_mux_F : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_F_addr,
        bram_din_0 => bram_ZYNQ_block_F_din,
        bram_en_0 => bram_ZYNQ_block_F_en,
        bram_we_0 => bram_ZYNQ_block_F_we,
        bram_addr_1 => block_F_porta_addr,
        bram_din_1 => block_F_porta_din,
        bram_en_1 => block_F_porta_en,
        bram_we_1 => block_F_porta_we,
        bram_addr_out => bram_mux_out_block_F_addr,
        bram_din_out => bram_mux_out_block_F_din,
        bram_en_out => bram_mux_out_block_F_en,
        bram_we_out => bram_mux_out_block_F_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_F :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_F,
        decoder_out_0 => bram_ZYNQ_block_F_dout,
        decoder_out_1 => block_F_porta_dout,
        sel => bram_ZYNQ_sel
        );
        
    block_G : design_BRAM_G_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_G_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_G_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_G,
        BRAM_PORTA_0_en       => bram_mux_out_block_G_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_G_we,
        BRAM_PORTB_0_addr     => block_G_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
        BRAM_PORTB_0_din      => block_G_portb_din,
        BRAM_PORTB_0_dout     => block_G_portb_dout,
        BRAM_PORTB_0_en       => block_G_portb_en,
        BRAM_PORTB_0_we(0)    => block_G_portb_we
    );
    bram_ZYNQ_mux_G : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_G_addr,
        bram_din_0 => bram_ZYNQ_block_G_din,
        bram_en_0 => bram_ZYNQ_block_G_en,
        bram_we_0 => bram_ZYNQ_block_G_we,
        bram_addr_1 => block_G_porta_addr,
        bram_din_1 => block_G_porta_din,
        bram_en_1 => block_G_porta_en,
        bram_we_1 => block_G_porta_we,
        bram_addr_out => bram_mux_out_block_G_addr,
        bram_din_out => bram_mux_out_block_G_din,
        bram_en_out => bram_mux_out_block_G_en,
        bram_we_out => bram_mux_out_block_G_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_G :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_G,
        decoder_out_0 => bram_ZYNQ_block_G_dout,
        decoder_out_1 => block_G_porta_dout,
        sel => bram_ZYNQ_sel
        );
        
    block_H : design_BRAM_H_wrapper
    port map (
        BRAM_PORTA_0_addr     => bram_mux_out_block_H_addr,
        BRAM_PORTA_0_clk      => CLK_100,
        BRAM_PORTA_0_din      => bram_mux_out_block_H_din,
        BRAM_PORTA_0_dout     => bram_decoder_in_block_H,
        BRAM_PORTA_0_en       => bram_mux_out_block_H_en,
        BRAM_PORTA_0_we(0)    => bram_mux_out_block_H_we,
        BRAM_PORTB_0_addr     => block_H_portb_addr,
        BRAM_PORTB_0_clk      => CLK_100,
        BRAM_PORTB_0_din      => block_H_portb_din,
        BRAM_PORTB_0_dout     => block_H_portb_dout,
        BRAM_PORTB_0_en       => block_H_portb_en,
        BRAM_PORTB_0_we(0)    => block_H_portb_we
    );
    bram_ZYNQ_mux_H : entity bram_ZYNQ_mux
    generic map(ADDR_WIDTH => ADDR_WIDTH)
    port map(bram_addr_0 => bram_ZYNQ_block_H_addr,
        bram_din_0 => bram_ZYNQ_block_H_din,
        bram_en_0 => bram_ZYNQ_block_H_en,
        bram_we_0 => bram_ZYNQ_block_H_we,
        bram_addr_1 => block_H_porta_addr,
        bram_din_1 => block_H_porta_din,
        bram_en_1 => block_H_porta_en,
        bram_we_1 => block_H_porta_we,
        bram_addr_out => bram_mux_out_block_H_addr,
        bram_din_out => bram_mux_out_block_H_din,
        bram_en_out => bram_mux_out_block_H_en,
        bram_we_out => bram_mux_out_block_H_we,
        sel => bram_ZYNQ_sel
        );
    bram_ZYNQ_decoder_H :entity bram_ZYNQ_decoder
    generic map (width => 32)
    port map(decoder_in => bram_decoder_in_block_H,
        decoder_out_0 => bram_ZYNQ_block_H_dout,
        decoder_out_1 => block_H_porta_dout,
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

    MAC_B : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_tdata => mac_B_result_tdata,
        M_AXIS_RESULT_tready => mac_B_result_tready,
        M_AXIS_RESULT_tvalid => mac_B_result_tvalid,
        S_AXIS_A_tdata => mac_B_a_tdata,
        S_AXIS_A_tready => mac_B_a_tready,
        S_AXIS_A_tvalid => mac_B_a_tvalid,
        S_AXIS_B_tdata => mac_B_b_tdata,
        S_AXIS_B_tready => mac_B_b_tready,
        S_AXIS_B_tvalid => mac_B_b_tvalid,
        S_AXIS_C_tdata => mac_B_c_tdata,
        S_AXIS_C_tready => mac_B_c_tready,
        S_AXIS_C_tvalid => mac_B_c_tvalid,
        S_AXIS_OPERATION_tdata => mac_B_operation_tdata,
        S_AXIS_OPERATION_tready => mac_B_operation_tready,
        S_AXIS_OPERATION_tvalid => mac_B_operation_tvalid,
        aclk   => CLK_100
    );

    MAC_C : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_tdata => mac_C_result_tdata,
        M_AXIS_RESULT_tready => mac_C_result_tready,
        M_AXIS_RESULT_tvalid => mac_C_result_tvalid,
        S_AXIS_A_tdata => mac_C_a_tdata,
        S_AXIS_A_tready => mac_C_a_tready,
        S_AXIS_A_tvalid => mac_C_a_tvalid,
        S_AXIS_B_tdata => mac_C_b_tdata,
        S_AXIS_B_tready => mac_C_b_tready,
        S_AXIS_B_tvalid => mac_C_b_tvalid,
        S_AXIS_C_tdata => mac_C_c_tdata,
        S_AXIS_C_tready => mac_C_c_tready,
        S_AXIS_C_tvalid => mac_C_c_tvalid,
        S_AXIS_OPERATION_tdata => mac_C_operation_tdata,
        S_AXIS_OPERATION_tready => mac_C_operation_tready,
        S_AXIS_OPERATION_tvalid => mac_C_operation_tvalid,
        aclk   => CLK_100
    );

    MAC_D : design_MAC_wrapper
    port map(
        M_AXIS_RESULT_tdata => mac_D_result_tdata,
        M_AXIS_RESULT_tready => mac_D_result_tready,
        M_AXIS_RESULT_tvalid => mac_D_result_tvalid,
        S_AXIS_A_tdata => mac_D_a_tdata,
        S_AXIS_A_tready => mac_D_a_tready,
        S_AXIS_A_tvalid => mac_D_a_tvalid,
        S_AXIS_B_tdata => mac_D_b_tdata,
        S_AXIS_B_tready => mac_D_b_tready,
        S_AXIS_B_tvalid => mac_D_b_tvalid,
        S_AXIS_C_tdata => mac_D_c_tdata,
        S_AXIS_C_tready => mac_D_c_tready,
        S_AXIS_C_tvalid => mac_D_c_tvalid,
        S_AXIS_OPERATION_tdata => mac_D_operation_tdata,
        S_AXIS_OPERATION_tready => mac_D_operation_tready,
        S_AXIS_OPERATION_tvalid => mac_D_operation_tvalid,
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

    DIV_B : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_tdata => div_B_result_tdata,
        M_AXIS_RESULT_tready => div_B_result_tready,
        M_AXIS_RESULT_tvalid => div_B_result_tvalid,
        S_AXIS_A_tdata => div_B_a_tdata,
        S_AXIS_A_tready => div_B_a_tready,
        S_AXIS_A_tvalid => div_B_a_tvalid,
        S_AXIS_B_tdata => div_B_b_tdata,
        S_AXIS_B_tready => div_B_b_tready,
        S_AXIS_B_tvalid => div_B_b_tvalid,
        aclk   => CLK_100
    );

    DIV_C : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_tdata => div_C_result_tdata,
        M_AXIS_RESULT_tready => div_C_result_tready,
        M_AXIS_RESULT_tvalid => div_C_result_tvalid,
        S_AXIS_A_tdata => div_C_a_tdata,
        S_AXIS_A_tready => div_C_a_tready,
        S_AXIS_A_tvalid => div_C_a_tvalid,
        S_AXIS_B_tdata => div_C_b_tdata,
        S_AXIS_B_tready => div_C_b_tready,
        S_AXIS_B_tvalid => div_C_b_tvalid,
        aclk   => CLK_100
    );

    DIV_D : design_DIV_wrapper
    port map(
        M_AXIS_RESULT_tdata => div_D_result_tdata,
        M_AXIS_RESULT_tready => div_D_result_tready,
        M_AXIS_RESULT_tvalid => div_D_result_tvalid,
        S_AXIS_A_tdata => div_D_a_tdata,
        S_AXIS_A_tready => div_D_a_tready,
        S_AXIS_A_tvalid => div_D_a_tvalid,
        S_AXIS_B_tdata => div_D_b_tdata,
        S_AXIS_B_tready => div_D_b_tready,
        S_AXIS_B_tvalid => div_D_b_tvalid,
        aclk   => CLK_100
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
    inputLocations(8) <= block_A_porta_dout;
    inputLocations(8+1) <= block_A_portb_dout;
    inputLocations(8+2) <= block_B_porta_dout;
    inputLocations(8+3) <= block_B_portb_dout;
    inputLocations(12) <= block_C_porta_dout;
    inputLocations(12+1) <= block_C_portb_dout;
    inputLocations(12+2) <= block_D_porta_dout;
    inputLocations(12+3) <= block_D_portb_dout;
    inputLocations(16) <= block_E_porta_dout;
    inputLocations(16+1) <= block_E_portb_dout;
    inputLocations(16+2) <= block_F_porta_dout;
    inputLocations(16+3) <= block_F_portb_dout;
    inputLocations(20) <= block_G_porta_dout;
    inputLocations(20+1) <= block_G_portb_dout;
    inputLocations(20+2) <= block_H_porta_dout;
    inputLocations(20+3) <= block_H_portb_dout;
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

    mac_A_a_signInv <= not mac_A_a_tdataIN(31);
    mac_A_a_tdata <= mac_A_a_signInv & mac_A_a_tdataIN(30 downto 0);

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

    mac_B_a_signInv <= not mac_B_a_tdataIN(31);
    mac_B_a_tdata <= mac_B_a_signInv & mac_B_a_tdataIN(30 downto 0);

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

    mac_C_a_signInv <= not mac_C_a_tdataIN(31);
    mac_C_a_tdata <= mac_C_a_signInv & mac_C_a_tdataIN(30 downto 0);

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

    mac_D_a_signInv <= not mac_D_a_tdataIN(31);
    mac_D_a_tdata <= mac_D_a_signInv & mac_D_a_tdataIN(30 downto 0);

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
        SEL => block_A_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_A_porta_din
    );

    MUX_BRAM_A_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_A_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_A_portb_din
    );

    MUX_BRAM_B_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_B_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_B_porta_din
    );

    MUX_BRAM_B_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_B_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_B_portb_din
    );

    MUX_BRAM_C_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_C_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_C_porta_din
    );

    MUX_BRAM_C_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_C_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_C_portb_din
    );

    MUX_BRAM_D_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_D_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_D_porta_din
    );

    MUX_BRAM_D_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_D_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_D_portb_din
    );

    MUX_BRAM_E_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_E_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_E_porta_din
    );

    MUX_BRAM_E_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_E_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_E_portb_din
    );

    MUX_BRAM_F_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_F_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_F_porta_din
    );

    MUX_BRAM_F_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_F_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_F_portb_din
    );

    MUX_BRAM_G_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_G_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_G_porta_din
    );

    MUX_BRAM_G_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_G_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_G_portb_din
    );

    MUX_BRAM_H_a_in : entity MUX_BRAM_IN
    port map(
        SEL => block_H_a_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_H_porta_din
    );

    MUX_BRAM_H_b_in : entity MUX_BRAM_IN
    port map(
        SEL => block_H_b_sel,
        DIN => inputLocations(23 downto 0),
        DOUT => block_H_portb_din
    );

    block_A_porta_addr <= CTRL_Signal(CTRL_WIDTH-1 downto CTRL_WIDTH-ADDR_WIDTH);
    block_A_porta_we <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-1);
    block_A_portb_addr <= CTRL_Signal(CTRL_WIDTH-ADDR_WIDTH-2 downto CTRL_WIDTH-2*ADDR_WIDTH-1);
    block_A_portb_we <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-2);
    block_B_porta_addr <= CTRL_Signal(CTRL_WIDTH-2*ADDR_WIDTH-3 downto CTRL_WIDTH-3*ADDR_WIDTH-2);
    block_B_porta_we <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-3);
    block_B_portb_addr <= CTRL_Signal(CTRL_WIDTH-3*ADDR_WIDTH-4 downto CTRL_WIDTH-4*ADDR_WIDTH-3);
    block_B_portb_we <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-4);
    block_C_porta_addr <= CTRL_Signal(CTRL_WIDTH-4*ADDR_WIDTH-5 downto CTRL_WIDTH-5*ADDR_WIDTH-4);
    block_C_porta_we <= CTRL_Signal(CTRL_WIDTH-5*ADDR_WIDTH-5);
    block_C_portb_addr <= CTRL_Signal(CTRL_WIDTH-5*ADDR_WIDTH-6 downto CTRL_WIDTH-6*ADDR_WIDTH-5);
    block_C_portb_we <= CTRL_Signal(CTRL_WIDTH-6 *ADDR_WIDTH-6);
    block_D_porta_addr <= CTRL_Signal(CTRL_WIDTH-6 *ADDR_WIDTH-7 downto CTRL_WIDTH-7*ADDR_WIDTH-6);
    block_D_porta_we <= CTRL_Signal(CTRL_WIDTH-7*ADDR_WIDTH-7);
    block_D_portb_addr <= CTRL_Signal(CTRL_WIDTH-7*ADDR_WIDTH-8 downto CTRL_WIDTH-8*ADDR_WIDTH-7);
    block_D_portb_we <= CTRL_Signal(CTRL_WIDTH-8*ADDR_WIDTH-8);
    block_E_porta_addr <= CTRL_Signal(CTRL_WIDTH-8*ADDR_WIDTH-9 downto CTRL_WIDTH-9*ADDR_WIDTH-8);
    block_E_porta_we <= CTRL_Signal(CTRL_WIDTH-9*ADDR_WIDTH-9);
    block_E_portb_addr <= CTRL_Signal(CTRL_WIDTH-9*ADDR_WIDTH-10 downto CTRL_WIDTH-10*ADDR_WIDTH-9);
    block_E_portb_we <= CTRL_Signal(CTRL_WIDTH-10*ADDR_WIDTH-10);
    block_F_porta_addr <= CTRL_Signal(CTRL_WIDTH-10*ADDR_WIDTH-11 downto CTRL_WIDTH-11*ADDR_WIDTH-10);
    block_F_porta_we <= CTRL_Signal(CTRL_WIDTH-11*ADDR_WIDTH-11);
    block_F_portb_addr <= CTRL_Signal(CTRL_WIDTH-11*ADDR_WIDTH-12 downto CTRL_WIDTH-12*ADDR_WIDTH-11);
    block_F_portb_we <= CTRL_Signal(CTRL_WIDTH-12*ADDR_WIDTH-12);
    block_G_porta_addr <= CTRL_Signal(CTRL_WIDTH-12*ADDR_WIDTH-13 downto CTRL_WIDTH-13*ADDR_WIDTH-12);
    block_G_porta_we <= CTRL_Signal(CTRL_WIDTH-13*ADDR_WIDTH-13);
    block_G_portb_addr <= CTRL_Signal(CTRL_WIDTH-13*ADDR_WIDTH-14 downto CTRL_WIDTH-14*ADDR_WIDTH-13);
    block_G_portb_we <= CTRL_Signal(CTRL_WIDTH-14*ADDR_WIDTH-14);
    block_H_porta_addr <= CTRL_Signal(CTRL_WIDTH-14*ADDR_WIDTH-15 downto CTRL_WIDTH-15*ADDR_WIDTH-14);
    block_H_porta_we <= CTRL_Signal(CTRL_WIDTH-15*ADDR_WIDTH-15);
    block_H_portb_addr <= CTRL_Signal(CTRL_WIDTH-15*ADDR_WIDTH-16 downto CTRL_WIDTH-16*ADDR_WIDTH-15);
    block_H_portb_we <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-16);
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
    block_A_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-BRAM_SEL_WIDTH-16);
    block_A_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-16);
    block_B_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-2*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-16);
    block_B_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-3*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-4*BRAM_SEL_WIDTH-16);
    block_C_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-4*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-5*BRAM_SEL_WIDTH-16);
    block_C_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-5*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-6*BRAM_SEL_WIDTH-16);
    block_D_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-6*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-7*BRAM_SEL_WIDTH-16);
    block_D_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-7*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-8*BRAM_SEL_WIDTH-16);
    block_E_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-8*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-9*BRAM_SEL_WIDTH-16);
    block_E_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-9*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-10*BRAM_SEL_WIDTH-16);
    block_F_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-10*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-11*BRAM_SEL_WIDTH-16);
    block_F_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-11*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-12*BRAM_SEL_WIDTH-16);
    block_G_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-12*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-13*BRAM_SEL_WIDTH-16);
    block_G_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-13*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-14*BRAM_SEL_WIDTH-16);
    block_H_a_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-14*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-15*BRAM_SEL_WIDTH-16);
    block_H_b_sel <= CTRL_Signal(CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-15*BRAM_SEL_WIDTH-17 downto CTRL_WIDTH-16*ADDR_WIDTH-20*AU_SEL_WIDTH-16*BRAM_SEL_WIDTH-16);
--  CTRL_Signal(0) is actually a complete signal which is required by this module during debugging
    block_A_porta_en <= locked;
    block_A_portb_en <= locked;
    block_B_porta_en <= locked;
    block_B_portb_en <= locked;
    block_C_porta_en <= locked;
    block_C_portb_en <= locked;
    block_D_porta_en <= locked;
    block_D_portb_en <= locked;
    block_E_porta_en <= locked;
    block_E_portb_en <= locked;
    block_F_porta_en <= locked;
    block_F_portb_en <= locked;
    block_G_porta_en <= locked;
    block_G_portb_en <= locked;
    block_H_porta_en <= locked;
    block_H_portb_en <= locked;

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
