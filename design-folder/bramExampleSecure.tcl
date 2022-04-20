create_project bramExample_secure /home/kawser/MeXT-SE/design-folder/bramExample_secure -part xc7vx485tffg1157-1
set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]
update_ip_catalog

create_bd_design "design_1"
update_compile_order -fileset sources_1

set_property  ip_repo_paths /home/kawser/MeXT-SE/ip-repo/IPFW_xilinx   [current_project]
update_ip_catalog

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
validate_bd_design -force
save_bd_design
