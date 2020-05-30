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

#This process might take a while. If everything goes well your fpga directory should now contain two files:

#- `pulpissimo_<board_target>.bit` the bitstream file for JTAG configuration of the FPGA.
#- `pulpissimo_<board_target>.bin` the binary configuration file to flash to a non-volatile configuration memory.


##### download the bitstream into the FPGA #####
METHOD=1;

if [[ $METHOD -eq 1 ]]; then
	#METHOD1
	#To download this bitstream into the FPGA connect the PROG USB header, turn the board on and run:

	make -C pulpissimo-zedboard download
elif [[ $METHOD -eq 2 ]] 	
	#METHOD 2
	# Step one: Connect the ZCU102 evaluation board to your host machine with a Micro-USB cable from the J2 connector (USB JTAG) on the ZCU102 board to a USB port on your host machine. 
	#Step two: Set the board boot mode to JTAG boot (all four DIP switch of the switch SW6 set to on position) More details on how to setup the zcu102 board are provided in the ZCU102 Evaluation Board User Guise. 
	#Step three: Program the ZCU102 with Hardware Manager. Invoke vivado Open Hardware Manager Open Target Program device Detailed instructions on how to use hardware manager are provided in Vivado Design Suite User Guide – programming and Debugging

fi

cd ../../ #come back to main folder

# Now the FPGA is ready to emulate PULPissimo
