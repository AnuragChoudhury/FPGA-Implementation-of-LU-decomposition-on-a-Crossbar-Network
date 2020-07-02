
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.types.all;

entity LUDH_TEST_WRAPPER is
    generic(
        ADDR_WIDTH : integer := 12; --Instruction BRAM
        ADDR_WIDTH_DATA_BRAM : integer := 11;
        CTRL_WIDTH : integer := 373;
        AU_SEL_WIDTH : integer := 5;
        BRAM_SEL_WIDTH : integer := 5
    );
    port(
        CLK_100 : in std_logic;
        CLK_200 : in std_logic;

        locked : in std_logic_vector(0 downto 0);
        RST_IN : in std_logic_vector(0 downto 0);
        START : in std_logic_vector(0 downto 0);
        COMPLETED : out std_logic_vector(0 downto 0);
        
        bram_ZYNQ_block_A_addr : in std_logic_vector(ADDR_WIDTH_DATA_BRAM - 1 downto 0);
        bram_ZYNQ_block_A_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_A_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_A_en : in std_logic;
        bram_ZYNQ_block_A_we : in std_logic_vector(3 downto 0);
        
        bram_ZYNQ_block_B_addr : in std_logic_vector(ADDR_WIDTH_DATA_BRAM - 1 downto 0);
        bram_ZYNQ_block_B_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_B_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_B_en : in std_logic;
        bram_ZYNQ_block_B_we : in std_logic_vector(3 downto 0);
        
        bram_ZYNQ_block_C_addr : in std_logic_vector(ADDR_WIDTH_DATA_BRAM - 1 downto 0);
        bram_ZYNQ_block_C_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_C_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_C_en : in std_logic;
        bram_ZYNQ_block_C_we : in std_logic_vector(3 downto 0);
        
        bram_ZYNQ_block_D_addr : in std_logic_vector(ADDR_WIDTH_DATA_BRAM - 1 downto 0);
        bram_ZYNQ_block_D_din : in std_logic_vector(31 downto 0);
        bram_ZYNQ_block_D_dout : out std_logic_vector(31 downto 0);
        bram_ZYNQ_block_D_en : in std_logic;
        bram_ZYNQ_block_D_we : in std_logic_vector(3 downto 0);
        
        bram_ZYNQ_INST_addr : in std_logic_vector(31 downto 0); --20 bits from msb are useless
        bram_ZYNQ_INST_en : in sTD_LOGIC_VECTOR ( 0 to 0 );
        bram_ZYNQ_INST_we : in STD_LOGIC_VECTOR ( 0 to 0 );
        
        bram_ZYNQ_INST_din_part_0 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_1 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_2 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_3 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_4 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_5 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_6 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_7 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_8 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_9 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_10 : in std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_din_part_11 : in std_logic_vector(31 downto 0);        
        
        bram_ZYNQ_INST_dout_part_0 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_1 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_2 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_3 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_4 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_5 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_6 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_7 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_8 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_9 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_10 : out std_logic_vector(31 downto 0);
        bram_ZYNQ_INST_dout_part_11 : out std_logic_vector(31 downto 0);
        
        --debug signals
        debug_state : out std_logic_vector(1 downto 0)
    );
end entity;

architecture justConnect of LUDH_TEST_WRAPPER is

    signal ctrl_signal : std_logic_vector(CTRL_WIDTH-1 downto 0); 
    
    --Instruction memory
    signal bram_ZYNQ_INST_din : std_logic_vector(383 downto 0); -- 11 bits from MSB are useless
    signal bram_ZYNQ_INST_dout : std_logic_vector(383 downto 0); -- 11 bits from MSB are useless
    
    
begin

    bram_ZYNQ_INST_din <= bram_ZYNQ_INST_din_part_11 & bram_ZYNQ_INST_din_part_10 & bram_ZYNQ_INST_din_part_9 & bram_ZYNQ_INST_din_part_8 & bram_ZYNQ_INST_din_part_7 & bram_ZYNQ_INST_din_part_6 & bram_ZYNQ_INST_din_part_5 & bram_ZYNQ_INST_din_part_4 & bram_ZYNQ_INST_din_part_3 & bram_ZYNQ_INST_din_part_2 & bram_ZYNQ_INST_din_part_1 & bram_ZYNQ_INST_din_part_0;
    --bram_ZYNQ_INST_dout <= bram_ZYNQ_INST_dout_part_11 & bram_ZYNQ_INST_dout_part_10 & bram_ZYNQ_INST_dout_part_9 & bram_ZYNQ_INST_dout_part_8 & bram_ZYNQ_INST_dout_part_7 & bram_ZYNQ_INST_dout_part_6 & bram_ZYNQ_INST_dout_part_5 & bram_ZYNQ_INST_dout_part_4 & bram_ZYNQ_INST_dout_part_3 & bram_ZYNQ_INST_dout_part_2 & bram_ZYNQ_INST_dout_part_1 & bram_ZYNQ_INST_dout_part_0;
    bram_ZYNQ_INST_dout_part_0 <= bram_ZYNQ_INST_dout(31 downto 0);
    bram_ZYNQ_INST_dout_part_1 <= bram_ZYNQ_INST_dout(63 downto 32);
    bram_ZYNQ_INST_dout_part_2 <= bram_ZYNQ_INST_dout(95 downto 64);
    bram_ZYNQ_INST_dout_part_3 <= bram_ZYNQ_INST_dout(127 downto 96);
    bram_ZYNQ_INST_dout_part_4 <= bram_ZYNQ_INST_dout(159 downto 128);
    bram_ZYNQ_INST_dout_part_5 <= bram_ZYNQ_INST_dout(191 downto 160);
    bram_ZYNQ_INST_dout_part_6 <= bram_ZYNQ_INST_dout(223 downto 192);
    bram_ZYNQ_INST_dout_part_7 <= bram_ZYNQ_INST_dout(255 downto 224);
    bram_ZYNQ_INST_dout_part_8 <= bram_ZYNQ_INST_dout(287 downto 256);
    bram_ZYNQ_INST_dout_part_9 <= bram_ZYNQ_INST_dout(319 downto 288);
    bram_ZYNQ_INST_dout_part_10 <= bram_ZYNQ_INST_dout(351 downto 320);
    bram_ZYNQ_INST_dout_part_11 <= "00000000000" & bram_ZYNQ_INST_dout(CTRL_WIDTH - 1 downto 352); --The no. of zeroes have to be adjusted if number of bits in control signals changes
    
    tester : entity LUDH_Tester
    generic map(ADDR_WIDTH, CTRL_WIDTH)
    port map(
        CLK_100 => CLK_100,
        locked => locked(0),
        RST => RST_IN(0),
        CTRL_Signal => ctrl_signal,
        COMPLETED => COMPLETED(0),
        START => START(0),
        
        bram_ZYNQ_INST_addr => bram_ZYNQ_INST_addr(ADDR_WIDTH - 1 downto 0),
        bram_ZYNQ_INST_din => bram_ZYNQ_INST_din(CTRL_WIDTH - 1 downto 0),
        bram_ZYNQ_INST_dout => bram_ZYNQ_INST_dout(CTRL_WIDTH - 1 downto 0),
        bram_ZYNQ_INST_en => bram_ZYNQ_INST_en(0),
        bram_ZYNQ_INST_we => bram_ZYNQ_INST_we,
        
        --debug signals
        debug_state => debug_state
    );

    LUDH : entity LUDHardware
    generic map(ADDR_WIDTH_DATA_BRAM, CTRL_WIDTH,AU_SEL_WIDTH,BRAM_SEL_WIDTH)
    port map(
        CLK_100 => CLK_100,
        CLK_200 => CLK_200,
        locked => locked(0),
        CTRL_Signal => ctrl_signal,
        
        bram_ZYNQ_block_A_addr => bram_ZYNQ_block_A_addr(ADDR_WIDTH_DATA_BRAM - 1 downto 0),
        bram_ZYNQ_block_A_din => bram_ZYNQ_block_A_din,
        bram_ZYNQ_block_A_dout => bram_ZYNQ_block_A_dout,
        bram_ZYNQ_block_A_en => bram_ZYNQ_block_A_en,
        bram_ZYNQ_block_A_we => bram_ZYNQ_block_A_we(0),
                
        bram_ZYNQ_block_B_addr => bram_ZYNQ_block_B_addr(ADDR_WIDTH_DATA_BRAM - 1 downto 0),
        bram_ZYNQ_block_B_din => bram_ZYNQ_block_B_din,
        bram_ZYNQ_block_B_dout => bram_ZYNQ_block_B_dout,
        bram_ZYNQ_block_B_en => bram_ZYNQ_block_B_en,
        bram_ZYNQ_block_B_we => bram_ZYNQ_block_B_we(0),
                
        bram_ZYNQ_block_C_addr => bram_ZYNQ_block_C_addr(ADDR_WIDTH_DATA_BRAM - 1 downto 0),
        bram_ZYNQ_block_C_din =>bram_ZYNQ_block_C_din,
        bram_ZYNQ_block_C_dout => bram_ZYNQ_block_C_dout,
        bram_ZYNQ_block_C_en => bram_ZYNQ_block_C_en,
        bram_ZYNQ_block_C_we => bram_ZYNQ_block_C_we(0),
                
        bram_ZYNQ_block_D_addr => bram_ZYNQ_block_D_addr(ADDR_WIDTH_DATA_BRAM - 1 downto 0),
        bram_ZYNQ_block_D_din => bram_ZYNQ_block_D_din,
        bram_ZYNQ_block_D_dout => bram_ZYNQ_block_D_dout,
        bram_ZYNQ_block_D_en => bram_ZYNQ_block_D_en,
        bram_ZYNQ_block_D_we => bram_ZYNQ_block_D_we(0),
        
        bram_ZYNQ_sel => START(0)
    );

end architecture;
