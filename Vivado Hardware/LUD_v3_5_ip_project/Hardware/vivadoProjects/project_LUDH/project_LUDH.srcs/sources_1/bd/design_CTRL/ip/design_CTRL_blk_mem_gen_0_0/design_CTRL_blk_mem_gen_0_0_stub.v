// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
// Date        : Thu Apr 23 16:14:32 2020
// Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top design_CTRL_blk_mem_gen_0_0 -prefix
//               design_CTRL_blk_mem_gen_0_0_ design_CTRL_blk_mem_gen_0_0_stub.v
// Design      : design_CTRL_blk_mem_gen_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xczu7ev-ffvc1156-2-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module design_CTRL_blk_mem_gen_0_0(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[11:0],dina[372:0],douta[372:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [11:0]addra;
  input [372:0]dina;
  output [372:0]douta;
endmodule
