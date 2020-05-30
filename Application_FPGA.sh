#!/bin/bash

# This script will compile the Application for Xilinx ZCU102

#into pulp-sdk folder:
cd ./pulp-sdk

## Select target platform and build SDK

#To run or debug applications for the FPGA you need to use a recent version of the PULP-SDK (commit id 3256fe7 or newer.'). Configure the SDK for the FPGA platform by running the following commands within the SDK's root directory:

cp ../zcu102.sh ~/pulpissimo/pulp-sdk/configs/fpgas/pulpissimo/ #copy the config file for zcu102 FPGA into the right folder in order use it when you want to use PULPissimo with this FPGA and not with the rtl simulator fo example.

source configs/pulpissimo.sh #select the target micro-Controller
source configs/fpgas/pulpissimo/zcu102.sh #select the target platform (RTL simulator, FPGA or virtual platform)
make all # build SDK

## build the application
make env
source sourceme.sh
cd hello
make clean all

#This command builds the ELF binary with UART as the default io peripheral. The binary will be stored at `build/pulpissimo/[app_name]/[app_name]`.

cd ../../ #come back to main folder

