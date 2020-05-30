#!/bin/bash

# This script will compile the Application for Xilinx ZCU102

cd ./pulp-sdk

##########################################
## SELECT TARGET PLATFORM AND BUILD SDK ##

#To run or debug applications for the FPGA you need to use a recent version of the PULP-SDK (commit id 3256fe7 or newer.'). Configure the SDK for the FPGA platform by running the following commands within the SDK's root directory:

cp ../zcu102.sh ~/pulpissimo/pulp-sdk/configs/fpgas/pulpissimo/ #copy the config file for zcu102 FPGA into the right folder in order use it when you want to use PULPissimo with this FPGA and not with the rtl simulator fo example.

source configs/pulpissimo.sh 			#select the target micro-Controller
source configs/fpgas/pulpissimo/zcu102.sh 	#select the target platform (RTL simulator, FPGA or virtual platform)
make all 					# build SDK

##########################################
## BUILD THE APPLICATION ##

## build the application - THE FIRST THREE COMMANDS ARE NEEDED BY THE UNOFFICIAL README BUT NOT INTO THE OFFICIAL README
#make env
#source sourceme.sh
#cd hello
make clean all

#This command builds the ELF binary with UART as the default io peripheral. The binary will be stored at 'build/pulpissimo/[app_name]/[app_name]'.

cd ../ #come back to main folder	

##########################################
## RUN THE APPLICATION ON zcu102 ##

#In order to execute our application on the FPGA we need to load the binary into PULPissimo's L2 memory. To do so we can use OpenOCD in conjunction with GDB to communicate with the internal RISC-V debug module.
#PULPissimo uses JTAG as a communication channel between OpenOCD and the Core. 

#Step one: Connect the UART of the ZCU102 (J83) to a USB port on your host. 
#Step two: Connect Digilent JTAG-HS2 adapter from (J55) of the ZCU102 to a USB port on your host. Please note the HS2 connector should be connected to the J55 pins with odd numbers (the top row of the J55). 
#Step three: Program the board with the pulpissimo-zcu102.bit following the instructions provided in the previous section Step four: Open three terminals on your host.

##########################################
## OpenOCD ##

#required dependencies
sudo apt-get install autoconf automake texinfo make libtool pkg-config libusb-1.0 libftdi libusb-0.1

#download, apply the patch and compile OpenOCD
source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build --p openocd --stdout
#The SDK will automatically set the environment variable OPENOCD to the installation path of this patched version.


##########################################

#ON SHELL1 - Launch openocd with a configuration file for the target board
#SHELL: $OPENOCD/bin/openocd -f ./pulpissimo/fpga/pulpissimo-zcu102/openocd-zcu102-digilent-jtag-hs2.cfg

#ON SHELL2 - launch gdb passing the ELF file as argument
#SHELL: PULP_RISCV_GCC_TOOLCHAIN_CI/bin/riscv32-unknown-elf-gdb ./pulpissimo/pulp-sdk/build/pulpissimo/[app_name]/[app_name]
#in my case is /opt/riscv/bin/riscv32-unknown-elf-gdb

#ON SHELL3 - Open a serial port client to redirect UART output from PULPissimo to stdout
#SHELL: screen /dev/ttyUSB0 115200
#Please note you might need to configure the serial port to a different device (for example /dev/ttyUSB1) depending on which USB port on the host side is connected to the UART of the board.

##########################################

