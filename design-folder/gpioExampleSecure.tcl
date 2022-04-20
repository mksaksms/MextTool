create_project gpioExample_secure /home/kawser/MeXT-SE/design-folder/gpioExample_secure -part xc7vx485tffg1157-1  -force
 set_property board_part digilentinc.com:zybo-z7-20:part0:1.0 [current_project]
update_ip_catalog

create_bd_design "design_1"
update_compile_order -fileset sources_1

set_property  ip_repo_paths /home/kawser/MeXT-SE/ip-repo/IPFW_Xilinx   [current_project]
update_ip_catalog

startgroup
create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]
startgroup
create_bd_cell -type ip -vlnv Digilent:user:IPFW:3.0 IPFW_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/IPFW_0/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins IPFW_0/S00_AXI]

startgroup
make_bd_pins_external  [get_bd_pins IPFW_0/secure_data_out]
endgroup

validate_bd_design -force
save_bd_design
set_property  ip_repo_paths /home/kawser/MeXT-SE/ip-repo/   [current_project]
update_ip_catalog

startgroup
create_bd_cell -type ip -vlnv Digilent:user:Sandbox:1.0 Sandbox_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/Sandbox_0/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins Sandbox_0/S00_AXI]



set_property  ip_repo_paths /home/kawser/MeXT-SE/ip-repo/   [current_project]
update_ip_catalog
startgroup
create_bd_cell -type ip -vlnv Digilent:user:Policy_Server:3.0 Policy_Server_0
endgroup

apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/Policy_Server_0/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins Policy_Server_0/S00_AXI]

validate_bd_design -force
save_bd_design
