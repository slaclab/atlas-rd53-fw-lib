# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Check for submodule tagging
if { [info exists ::env(OVERRIDE_SUBMODULE_LOCKS)] != 1 || $::env(OVERRIDE_SUBMODULE_LOCKS) == 0 } {
   if { [SubmoduleCheck {ruckus} {2.0.1}  ] < 0 } {exit -1}
   if { [SubmoduleCheck {surf}   {2.0.0} ] < 0 } {exit -1}
} else {
   puts "\n\n*********************************************************"
   puts "OVERRIDE_SUBMODULE_LOCKS != 0"
   puts "Ignoring the submodule locks in axi-pcie-core/ruckus.tcl"
   puts "*********************************************************\n\n"
}   

# Get the family type
set family [getFpgaFamily]

if { ${family} eq {artix7}  ||
     ${family} eq {kintex7} ||
     ${family} eq {virtex7} ||
     ${family} eq {zynq} } {
   set fpgaType "7Series"
}

if { ${family} eq {kintexu} ||
     ${family} eq {kintexuplus} ||
     ${family} eq {virtexuplus} ||
     ${family} eq {virtexuplusHBM} ||
     ${family} eq {zynquplus} ||
     ${family} eq {zynquplusRFSOC} } {
   set fpgaType "UltraScale"
}

# Load the source code
loadSource -lib atlas_rd53_fw_lib -dir "$::DIR_PATH/rtl"
loadSource -lib atlas_rd53_fw_lib -dir "$::DIR_PATH/rtl/${fpgaType}"

# Adding the common Si5345 configuration
add_files -norecurse "$::DIR_PATH/mem/Si5345-RevD-Registers-160MHz.mem"

# Load ruckus files
loadRuckusTcl "$::DIR_PATH/sim"
