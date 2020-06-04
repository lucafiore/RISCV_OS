#!/bin/bash

#This script must be run if you do the download of the bitstream 
# after having closed the terminal where you generated the bitstream

if (( $# != 1 )); then 
	echo "Error usage: enter the model of the board as first argument!"
fi
target_board=$1

cd pulpissimo/fpga

#cd ./pulpissimo/fpga
make -C pulpissimo-${target_board} download
cd ../../
