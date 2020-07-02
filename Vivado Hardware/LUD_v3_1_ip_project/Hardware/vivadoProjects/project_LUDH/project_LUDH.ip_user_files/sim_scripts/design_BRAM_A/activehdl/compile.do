vlib work
vlib activehdl

vlib activehdl/xil_defaultlib
vlib activehdl/xpm
vlib activehdl/blk_mem_gen_v8_4_2

vmap xil_defaultlib activehdl/xil_defaultlib
vmap xpm activehdl/xpm
vmap blk_mem_gen_v8_4_2 activehdl/blk_mem_gen_v8_4_2

vlog -work xil_defaultlib  -sv2k12 \
"/opt/XilinxWebPACK/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93 \
"/opt/XilinxWebPACK/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \

vlog -work blk_mem_gen_v8_4_2  -v2k5 \
"../../../../project_LUDH.srcs/sources_1/bd/design_BRAM_A/ipshared/37c2/simulation/blk_mem_gen_v8_4.v" \

vlog -work xil_defaultlib  -v2k5 \
"../../../bd/design_BRAM_A/ip/design_BRAM_A_blk_mem_gen_0_1/sim/design_BRAM_A_blk_mem_gen_0_1.v" \

vcom -work xil_defaultlib -93 \
"../../../bd/design_BRAM_A/sim/design_BRAM_A.vhd" \


vlog -work xil_defaultlib \
"glbl.v"

