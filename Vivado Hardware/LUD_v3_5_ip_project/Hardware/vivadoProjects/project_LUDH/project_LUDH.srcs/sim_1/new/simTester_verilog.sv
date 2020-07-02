`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.12.2019 07:59:36
// Design Name: 
// Module Name: simTester_verilog
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module simTester_verilog();
reg CLK_100, CLK_200, locked, RST_IN,start_sig;
wire  completed;
localparam time t_100 = 40;
localparam time t_200 = 20;

localparam integer ADDR_WIDTH = 12;
localparam integer INST_BRAM_SIZE = 2**ADDR_WIDTH;
localparam integer ADDR_WIDTH_DATA_BRAM = 11;
localparam integer DATA_BRAM_SIZE = 2**ADDR_WIDTH_DATA_BRAM;
localparam integer CTRL_WIDTH = 373;
localparam integer AU_SEL_WIDTH = 5;
localparam integer BRAM_SEL_WIDTH = 5;

localparam integer BRAM_LIMIT_IND_DEBUG = 4; //It indicates that BRAM contents from location 0 to BRAM_LIMIT_IND_DEBUG will be dumped for all 4 BRAMS for every cycle

//Constant array to load the A matrix
localparam integer A_size = 11;
localparam longint A[0:10] = '{64'h4014000000000000, 64'h4000000000000000, 64'h3ff0000000000000, 64'h4010000000000000, 64'hc008000000000000, 64'hc014000000000000, 64'hc000000000000000, 64'hc010000000000000, 64'hbff0000000000000, 64'h4018000000000000, 64'h4008000000000000};
localparam integer A_BRAMInd[0:10] = '{0, 1, 2, 3, 0, 1, 0, 1, 2, 3, 2};
localparam integer A_BRAMAddr[0:10] = '{0, 0, 0, 0, 1, 1, 2, 2, 2, 2, 3};

//Constant array to load the instruction BRAM
localparam integer total_instructions = 112;
localparam integer sub_instructions = 6;
localparam longint Inst[0:111][0:5] = '{{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h40000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h9a410c40000000, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h8000000, 64'h400000000000000, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h600005000000000, 64'h7000000000004000, 64'hc36185c50d8a1, 64'h0, 64'h200000000000200, 64'h60000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h800000000000800, 64'h40000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'hc440000000000, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h80000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h300000000000000, 64'h10200000002000, 64'h0, 64'h0, 64'he00000000000600, 64'he0000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'ha00, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'hc00, 64'hc0000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h40000, 64'h5000, 64'h82c0000000000, 64'h6000000, 64'h0, 64'ha0000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h4000000, 64'hc00000000000000, 64'hc0000000000},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h8a30000000000, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'he00, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'he00000000000000, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h0, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0},{64'h1, 64'h0, 64'h0, 64'h0, 64'h0, 64'h0}};


//For 1st BRAM
wire [ADDR_WIDTH_DATA_BRAM - 1 : 0]bram_ZYNQ_block_A_addr;
reg [63:0]bram_ZYNQ_block_A_din;
wire [63:0]bram_ZYNQ_block_A_dout;
wire bram_ZYNQ_block_A_en;
wire [3:0]bram_ZYNQ_block_A_we;

//For 2nd BRAM
wire [ADDR_WIDTH_DATA_BRAM - 1 : 0]bram_ZYNQ_block_B_addr;
reg [63:0]bram_ZYNQ_block_B_din;
wire [63:0]bram_ZYNQ_block_B_dout;
wire bram_ZYNQ_block_B_en;
wire [3:0]bram_ZYNQ_block_B_we;

//For 3rd BRAM
wire [ADDR_WIDTH_DATA_BRAM - 1 : 0]bram_ZYNQ_block_C_addr;
reg [63:0]bram_ZYNQ_block_C_din;
wire [63:0]bram_ZYNQ_block_C_dout;
wire bram_ZYNQ_block_C_en;
wire [3:0]bram_ZYNQ_block_C_we;

//For 4th BRAM
wire [ADDR_WIDTH_DATA_BRAM - 1 : 0]bram_ZYNQ_block_D_addr;
reg [63:0]bram_ZYNQ_block_D_din;
wire [63:0]bram_ZYNQ_block_D_dout;
wire bram_ZYNQ_block_D_en;
wire [3:0]bram_ZYNQ_block_D_we;

//Instruction BRAM
wire [31:0]bram_ZYNQ_INST_addr;
wire bram_ZYNQ_INST_en;
wire bram_ZYNQ_INST_we;

wire [63:0]bram_ZYNQ_INST_din_part_0;
wire [63:0]bram_ZYNQ_INST_din_part_1;
wire [63:0]bram_ZYNQ_INST_din_part_2;
wire [63:0]bram_ZYNQ_INST_din_part_3;
wire [63:0]bram_ZYNQ_INST_din_part_4;
wire [63:0]bram_ZYNQ_INST_din_part_5;

wire [63:0]bram_ZYNQ_INST_dout_part_0;
wire [63:0]bram_ZYNQ_INST_dout_part_1;
wire [63:0]bram_ZYNQ_INST_dout_part_2;
wire [63:0]bram_ZYNQ_INST_dout_part_3;
wire [63:0]bram_ZYNQ_INST_dout_part_4;
wire [63:0]bram_ZYNQ_INST_dout_part_5;

//debug signals
wire [1:0]debug_state;

reg [31:0]fptr;
integer count;
reg complete_bit;

//Mux signals
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_A_0; //For dumping BRAM contents
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_A_1; //For clearing
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_A_2; //For loading A matrix
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_A_3; //Currently unused
wire [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_A_dout;
reg [1:0]sel_mux_dataBRAM;

reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_B_0; //For dumping BRAM contents
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_B_1; //For clearing
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_B_2; //For loading A matrix
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_B_3; //Currently unused
wire [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_B_dout;

reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_C_0; //For dumping BRAM contents
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_C_1; //For clearing
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_C_2; //For loading A matrix
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_C_3; //Currently unused
wire [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_C_dout;

reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_D_0; //For dumping BRAM contents
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_D_1; //For clearing
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_D_2; //For loading A matrix
reg [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_D_3; //Currently unused
wire [ADDR_WIDTH_DATA_BRAM-1:0]mux_dataBRAM_D_dout;

reg mux_dataBRAM_A_en0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_A_en1 = 0; //For clearing
reg mux_dataBRAM_A_en2 = 0; //For loading A matrix
reg mux_dataBRAM_A_en3 = 0; //Currently unused
wire mux_dataBRAM_A_endout;

reg mux_dataBRAM_B_en0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_B_en1 = 0; //For clearing
reg mux_dataBRAM_B_en2 = 0; //For loading A matrix
reg mux_dataBRAM_B_en3 = 0; //Currently unused
wire mux_dataBRAM_B_endout;

reg mux_dataBRAM_C_en0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_C_en1 = 0; //For clearing
reg mux_dataBRAM_C_en2 = 0; //For loading A matrix
reg mux_dataBRAM_C_en3 = 0; //Currently unused
wire mux_dataBRAM_C_endout;

reg mux_dataBRAM_D_en0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_D_en1 = 0; //For clearing
reg mux_dataBRAM_D_en2 = 0; //For loading A matrix
reg mux_dataBRAM_D_en3 = 0; //Currently unused
wire mux_dataBRAM_D_endout;

reg mux_dataBRAM_A_we0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_A_we1 = 0; //For clearing
reg mux_dataBRAM_A_we2 = 0; //For loading A matrix
reg mux_dataBRAM_A_we3 = 0; //Currently unused
wire mux_dataBRAM_A_wedout;

reg mux_dataBRAM_B_we0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_B_we1 = 0; //For clearing
reg mux_dataBRAM_B_we2 = 0; //For loading A matrix
reg mux_dataBRAM_B_we3 = 0; //Currently unused
wire mux_dataBRAM_B_wedout;

reg mux_dataBRAM_C_we0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_C_we1 = 0; //For clearing
reg mux_dataBRAM_C_we2 = 0; //For loading A matrix
reg mux_dataBRAM_C_we3 = 0; //Currently unused
wire mux_dataBRAM_C_wedout;

reg mux_dataBRAM_D_we0 = 0; //For dumping BRAM contents
reg mux_dataBRAM_D_we1 = 0; //For clearing
reg mux_dataBRAM_D_we2 = 0; //For loading A matrix
reg mux_dataBRAM_D_we3 = 0; //Currently unused
wire mux_dataBRAM_D_wedout;

reg [63:0]mux_dataBRAM_A_din0; //for clearing the data BRAMS
reg [63:0]mux_dataBRAM_A_din1; //for loading the data BRAMS
wire [63:0]mux_dataBRAM_A_din_out;
reg sel_mux_dataBRAM_din;

reg [63:0]mux_dataBRAM_B_din0; //for clearing the data BRAMS
reg [63:0]mux_dataBRAM_B_din1; //for loading the data BRAMS
wire [63:0]mux_dataBRAM_B_din_out;

reg [63:0]mux_dataBRAM_C_din0; //for clearing the data BRAMS
reg [63:0]mux_dataBRAM_C_din1; //for loading the data BRAMS
wire [63:0]mux_dataBRAM_C_din_out;

reg [63:0]mux_dataBRAM_D_din0; //for clearing the data BRAMS
reg [63:0]mux_dataBRAM_D_din1; //for loading the data BRAMS
wire [63:0]mux_dataBRAM_D_din_out;

//Instruction BRAM muxes
reg [63:0]instBRAM_part0_din;
reg [63:0]instBRAM_part1_din;
reg [63:0]instBRAM_part2_din;
reg [63:0]instBRAM_part3_din;
reg [63:0]instBRAM_part4_din;
reg [63:0]instBRAM_part5_din;

reg instBRAM_en = 0;
reg instBRAM_we = 0;
reg [ADDR_WIDTH-1:0]instBRAM_addr;


//Memory dump start and complete signals
reg start_mem_dump;
reg mem_dump_complete;
reg start_dataBRAM_erase;
reg dataBRAM_erase_complete;
reg start_A_load;
reg A_load_complete;
reg start_instBRAM_erase;
reg instBRAM_erase_complete;
reg start_inst_load;
reg inst_load_complete;
reg start_full_run;
reg complete_full_run;
reg start0; //For full run
reg complete_sig;

LUDH_TEST_WRAPPER #(ADDR_WIDTH,ADDR_WIDTH_DATA_BRAM,CTRL_WIDTH,AU_SEL_WIDTH,BRAM_SEL_WIDTH) uut1 (
CLK_100,
CLK_200,
locked,
RST_IN,
start_sig,
completed,

//First BRAM
bram_ZYNQ_block_A_addr, 
bram_ZYNQ_block_A_din, 
bram_ZYNQ_block_A_dout, 
bram_ZYNQ_block_A_en,
bram_ZYNQ_block_A_we, 

//Second BRAM
bram_ZYNQ_block_B_addr, 
bram_ZYNQ_block_B_din, 
bram_ZYNQ_block_B_dout, 
bram_ZYNQ_block_B_en,
bram_ZYNQ_block_B_we, 

//Third BRAM
bram_ZYNQ_block_C_addr, 
bram_ZYNQ_block_C_din, 
bram_ZYNQ_block_C_dout, 
bram_ZYNQ_block_C_en,
bram_ZYNQ_block_C_we, 

//Fourth BRAM
bram_ZYNQ_block_D_addr, 
bram_ZYNQ_block_D_din, 
bram_ZYNQ_block_D_dout, 
bram_ZYNQ_block_D_en,
bram_ZYNQ_block_D_we, 

//Instruction BRAM
bram_ZYNQ_INST_addr,
bram_ZYNQ_INST_en,
bram_ZYNQ_INST_we,
        
bram_ZYNQ_INST_din_part_0,
bram_ZYNQ_INST_din_part_1,
bram_ZYNQ_INST_din_part_2,
bram_ZYNQ_INST_din_part_3,
bram_ZYNQ_INST_din_part_4,
bram_ZYNQ_INST_din_part_5,
        
bram_ZYNQ_INST_dout_part_0,
bram_ZYNQ_INST_dout_part_1,
bram_ZYNQ_INST_dout_part_2,
bram_ZYNQ_INST_dout_part_3,
bram_ZYNQ_INST_dout_part_4,
bram_ZYNQ_INST_dout_part_5,
        
//debug signals
debug_state
);

initial begin
CLK_100 = 1'b1;
forever #(t_100/2) CLK_100 = ~CLK_100;
end

initial begin
CLK_200 = 1'b1;
forever #(t_200/2) CLK_200 = ~CLK_200;
end

//Initiallizing the mux to be used for DATA BRAMS address multiplexing
//For address
mux_4x1 #(ADDR_WIDTH_DATA_BRAM) uut2(mux_dataBRAM_A_dout,mux_dataBRAM_A_0,mux_dataBRAM_A_1,mux_dataBRAM_A_2,mux_dataBRAM_A_3,sel_mux_dataBRAM);
mux_4x1 #(ADDR_WIDTH_DATA_BRAM) uut3(mux_dataBRAM_B_dout,mux_dataBRAM_B_0,mux_dataBRAM_B_1,mux_dataBRAM_B_2,mux_dataBRAM_B_3,sel_mux_dataBRAM);
mux_4x1 #(ADDR_WIDTH_DATA_BRAM) uut4(mux_dataBRAM_C_dout,mux_dataBRAM_C_0,mux_dataBRAM_C_1,mux_dataBRAM_C_2,mux_dataBRAM_C_3,sel_mux_dataBRAM);
mux_4x1 #(ADDR_WIDTH_DATA_BRAM) uut5(mux_dataBRAM_D_dout,mux_dataBRAM_D_0,mux_dataBRAM_D_1,mux_dataBRAM_D_2,mux_dataBRAM_D_3,sel_mux_dataBRAM);

//For enable
mux_4x1 #(1) uut6(mux_dataBRAM_A_endout,mux_dataBRAM_A_en0,mux_dataBRAM_A_en1,mux_dataBRAM_A_en2,mux_dataBRAM_A_en3,sel_mux_dataBRAM);
mux_4x1 #(1) uut7(mux_dataBRAM_B_endout,mux_dataBRAM_B_en0,mux_dataBRAM_B_en1,mux_dataBRAM_B_en2,mux_dataBRAM_B_en3,sel_mux_dataBRAM);
mux_4x1 #(1) uut8(mux_dataBRAM_C_endout,mux_dataBRAM_C_en0,mux_dataBRAM_C_en1,mux_dataBRAM_C_en2,mux_dataBRAM_C_en3,sel_mux_dataBRAM);
mux_4x1 #(1) uut9(mux_dataBRAM_D_endout,mux_dataBRAM_D_en0,mux_dataBRAM_D_en1,mux_dataBRAM_D_en2,mux_dataBRAM_D_en3,sel_mux_dataBRAM);

//For Write enable
mux_4x1 #(1) uut10(mux_dataBRAM_A_wedout,mux_dataBRAM_A_we0,mux_dataBRAM_A_we1,mux_dataBRAM_A_we2,mux_dataBRAM_A_we3,sel_mux_dataBRAM);
mux_4x1 #(1) uut11(mux_dataBRAM_B_wedout,mux_dataBRAM_B_we0,mux_dataBRAM_B_we1,mux_dataBRAM_B_we2,mux_dataBRAM_B_we3,sel_mux_dataBRAM);
mux_4x1 #(1) uut12(mux_dataBRAM_C_wedout,mux_dataBRAM_C_we0,mux_dataBRAM_C_we1,mux_dataBRAM_C_we2,mux_dataBRAM_C_we3,sel_mux_dataBRAM);
mux_4x1 #(1) uut13(mux_dataBRAM_D_wedout,mux_dataBRAM_D_we0,mux_dataBRAM_D_we1,mux_dataBRAM_D_we2,mux_dataBRAM_D_we3,sel_mux_dataBRAM);

//For din
mux_2x1 #(64) uut14(mux_dataBRAM_A_din_out,mux_dataBRAM_A_din0,mux_dataBRAM_A_din1,sel_mux_dataBRAM_din);
mux_2x1 #(64) uut15(mux_dataBRAM_B_din_out,mux_dataBRAM_B_din0,mux_dataBRAM_B_din1,sel_mux_dataBRAM_din);
mux_2x1 #(64) uut16(mux_dataBRAM_C_din_out,mux_dataBRAM_C_din0,mux_dataBRAM_C_din1,sel_mux_dataBRAM_din);
mux_2x1 #(64) uut17(mux_dataBRAM_D_din_out,mux_dataBRAM_D_din0,mux_dataBRAM_D_din1,sel_mux_dataBRAM_din);


initial begin
start_mem_dump <= 0;
mem_dump_complete <= 0;
start_dataBRAM_erase <= 0;
dataBRAM_erase_complete <= 0;
start_A_load <= 0;
A_load_complete <= 0;
start_instBRAM_erase <= 0;
instBRAM_erase_complete <= 0;
start_inst_load <= 0;
inst_load_complete <= 0;
complete_full_run <= 0;
sel_mux_dataBRAM <= 2'b00;
sel_mux_dataBRAM_din <= 1'b0;

count <= -1;
complete_bit <= 1'b0;
locked <= 1'b0;

#(t_100*50)
start_full_run <= 1'b0;

#(t_100*50)
RST_IN <= 1'b1;

//Resetting the contents of data BRAMS and Inst BRAM
#(t_100*50)
sel_mux_dataBRAM <= 2'b01;
sel_mux_dataBRAM_din <= 1'b0;
start_dataBRAM_erase <= 1'b1;

@(posedge dataBRAM_erase_complete)
#(t_100*50)
start_dataBRAM_erase <= 0;

#(t_100*50)
start_instBRAM_erase <= 1'b1;

@(posedge instBRAM_erase_complete)
#(t_100*50)
start_instBRAM_erase <= 0;

//Loading the A matrix
#(t_100*50)
sel_mux_dataBRAM <= 2'b10;
sel_mux_dataBRAM_din <= 1'b1;
start_A_load <= 1'b1;

@(posedge A_load_complete)
#(t_100*50)
start_A_load <= 0;

//RST = 0
#(t_100*50)
RST_IN <= 1'b0;

//Locked = 1
#(t_100*50)
locked <= 1'b1;

//Loading the instruction matrix and starting LU Decomposition
#(t_100*50)
start_full_run = 1'b1;

@(posedge complete_sig)
complete_bit <= 1'b1;
#(t_100*50)
start_full_run <= 1'b0;

#(t_100*50)
sel_mux_dataBRAM <= 2'b00;
start_mem_dump <= 1;

@(posedge mem_dump_complete)
#(t_100*50)
start_mem_dump <= 0;
$stop;

end

assign start_sig = start0;
assign complete_sig = complete_full_run;

//Address signals(data BRAM)
assign bram_ZYNQ_block_A_addr = mux_dataBRAM_A_dout;
assign bram_ZYNQ_block_B_addr = mux_dataBRAM_B_dout;
assign bram_ZYNQ_block_C_addr = mux_dataBRAM_C_dout;
assign bram_ZYNQ_block_D_addr = mux_dataBRAM_D_dout;

//Enable signals(data BRAM)
assign bram_ZYNQ_block_A_en = mux_dataBRAM_A_endout;
assign bram_ZYNQ_block_B_en = mux_dataBRAM_B_endout;
assign bram_ZYNQ_block_C_en = mux_dataBRAM_C_endout;
assign bram_ZYNQ_block_D_en = mux_dataBRAM_D_endout;

//Write enable signals(data BRAM)
assign bram_ZYNQ_block_A_we = mux_dataBRAM_A_wedout;
assign bram_ZYNQ_block_B_we = mux_dataBRAM_B_wedout;
assign bram_ZYNQ_block_C_we = mux_dataBRAM_C_wedout;
assign bram_ZYNQ_block_D_we = mux_dataBRAM_D_wedout;

//din signals(data BRAM)
assign bram_ZYNQ_block_A_din = mux_dataBRAM_A_din_out;
assign bram_ZYNQ_block_B_din = mux_dataBRAM_B_din_out;
assign bram_ZYNQ_block_C_din = mux_dataBRAM_C_din_out;
assign bram_ZYNQ_block_D_din = mux_dataBRAM_D_din_out;

//Address signal(inst BRAM)
assign bram_ZYNQ_INST_addr = instBRAM_addr;

//Enable signal(inst BRAM)
assign bram_ZYNQ_INST_en = instBRAM_en;

//Write enable signal(inst BRAM)
assign bram_ZYNQ_INST_we = instBRAM_we;

//din signal(inst BRAM)
assign bram_ZYNQ_INST_din_part_0 = instBRAM_part0_din;
assign bram_ZYNQ_INST_din_part_1 = instBRAM_part1_din;
assign bram_ZYNQ_INST_din_part_2 = instBRAM_part2_din;
assign bram_ZYNQ_INST_din_part_3 = instBRAM_part3_din;
assign bram_ZYNQ_INST_din_part_4 = instBRAM_part4_din;
assign bram_ZYNQ_INST_din_part_5 = instBRAM_part5_din;


//Always block for full run
always@(posedge CLK_100) begin
if(CLK_100  == 1 && start_full_run == 1 && complete_full_run != 1) begin
//Start loading complete instructions
start_inst_load <= 1'b1;
@(posedge inst_load_complete)
#(t_100*50)
start_inst_load <= 0;

//Start the LU Decomposition
#(t_100*50)
start0 <= 1'b1;
complete_full_run <= 1'b0;

//Waiting for completion
@(posedge completed)
complete_full_run <= 1'b1;

end
else if(CLK_100 == 1 && start_full_run == 0) begin
start0 <= 0;
complete_full_run <= 0;
end
end

//Always block to dump bram contents
always@(posedge CLK_200) begin
if(CLK_200 == 1 && start_mem_dump == 1 && mem_dump_complete != 1)begin 

    if(count == -1) begin
        fptr = $fopen("BRAM_dump.txt","w");
        $fdisplay(fptr,"double bram_dump[%d][%d];",4,2**ADDR_WIDTH_DATA_BRAM);
        mux_dataBRAM_A_en0 = 1'b1; mux_dataBRAM_B_en0 = 1'b1; mux_dataBRAM_C_en0 = 1'b1; mux_dataBRAM_D_en0 = 1'b1;
        mux_dataBRAM_A_we0 = 1'b0; mux_dataBRAM_B_we0 = 1'b0; mux_dataBRAM_C_we0 = 1'b0; mux_dataBRAM_D_we0 = 1'b0;
        count = count + 1;
        mux_dataBRAM_A_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_B_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_C_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_D_0 = count[ADDR_WIDTH_DATA_BRAM-1:0];
    end
    else if(count == 0) begin
        count = count + 1;
        mux_dataBRAM_A_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_B_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_C_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_D_0 = count[ADDR_WIDTH_DATA_BRAM-1:0];//Addres
    end
    else if(count <= DATA_BRAM_SIZE && count >= 1)begin
        $fdisplay(fptr,"bram_dump[0][%d] = %e;",count-1,double_conv(bram_ZYNQ_block_A_dout)); //count-1 because BRAM has single cycle latency
        $fdisplay(fptr,"bram_dump[1][%d] = %e;",count-1,double_conv(bram_ZYNQ_block_B_dout));
        $fdisplay(fptr,"bram_dump[2][%d] = %e;",count-1,double_conv(bram_ZYNQ_block_C_dout));
        $fdisplay(fptr,"bram_dump[3][%d] = %e;",count-1,double_conv(bram_ZYNQ_block_D_dout));
        count = count + 1;
        mux_dataBRAM_A_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_B_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_C_0 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_D_0 = count[ADDR_WIDTH_DATA_BRAM-1:0];//Address
    end
    else if (count == DATA_BRAM_SIZE+1) begin
        $fclose(fptr);
        count = -1;
        mem_dump_complete = 1;    
        mux_dataBRAM_A_en0 = 1'b0; mux_dataBRAM_B_en0 = 1'b0; mux_dataBRAM_C_en0 = 1'b0; mux_dataBRAM_D_en0 = 1'b0;   
    end
end
else if(CLK_200 == 1 && start_mem_dump == 0)
    mem_dump_complete = 0;
end


//Always block to erase data BRAM contents
always@(posedge CLK_200) begin
if(CLK_200 == 1 && start_dataBRAM_erase == 1 && dataBRAM_erase_complete != 1)begin 

    if(count <= DATA_BRAM_SIZE-2 && count >= -1)begin
        if(count == -1) begin
            mux_dataBRAM_A_en1 = 1'b1; mux_dataBRAM_B_en1 = 1'b1; mux_dataBRAM_C_en1 = 1'b1; mux_dataBRAM_D_en1 = 1'b1;
            mux_dataBRAM_A_we1 = 1'b1; mux_dataBRAM_B_we1 = 1'b1; mux_dataBRAM_C_we1 = 1'b1; mux_dataBRAM_D_we1 = 1'b1;
            mux_dataBRAM_A_din0 = 0; mux_dataBRAM_B_din0 = 0; mux_dataBRAM_C_din0 = 0; mux_dataBRAM_D_din0 = 0; //Reset value
        end
        count = count + 1;
        mux_dataBRAM_A_1 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_B_1 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_C_1 = count[ADDR_WIDTH_DATA_BRAM-1:0]; mux_dataBRAM_D_1 = count[ADDR_WIDTH_DATA_BRAM-1:0]; //Address
    end
    else if (count == DATA_BRAM_SIZE-1) begin
        count = -1;
        dataBRAM_erase_complete = 1;   
        mux_dataBRAM_A_en1 = 1'b0; mux_dataBRAM_B_en1 = 1'b0; mux_dataBRAM_C_en1 = 1'b0; mux_dataBRAM_D_en1 = 1'b0;
        mux_dataBRAM_A_we1 = 1'b0; mux_dataBRAM_B_we1 = 1'b0; mux_dataBRAM_C_we1 = 1'b0; mux_dataBRAM_D_we1 = 1'b0;    
    end
end
else if(CLK_200 == 1 && start_dataBRAM_erase == 0)
    dataBRAM_erase_complete = 0;
end

//Always block to load the A matrix in data bram
always@(posedge CLK_200) begin
if(CLK_200 == 1 && start_A_load == 1 && A_load_complete != 1)begin 

    if(count <= A_size-2 && count >= -1)begin
        if(count == -1) //Initialization of en signals
            mux_dataBRAM_A_en2 = 1'b1; mux_dataBRAM_B_en2 = 1'b1; mux_dataBRAM_C_en2 = 1'b1; mux_dataBRAM_D_en2 = 1'b1;
            
        mux_dataBRAM_A_we2 = 1'b0; mux_dataBRAM_B_we2 = 1'b0; mux_dataBRAM_C_we2 = 1'b0; mux_dataBRAM_D_we2 = 1'b0;//Initially assigning all the write enables to 0
        count = count + 1;
        if(A_BRAMInd[count] == 0) begin//making one of the write enables 1
            mux_dataBRAM_A_we2 = 1'b1; mux_dataBRAM_A_2 = A_BRAMAddr[count]; mux_dataBRAM_A_din1 = A[count];
        end
        else if(A_BRAMInd[count] == 1) begin
            mux_dataBRAM_B_we2 = 1'b1; mux_dataBRAM_B_2 = A_BRAMAddr[count]; mux_dataBRAM_B_din1 = A[count];
        end
        else if(A_BRAMInd[count] == 2) begin
            mux_dataBRAM_C_we2 = 1'b1; mux_dataBRAM_C_2 = A_BRAMAddr[count]; mux_dataBRAM_C_din1 = A[count];
        end
        else if(A_BRAMInd[count] == 3) begin
            mux_dataBRAM_D_we2 = 1'b1; mux_dataBRAM_D_2 = A_BRAMAddr[count]; mux_dataBRAM_D_din1 = A[count];
        end
    end
    else if (count == A_size-1) begin
        count = -1;
        A_load_complete = 1;   
        mux_dataBRAM_A_en2 = 1'b0; mux_dataBRAM_B_en2 = 1'b0; mux_dataBRAM_C_en2 = 1'b0; mux_dataBRAM_D_en2 = 1'b0;
        mux_dataBRAM_A_we2 = 1'b0; mux_dataBRAM_B_we2 = 1'b0; mux_dataBRAM_C_we2 = 1'b0; mux_dataBRAM_D_we2 = 1'b0;    
    end
end
else if(CLK_200 == 1 && start_A_load == 0)
    A_load_complete = 0;
end

//Always block to erase inst BRAM
always@(posedge CLK_100) begin
if(CLK_100 == 1 && start_instBRAM_erase == 1 && instBRAM_erase_complete != 1)begin 

    if(count <= INST_BRAM_SIZE-2 && count >= -1)begin
        if(count == -1) begin
            instBRAM_en = 1'b1;
            instBRAM_we = 1'b1;
            instBRAM_part0_din = 0; instBRAM_part1_din = 0; instBRAM_part2_din = 0; instBRAM_part3_din = 0; instBRAM_part4_din = 0; instBRAM_part5_din = 0;
        end
        count = count + 1;
        instBRAM_addr = count[ADDR_WIDTH-1:0];
    end
    else if (count == INST_BRAM_SIZE-1) begin
        count = -1;
        instBRAM_erase_complete = 1;   
        instBRAM_en = 1'b0;
        instBRAM_we = 1'b0;
    end
end
else if(CLK_100 == 1 && start_instBRAM_erase == 0)
    instBRAM_erase_complete = 0;
end

//Always block to load instruction to instruction BRAM
always@(posedge CLK_100) begin
if(CLK_100 == 1 && start_inst_load == 1 && inst_load_complete != 1)begin 

    if(count <= total_instructions-2 && count >= -1)begin
        if(count == -1) begin
            instBRAM_en = 1'b1;
            instBRAM_we = 1'b1;
        end
        count = count + 1;
        instBRAM_part0_din = Inst[count][0]; instBRAM_part1_din = Inst[count][1]; instBRAM_part2_din = Inst[count][2]; instBRAM_part3_din = Inst[count][3]; 
        instBRAM_part4_din = Inst[count][4]; instBRAM_part5_din = Inst[count][5];
        instBRAM_addr = count[ADDR_WIDTH-1:0];
    end
    else if (count == total_instructions-1) begin
        count = -1;
        inst_load_complete = 1;   
        instBRAM_en = 1'b0;
        instBRAM_we = 1'b0;
    end
end
else if(CLK_100 == 1 && start_inst_load == 0)
    inst_load_complete = 0;
end

function real double_conv(input [63:0]b_num);
reg sign;
reg [10:0]weighted_expt;
integer actual_expt;
reg [1:52] mantissa;
reg [10:0] i;
static real real_one = 1.0;
static longint long_one = 1;
real temp_result,temp_decimal;

begin
sign = b_num >> 63;
weighted_expt = (b_num & 64'h7ff0000000000000)>> 52;
mantissa = b_num & 64'h000fffffffffffff;
if(weighted_expt == 0)begin
	temp_result = 1.0;
	for(i=0;i<1022;i=i+1)
		temp_result = temp_result/2;

	temp_decimal = 0;
	for(i=1;i<=52;i=i+1)
		temp_decimal = temp_decimal + mantissa[i]*(real_one/(long_one<<i));
		
	temp_result = temp_result*temp_decimal;
	if(sign==1)
		double_conv = -temp_result;
	else
		double_conv = temp_result;
	end
else if(weighted_expt>0 && weighted_expt <2047) begin
	actual_expt = weighted_expt-1023;
	if(actual_expt<0)begin
		temp_result = 1.0;
		actual_expt = -actual_expt;
		for(i=0;i<actual_expt;i=i+1)
			temp_result = temp_result/2;
		end
	else begin
		temp_result = 1.0;
		for(i=0;i<actual_expt;i=i+1)
			temp_result = temp_result*2;
	end

	temp_decimal = 0;
	for(i=1;i<=52;i=i+1)
		temp_decimal = temp_decimal + mantissa[i]*(real_one/(long_one<<i));

	temp_decimal = temp_decimal + 1;
	temp_result = temp_result*temp_decimal;
	if(sign == 1)
		double_conv = -temp_result;
	else
		double_conv = temp_result;
end
else if(weighted_expt == 2047)begin
/*if(mantissa == 0 and sign == 0)
double_conv = "inf";
else if(mantissa == 0 and sign == 1)
double_conv = "-inf";
else
double_conv = "nan";*/
end

end
endfunction

endmodule

module mux_4x1 #(parameter integer data_width = 11)(dout,din0,din1,din2,din3,sel);
output reg [data_width-1:0]dout;
input [data_width-1:0]din0;
input [data_width-1:0]din1;
input [data_width-1:0]din2;
input [data_width-1:0]din3;
input [1:0]sel;

always@(din0,din1,din2,din3,sel) begin
case(sel)
2'b00: dout <= din0;
2'b01: dout <= din1;
2'b10: dout <= din2;
2'b11: dout <= din3;
endcase
end
endmodule

module mux_2x1 #(parameter integer data_width = 32)(dout,din0,din1,sel);
output reg [data_width-1:0]dout;
input [data_width-1:0]din0;
input [data_width-1:0]din1;
input sel;

always@(din0,din1,sel) begin
case(sel)
1'b0: dout <= din0;
1'b1: dout <= din1;
endcase
end
endmodule













