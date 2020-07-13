library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.all;

entity quadPortBRAM is
    generic(
        ADDR_WIDTH : integer := 11;
        DATA_WIDTH : integer := 32
    );
    port
    (
        CLK_1X          : in std_logic;
        CLK_2X          : in std_logic;
        RST             : in std_logic;
        BRAM_PORTA_ADDR : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        BRAM_PORTA_DIN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTA_DOUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTA_EN   : in  std_logic;
        BRAM_PORTA_WE   : in  std_logic;
        BRAM_PORTB_ADDR : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        BRAM_PORTB_DIN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTB_DOUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTB_EN   : in  std_logic;
        BRAM_PORTB_WE   : in  std_logic;
        BRAM_PORTC_ADDR : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        BRAM_PORTC_DIN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTC_DOUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTC_EN   : in  std_logic;
        BRAM_PORTC_WE   : in  std_logic;
        BRAM_PORTD_ADDR : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
        BRAM_PORTD_DIN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTD_DOUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BRAM_PORTD_EN   : in  std_logic;
        BRAM_PORTD_WE   : in  std_logic;

        BLOCK_PORTA_ADDR: out std_logic_vector(ADDR_WIDTH-1 downto 0);
        BLOCK_PORTA_DIN : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BLOCK_PORTA_DOUT: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BLOCK_PORTA_EN  : out std_logic;
        BLOCK_PORTA_WE  : out std_logic;

        BLOCK_PORTB_ADDR: out std_logic_vector(ADDR_WIDTH-1 downto 0);
        BLOCK_PORTB_DIN : out std_logic_vector(DATA_WIDTH-1 downto 0);
        BLOCK_PORTB_DOUT: in  std_logic_vector(DATA_WIDTH-1 downto 0);
        BLOCK_PORTB_EN  : out std_logic;
        BLOCK_PORTB_WE  : out std_logic
    );
end entity;

 architecture behav of quadPortBRAM is

     signal reg_portA : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal reg_portA_addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0);
     signal reg_portA_din_out : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal reg_portA_en_out : std_logic;
     signal reg_portA_we_out : std_logic;

     signal reg_portB : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal mux_out_portB : std_logic_vector(DATA_WIDTH-1 downto 0);
     
     signal reg_portB_addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0);
     signal reg_portB_din_out : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal reg_portB_en_out : std_logic;
     signal reg_portB_we_out : std_logic;

     signal reg_portC: std_logic_vector(DATA_WIDTH-1 downto 0);
     
     signal reg_portC_addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0);
     signal reg_portC_din_out : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal reg_portC_en_out : std_logic;
     signal reg_portC_we_out : std_logic;

     signal reg_portD : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal mux_out_portD : std_logic_vector(DATA_WIDTH-1 downto 0);
     
     signal reg_portD_addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0);
     signal reg_portD_din_out : std_logic_vector(DATA_WIDTH-1 downto 0);
     signal reg_portD_en_out : std_logic;
     signal reg_portD_we_out : std_logic;

     signal mux_sel : std_logic;
     signal mux_sel_1 : std_logic;
     signal reg_ena : std_logic;
     signal input_latch_ena : std_logic;
     signal latch_ena : std_logic;
     signal portACOutReg0ENA : std_logic;
     signal portBDOutReg0ENA : std_logic;

     signal portAInReg_in, portAInReg_out : std_logic_vector(DATA_WIDTH + ADDR_WIDTH + 1 downto 0);
     signal portBInReg_in, portBInReg_out : std_logic_vector(DATA_WIDTH + ADDR_WIDTH + 1 downto 0);
     signal portCInReg_in, portCInReg_out : std_logic_vector(DATA_WIDTH + ADDR_WIDTH + 1 downto 0);
     signal portDInReg_in, portDInReg_out : std_logic_vector(DATA_WIDTH + ADDR_WIDTH + 1 downto 0);
     
     signal CLK_2X_delayed, CLK_1X_delayed : std_logic;

 begin
     
     CLK_2X_delayed <= CLK_2X;
     CLK_1X_delayed <= CLK_1X;
     
     --mux_sel <= CLK_1X xor CLK_2X;
     
     process(CLK_2X, CLK_1X)
     begin
     If(CLK_2X'event and  CLK_2X = '0')then
     if(CLK_1X = '0')then
        mux_sel <= '0';
     else
        mux_sel <= '1';
     end if;
     end if;
     end process;
     
     process(CLK_2X, mux_sel)
     begin
     If(CLK_2X'event and  CLK_2X = '1')then
     if(mux_sel = '1')then
        mux_sel_1 <= '0';
     else
        mux_sel_1 <= '1';
     end if;
     end if;
     end process;
     
     reg_ena <= not RST;
     latch_ena <= (not RST) and CLK_1X and CLK_2X and (not mux_sel);
     input_latch_ena <= (not RST) and (not CLK_1X) and (not CLK_2X) and (not mux_sel);
     portACOutReg0ENA <= mux_sel and (reg_ena);
     portBDOutReg0ENA <= (not mux_sel) and (reg_ena);
     
     BLOCK_PORTA_ADDR <= reg_portA_addr_out when (mux_sel = '0') else reg_portB_addr_out;
     BLOCK_PORTA_DIN  <= reg_portA_din_out  when (mux_sel = '0') else reg_portB_din_out;
     BLOCK_PORTA_EN   <= reg_portA_en_out   when (mux_sel = '0') else reg_portB_en_out;
     BLOCK_PORTA_WE   <= reg_portA_we_out   when (mux_sel = '0') else reg_portB_we_out;

     BLOCK_PORTB_ADDR <= reg_portC_addr_out when (mux_sel = '0') else reg_portD_addr_out;
     BLOCK_PORTB_DIN  <= reg_portC_din_out  when (mux_sel = '0') else reg_portD_din_out;
     BLOCK_PORTB_EN   <= reg_portC_en_out   when (mux_sel = '0') else reg_portD_en_out;
     BLOCK_PORTB_WE   <= reg_portC_we_out   when (mux_sel = '0') else reg_portD_we_out;

     portBInReg_in       <= BRAM_PORTB_ADDR & BRAM_PORTB_DIN & BRAM_PORTB_EN & BRAM_PORTB_WE;
     reg_portB_addr_out  <= portBInReg_out(portBInReg_out'length-1 downto 2 + DATA_WIDTH);
     reg_portB_din_out   <= portBInReg_out(1 + DATA_WIDTH downto 2);
     reg_portB_en_out    <= portBInReg_out(1);
     reg_portB_we_out    <= portBInReg_out(0);
     
     portAInReg_in       <= BRAM_PORTA_ADDR & BRAM_PORTA_DIN & BRAM_PORTA_EN & BRAM_PORTA_WE;
     reg_portA_addr_out  <= portAInReg_out(portAInReg_out'length-1 downto 2 + DATA_WIDTH);
     reg_portA_din_out   <= portAInReg_out(1 + DATA_WIDTH downto 2);
     reg_portA_en_out    <= portAInReg_out(1);
     reg_portA_we_out    <= portAInReg_out(0);

     portBInLatch : entity myLatch
     generic map(ADDR_WIDTH + DATA_WIDTH + 2)
     port map(
         ARST => RST,
         ENA => input_latch_ena,
         DIN => portBInReg_in,
         DOUT => portBInReg_out
     );
     
     portAInLatch : entity myLatch
     generic map(ADDR_WIDTH + DATA_WIDTH + 2)
     port map(
         ARST => RST,
         ENA => input_latch_ena,
         DIN => portAInReg_in,
         DOUT => portAInReg_out
     );
     
     portBOutReg0 : entity myReg
     generic map(DATA_WIDTH)
     port map(
         CLK => CLK_2X,
         ARST => RST,
         ENA => portBDOutReg0ENA,
         DIN => BLOCK_PORTA_DOUT,
         DOUT => reg_portB
     );
     
     mux_out_portB <= BLOCK_PORTA_DOUT when (mux_sel_1 = '0') else reg_portB;

     portBOutLatch : entity myLatch
     generic map(DATA_WIDTH)
     port map(
         ARST => RST,
         ENA => latch_ena,
         DIN => mux_out_portB,
         DOUT => BRAM_PORTB_DOUT
     );

     portAOutReg0 : entity myReg
     generic map(DATA_WIDTH)
     port map(
         CLK => CLK_2X,
         ARST => RST,
         ENA => portACOutReg0ENA,
         DIN => BLOCK_PORTA_DOUT,
         DOUT => reg_portA
     );

     portAOutLatch : entity myLatch
     generic map(DATA_WIDTH)
     port map(
         ARST => RST,
         ENA => latch_ena,
         DIN => reg_portA,
         DOUT => BRAM_PORTA_DOUT
     );

     portDInReg_in <= BRAM_PORTD_ADDR & BRAM_PORTD_DIN & BRAM_PORTD_EN & BRAM_PORTD_WE;
     reg_portD_addr_out  <= portDInReg_out(portDInReg_out'length-1 downto 2 + DATA_WIDTH);
     reg_portD_din_out   <= portDInReg_out(1 + DATA_WIDTH downto 2);
     reg_portD_en_out    <= portDInReg_out(1);
     reg_portD_we_out    <= portDInReg_out(0);
     
     portCInReg_in       <= BRAM_PORTC_ADDR & BRAM_PORTC_DIN & BRAM_PORTC_EN & BRAM_PORTC_WE;
     reg_portC_addr_out  <= portCInReg_out(portCInReg_out'length-1 downto 2 + DATA_WIDTH);
     reg_portC_din_out   <= portCInReg_out(1 + DATA_WIDTH downto 2);
     reg_portC_en_out    <= portCInReg_out(1);
     reg_portC_we_out    <= portCInReg_out(0);

     portDInLatch : entity myLatch
     generic map(ADDR_WIDTH + DATA_WIDTH + 2)
     port map(
         ARST => RST,
         ENA => input_latch_ena,
         DIN => portDInReg_in,
         DOUT => portDInReg_out
     );
     
     portCInLatch : entity myLatch
     generic map(ADDR_WIDTH + DATA_WIDTH + 2)
     port map(
         ARST => RST,
         ENA => input_latch_ena,
         DIN => portCInReg_in,
         DOUT => portCInReg_out
     );
     
     portDOutReg0 : entity myReg
     generic map(DATA_WIDTH)
     port map(
         CLK => CLK_2X,
         ARST => RST,
         ENA => portBDOutReg0ENA,
         DIN => BLOCK_PORTB_DOUT,
         DOUT => reg_portD
     );
     
     mux_out_portD <= BLOCK_PORTB_DOUT when (mux_sel_1 = '0') else reg_portD;

     portDOutLatch : entity myLatch
     generic map(DATA_WIDTH)
     port map(
         ARST => RST,
         ENA => latch_ena,
         DIN => mux_out_portD,
         DOUT => BRAM_PORTD_DOUT
     );

     portCOutReg0 : entity myReg
     generic map(DATA_WIDTH)
     port map(
         CLK => CLK_2X,
         ARST => RST,
         ENA => portACOutReg0ENA,
         DIN => BLOCK_PORTB_DOUT,
         DOUT => reg_portC
     );

     portCOutLatch : entity myLatch
     generic map(DATA_WIDTH)
     port map(
         ARST => RST,
         ENA => latch_ena,
         DIN => reg_portC,
         DOUT => BRAM_PORTC_DOUT
     );

 end architecture;
