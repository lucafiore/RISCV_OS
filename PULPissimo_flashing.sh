#!/bin/bash

# This script will load the PULPissimo microcontroller on Xilinx ZCU102

#into pulpissimo folder:
cd ./pulpissimo

##### Generate the necessary synthesis include scripts #####
 
#It will parse the ips_list.yml using the PULP IPApproX IP management tool to generate tcl scripts for all the IPs used in the PULPissimo project. These files are later on sourced by Vivado to generate the bitstream for PULPissimo.

./update-ips 


##### Generate the bitstream #####

cd fpga
make zcu102

##ATTENTION: the bitstream generation could not work well due to this kind of problem --> "error  Vivado/2019.2/bin/loader: line 280: 27584 Killed  "$RDI_PROG" "$@"
# This is a memory related problem that can be resolved by increasing the stack in VIVADO or, if it does not work, increasing the swap in your machine.
# This was tested on a machine with 12GB RAM and initially 1GB swap (8GB at the end). 
# PROCEDURE 1:
# 	-add another option to the VIVADO command --> "-stack 2000" (i.e. run: vivado -stack 2000)
#	-you may also increase the value 2000
# PROCEDURE 2:
#	-increase the swap in your machine following these commands to run:
#	-(with this procedure you increase the swap to 8GB)
#		sudo swapoff -a
#		sudo dd if=/dev/zero of=/swapfile bs=1G count=8
#		sudo mkswap /swapfile
#		sudo swapon /swapfile
#		grep SwapTotal /proc/meminfo #to check if now the size f the swap is 8GB
#
# SOLUTION: the problem was solved by both increasing the swap and adding the stack option to vivado command (-stack 10000).


#This process might take a while. If everything goes well your fpga directory should now contain two files:

#- `pulpissimo_<board_target>.bit` the bitstream file for JTAG configuration of the FPGA.
#- `pulpissimo_<board_target>.bin` the binary configuration file to flash to a non-volatile configuration memory.


##### download the bitstream into the FPGA #####

# Step one: Connect the ZCU102 evaluation board to your host machine with a Micro-USB cable from the J2 connector (USB JTAG) on the ZCU102 board to a USB port on your host machine. 
#Step two: Set the board boot mode to JTAG boot (all four DIP switch of the switch SW6 set to on position) More details on how to setup the zcu102 board are provided in the ZCU102 Evaluation Board User Guide.
# to set correctly the board, see https://www.xilinx.com/support/answers/68386.html

METHOD=1;

if [[ $METHOD -eq 1 ]]; then
	#METHOD1
	#To download this bitstream into the FPGA connect the PROG USB header, turn the board on and run:

	make -C pulpissimo-zcu102 download
	
elif [[ $METHOD -eq 2 ]] 	
	#METHOD 2
	#Program the ZCU102 with Hardware Manager. Invoke vivado Open Hardware Manager Open Target Program device Detailed instructions on how to use hardware manager are provided in Vivado Design Suite User Guide – programming and Debugging

fi

#ATTENTION: if the board is not detected, please run "sudo ./install_drivers" in the directory "{Xilinx_installation_dir}/Vivado/2019.2/data/xicom/cable_drivers/lin64/install_script" and reboot your machine

cd ../../ #come back to main folder

# Now the FPGA is ready to emulate PULPissimo
