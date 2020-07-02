-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
-- Date        : Thu Apr 23 23:24:20 2020
-- Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Users/anuragchoudhury/Desktop/local_documents/Vivado/LUD_v3_2_ip_project/Hardware/vivadoProjects/project_LUDH/project_LUDH.srcs/sources_1/bd/design_CTRL/ip/design_CTRL_blk_mem_gen_0_0/design_CTRL_blk_mem_gen_0_0_stub.vhdl
-- Design      : design_CTRL_blk_mem_gen_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xczu7ev-ffvc1156-2-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity design_CTRL_blk_mem_gen_0_0 is
  Port ( 
    clka : in STD_LOGIC;
    ena : in STD_LOGIC;
    wea : in STD_LOGIC_VECTOR ( 0 to 0 );
    addra : in STD_LOGIC_VECTOR ( 11 downto 0 );
    dina : in STD_LOGIC_VECTOR ( 356 downto 0 );
    douta : out STD_LOGIC_VECTOR ( 356 downto 0 )
  );

end design_CTRL_blk_mem_gen_0_0;

architecture stub of design_CTRL_blk_mem_gen_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clka,ena,wea[0:0],addra[11:0],dina[356:0],douta[356:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "blk_mem_gen_v8_4_2,Vivado 2018.3";
begin
end;
