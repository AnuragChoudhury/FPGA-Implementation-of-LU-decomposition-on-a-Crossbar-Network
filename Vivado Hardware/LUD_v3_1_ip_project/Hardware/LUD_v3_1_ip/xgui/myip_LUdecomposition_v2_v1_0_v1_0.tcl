# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "ADDR_WIDTH_DATA_BRAM" -parent ${Page_0}
  ipgui::add_param $IPINST -name "AU_SEL_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BRAM_SEL_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "CTRL_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "C_S00_AXI_DATA_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.ADDR_WIDTH_DATA_BRAM { PARAM_VALUE.ADDR_WIDTH_DATA_BRAM } {
	# Procedure called to update ADDR_WIDTH_DATA_BRAM when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH_DATA_BRAM { PARAM_VALUE.ADDR_WIDTH_DATA_BRAM } {
	# Procedure called to validate ADDR_WIDTH_DATA_BRAM
	return true
}

proc update_PARAM_VALUE.AU_SEL_WIDTH { PARAM_VALUE.AU_SEL_WIDTH } {
	# Procedure called to update AU_SEL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.AU_SEL_WIDTH { PARAM_VALUE.AU_SEL_WIDTH } {
	# Procedure called to validate AU_SEL_WIDTH
	return true
}

proc update_PARAM_VALUE.BRAM_SEL_WIDTH { PARAM_VALUE.BRAM_SEL_WIDTH } {
	# Procedure called to update BRAM_SEL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BRAM_SEL_WIDTH { PARAM_VALUE.BRAM_SEL_WIDTH } {
	# Procedure called to validate BRAM_SEL_WIDTH
	return true
}

proc update_PARAM_VALUE.CTRL_WIDTH { PARAM_VALUE.CTRL_WIDTH } {
	# Procedure called to update CTRL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.CTRL_WIDTH { PARAM_VALUE.CTRL_WIDTH } {
	# Procedure called to validate CTRL_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to update C_S00_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_ADDR_WIDTH { PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_S00_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to update C_S00_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_S00_AXI_DATA_WIDTH { PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to validate C_S00_AXI_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH_DATA_BRAM { MODELPARAM_VALUE.ADDR_WIDTH_DATA_BRAM PARAM_VALUE.ADDR_WIDTH_DATA_BRAM } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH_DATA_BRAM}] ${MODELPARAM_VALUE.ADDR_WIDTH_DATA_BRAM}
}

proc update_MODELPARAM_VALUE.CTRL_WIDTH { MODELPARAM_VALUE.CTRL_WIDTH PARAM_VALUE.CTRL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.CTRL_WIDTH}] ${MODELPARAM_VALUE.CTRL_WIDTH}
}

proc update_MODELPARAM_VALUE.AU_SEL_WIDTH { MODELPARAM_VALUE.AU_SEL_WIDTH PARAM_VALUE.AU_SEL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.AU_SEL_WIDTH}] ${MODELPARAM_VALUE.AU_SEL_WIDTH}
}

proc update_MODELPARAM_VALUE.BRAM_SEL_WIDTH { MODELPARAM_VALUE.BRAM_SEL_WIDTH PARAM_VALUE.BRAM_SEL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BRAM_SEL_WIDTH}] ${MODELPARAM_VALUE.BRAM_SEL_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH PARAM_VALUE.C_S00_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH PARAM_VALUE.C_S00_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_S00_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_S00_AXI_ADDR_WIDTH}
}

