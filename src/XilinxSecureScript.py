#MeXT-SE software source code
#author: Md Jubaer Hossain Pantho
#modified : Muhammed Kawser Ahmed - Replaced HIMM by IPFIREWALL and added sandbox
#University of Florida

def ScriptGeneration(systemData, cpuConfList, memConfList, comConfData, filePath):
    print("Generating secure script for Xilinx FPGA")
    print(systemData)

    tclFile = open(filePath[:-4] + "Secure.tcl", "w")
    projectDir = filePath.split('/')
    projectName = projectDir[-1]
    projectName = projectName[:-4] + "_secure"
    print(projectName)

    x = len(projectDir)
    projectDir = projectDir[1:x-2]

    create_project = "create_project " + projectName + " " + filePath[:-4] + "_secure" + " -part xc7vx485tffg1157-1" + "  -force\n "
    tclFile.write(create_project)


    if (systemData[1][0] == "zynq-7010"):
        tclFile.write("set_property board_part digilentinc.com:zybo-z7-10:part0:1.0 [current_project]\n")
        tclFile.write("update_ip_catalog\n\n")
    elif(systemData[1][0] == "zynq-7020"):
        tclFile.write("set_property board_part digilentinc.com:zybo-z7-20:part0:1.0 [current_project]\n")
        tclFile.write("update_ip_catalog\n\n")
    else:
        print("INFO: Unknown board file")
        exit(-1)


    tclFile.write("create_bd_design \"design_1\"\n")
    tclFile.write("update_compile_order -fileset sources_1\n\n")

    #adding static IP repo. This will be changed to a dynamically added repo in future
    ip_repo_path = ""
    for item in projectDir:
        ip_repo_path += "/"+item
    ip_repo_path += "/ip-repo/IPFW_Xilinx"
    tclFile.write("set_property  ip_repo_paths "+ip_repo_path+"   [current_project]\n")
#    tclFile.write("set_property  ip_repo_paths  /home/mdjubaer/vivado-projects/mext-project/ip_repo [current_project]\n")
    tclFile.write("update_ip_catalog\n\n")

    count = 0

    gpio_index = -1
    for item in systemData:
        count = count + 1
        if (count > 2):
            if ("CPU" in item[0]):
                if("standalone" in item and "zynq" in item):
                    tclFile.write("startgroup\n")
                    tclFile.write("create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0\n")
                    tclFile.write("endgroup\n\n")


                if (cpuConfList[0] =="DDR"):
                    tclFile.write('apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable" }  [get_bd_cells processing_system7_0]\n')

            elif ("ipcore" in item[0]):
                gpio_index = gpio_index + 1
                if ("GPIO" in item):
                    tclFile.write("startgroup\n")


                    tclFile.write("create_bd_cell -type ip -vlnv Digilent:user:IPFW:3.0 IPFW_"+ str(gpio_index) +"\n")
                    tclFile.write("endgroup\n\n")

                    if ("output" in item):
                        widthSize = item[3]
                        widthSize = widthSize[:-4]
                        tclFile.write("set_property -dict [list CONFIG.SECURE_DATA_OUT_WIDTH {" + widthSize + "}] [get_bd_cells IPFW_" + str(gpio_index) + "]\n\n")
                    tclFile.write("apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/IPFW_" + str(gpio_index) + "/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins IPFW_" + str(gpio_index) + "/S00_AXI]\n\n")







                    tclFile.write("startgroup\n")
                    tclFile.write("make_bd_pins_external  [get_bd_pins IPFW_" + str(gpio_index) + "/secure_data_out]\n")
                    tclFile.write("endgroup\n\n")


                    ###Update the IPs first
                    tclFile.write("validate_bd_design -force\n")
                    tclFile.write("save_bd_design\n")


                    #########################################################################3
                    #Editing of sandbox starts here
                    ## This option is for sand box ;
                    ##########################################################################

                    ## Add the sandbox IP to the repo path and update ip catalog

               #     ip_repo_path.removesuffix("IPFW_xilinx")
                    print(ip_repo_path)


                    suffix =  "IPFW_Xilinx"
                  #  ip_repo_path_new = "Kawser"
                    ip_repo_path_new = ip_repo_path.rstrip(suffix)
                #    ip_repo_path_new += "Sandbox_Xilinx"

                    print(ip_repo_path_new)
                    tclFile.write("set_property  ip_repo_paths " + ip_repo_path_new + "   [current_project]\n")
                    tclFile.write("update_ip_catalog\n\n")


                    tclFile.write("startgroup\n")
                    tclFile.write(
                        "create_bd_cell -type ip -vlnv Digilent:user:Sandbox:1.0 Sandbox_" + str(gpio_index) + "\n")
                    tclFile.write("endgroup\n\n")

                    tclFile.write(
                    "apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/Sandbox_" + str(
                        gpio_index) + "/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins Sandbox_" + str(
                        gpio_index) + "/S00_AXI]\n\n")

    ## Second module for sandbox
    ## Added by Kawser

                ## Policy Server added

                    tclFile.write("startgroup\n")

                    tclFile.write(  "create_bd_cell -type ip -vlnv Digilent:user:Policy_Server:3.0 Policy_Server_" + str(gpio_index) + "\n")
                    tclFile.write("endgroup\n\n")

                    tclFile.write(             "apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/Policy_Server_" + str(             gpio_index) + "/S00_AXI} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins Policy_Server_" + str(gpio_index) + "/S00_AXI]\n\n")

                    tclFile.write("validate_bd_design -force\n")
                    tclFile.write("save_bd_design\n")
                    tclFile.close()



                    ## Connect the pins
                    #tclFile.write("update_compile_order -fileset sources_1\n")
                   # tclFile.write("connect_bd_net [get_bd_pins Sandbox_0/UpdateWR] [get_bd_pins Policy_Server_0/UpdateWR_SB]\n")


    print("Secure Script Generation Done")
