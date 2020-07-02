#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

if [ -z "$PATH" ]; then
  PATH=/opt/XilinxWebPACK/SDK/2018.3/bin:/opt/XilinxWebPACK/Vivado/2018.3/ids_lite/ISE/bin/lin64:/opt/XilinxWebPACK/Vivado/2018.3/bin
else
  PATH=/opt/XilinxWebPACK/SDK/2018.3/bin:/opt/XilinxWebPACK/Vivado/2018.3/ids_lite/ISE/bin/lin64:/opt/XilinxWebPACK/Vivado/2018.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=/opt/XilinxWebPACK/Vivado/2018.3/ids_lite/ISE/lib/lin64
else
  LD_LIBRARY_PATH=/opt/XilinxWebPACK/Vivado/2018.3/ids_lite/ISE/lib/lin64:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='/home/anuragchoudhury/mod_v_fix_v2_md_2018_ip/Hardware/vivadoProjects/project_LUDH/project_LUDH.runs/design_DIV_floating_point_0_0_synth_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

EAStep vivado -log design_DIV_floating_point_0_0.vds -m64 -product Vivado -mode batch -messageDb vivado.pb -notrace -source design_DIV_floating_point_0_0.tcl
