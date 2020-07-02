library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;
use work.types.all;

entity LUDH_Tester is
    generic(
        ADDR_WIDTH : integer := 12;
        CTRL_WIDTH : integer := 357
        --TEST_LENGTH : integer := 2572
    );
    port(
        CLK_100 : in std_logic;
        locked : in std_logic;
        RST : in std_logic;
        CTRL_SIGNAL : inout std_logic_vector(CTRL_WIDTH-1 downto 0);
        COMPLETED : out std_logic;
        START : in std_logic;
        
        --These ports will be connected to the ZYNQ processing system
        bram_ZYNQ_INST_addr : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
        bram_ZYNQ_INST_din : in std_logic_vector(CTRL_WIDTH - 1 downto 0);
        bram_ZYNQ_INST_dout : out std_logic_vector(CTRL_WIDTH - 1 downto 0);
        bram_ZYNQ_INST_en : in std_logic;
        bram_ZYNQ_INST_we : in STD_LOGIC_VECTOR ( 0 to 0 ) ;
        
        --State is send as output for debugging purpose
        debug_state : out std_logic_vector(1 downto 0)
    );
end entity;

architecture yoStyle of LUDH_Tester is
    --Component decleration ********************************************************************************************************************************************************************
    component design_CTRL_wrapper is
    port (
        BRAM_PORTA_0_addr : in STD_LOGIC_VECTOR ( 11 downto 0 );
        BRAM_PORTA_0_clk : in STD_LOGIC;
        BRAM_PORTA_0_din : in STD_LOGIC_VECTOR ( 356 downto 0 );
        BRAM_PORTA_0_dout : out STD_LOGIC_VECTOR ( 356 downto 0 );
        BRAM_PORTA_0_en : in STD_LOGIC;
        BRAM_PORTA_0_we : in STD_LOGIC_VECTOR ( 0 to 0 )
    );
    end component design_CTRL_wrapper;
    --Component decleration end ****************************************************************************************************************************************************************

    signal CTRL_SIGNAL_temp : std_logic_vector(CTRL_WIDTH-1 downto 0);

    signal ctrl_last: std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal ctrl_addr, ctrl_addr_in : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal run_test, test_completed, sync_start : std_logic;
    signal reg_en, complete_bit : std_logic := '0';
    signal reset_counter_reg : std_logic := '1';
    signal reset_counter : std_logic;
    signal pr_state,nxt_state : std_logic_vector(1 downto 0) := "00";
    
    --Mux signals
    signal muxout_addr : std_logic_vector(ADDR_WIDTH - 1 downto 0);
    signal muxout_din : std_logic_vector(CTRL_WIDTH - 1 downto 0);
    signal decoder_input : std_logic_vector(CTRL_WIDTH - 1 downto 0);
    signal muxout_en : std_logic;
    signal muxout_we : STD_LOGIC_VECTOR ( 0 to 0 );
    
begin

    --debug signals
    debug_state <= pr_state;

    complete_bit <= CTRL_SIGNAL(0);
    
    reg_en <= locked and run_test;

    COMPLETED <= test_completed; --This signal is such that it will be 0 only when LUD hardware is running. Else it will be 1
                                 --This is required for the individual cycle bram dump in test bench
    
    reset_counter <= RST or reset_counter_reg;
    
    --once operation is completed, the address will no longer be incremented
    ctrl_addr_in <= std_logic_vector(to_unsigned(to_integer(unsigned(ctrl_addr)) + 1, ADDR_WIDTH)) when (reg_en = '1') else (others => '0');

    ctrlAddrReg : entity myReg
    generic map(ADDR_WIDTH)
    port map(
        CLK => CLK_100,
        ARST => reset_counter,
        ENA => reg_en,
        DIN => ctrl_addr_in,
        DOUT => ctrl_addr
    );
    
    --This register ensures that the sync_start signal is 1 always at the rising edge of clock and not somewhere in between the clock.
--    sync_start_reg : entity myReg_single_bit
--    port map(
--        CLK => CLK_100,
--        ARST => RST,
--        ENA => '1',
--        DIN => START,
--        DOUT => sync_start
--    );
    sync_start <= START;
    
    --FSM
    --sync_start and complete_bit are the input to FSM. test_completed, reset_counter_reg, and run_test are the output to FSM
    process(CLK_100)
    begin
    if(CLK_100'event and CLK_100 = '1') then
        If(RST = '1') then
            pr_state <= "00";
        else
            pr_state <= nxt_state;
        end if;
    end if;
    end process;
    
    process(pr_state, sync_start, complete_bit)
    begin
    case pr_state is
    when "00" =>
        test_completed <= '1';
        run_test <= '0';
        reset_counter_reg <= '1';
        if(sync_start = '1') then
            nxt_state <= "01";
        else
            nxt_state <= "00";
        end if;
    when "01" =>
        test_completed <= '0';
        run_test <= '1';
        reset_counter_reg <= '0';
        if(sync_start = '1') then
            if(complete_bit = '1') then
                nxt_state <= "10";
            elsif(complete_bit = '0')then
                nxt_state <= "01";
            end if;
        else
            nxt_state <= "00";
        end if;
    when "10" =>
        test_completed <= '1';
        run_test <= '0';
        reset_counter_reg <= '0';
        if(sync_start = '1') then
            nxt_state <= "10";
        else
            nxt_state <= "00";
        end if;
    when others =>
        test_completed <= '1';
        run_test <= '0';
        reset_counter_reg <= '1';
        nxt_state <= "00";
    end case;
    end process;
    
    ctrlStorage : design_CTRL_wrapper
    port map (
    BRAM_PORTA_0_addr => muxout_addr ,
    BRAM_PORTA_0_clk => CLK_100,
    BRAM_PORTA_0_din => muxout_din ,
    BRAM_PORTA_0_dout => decoder_input ,
    BRAM_PORTA_0_en => muxout_en ,
    BRAM_PORTA_0_we => muxout_we
    );
    
    muxout_addr <= bram_ZYNQ_INST_addr when (sync_start = '0') else ctrl_addr(ADDR_WIDTH-1 downto 0);
    muxout_din <= bram_ZYNQ_INST_din when (sync_start = '0') else (others => '0');
    muxout_en <= bram_ZYNQ_INST_en when (sync_start = '0') else '1';
    muxout_we <= bram_ZYNQ_INST_we when (sync_start = '0') else "0";
    
    bram_ZYNQ_decoder_INST :entity bram_ZYNQ_decoder
    generic map (width => CTRL_WIDTH)
    port map(decoder_in => decoder_input,
          decoder_out_0 => bram_ZYNQ_INST_dout,
          decoder_out_1 => CTRL_SIGNAL_temp,
          sel => sync_start
    );
    
    CTRL_SIGNAL <= (others => '0') when (sync_start = '0') else CTRL_SIGNAL_temp;
end architecture;
