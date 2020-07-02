-makelib xcelium_lib/xil_defaultlib -sv \
  "/opt/XilinxWebPACK/Vivado/2018.3/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/opt/XilinxWebPACK/Vivado/2018.3/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_2 \
  "../../../../project_LUDH.srcs/sources_1/bd/design_BRAM_A/ipshared/37c2/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/design_BRAM_A/ip/design_BRAM_A_blk_mem_gen_0_1/sim/design_BRAM_A_blk_mem_gen_0_1.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../bd/design_BRAM_A/sim/design_BRAM_A.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib

