#!/bin/bash 

UsageExit(){
	echo -e "\
pulp_app [OPTION]   Is a bash script able to create pulp bitstream,
		    upload it into board compile application and run
		    it into board, actually zcu102 is the  default
		    board and hello is the default application.
OPTION
	-b|--bitstream
		create bitstream using PULPissimo_bitstream.sh

	-f|--flashing
		flash bitstream into board using
		make -C pulpissimo-zcu102 download

	-c|--compile
		create cross compiled test elf file of hello

	-u|--usb-for-screen
		selection of usb for minicom connection example:
		-u ttyUSB0
	-t|--terminal 
		run 3 terminal with openOCD, gdb and screen, 
		for screen is possible to select usb number using
		-u option
"
	exit 1;	
}

source ccommon.sh

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

DIR=`pwd`
#sudo chmod 2775 /usr/bin/screen
#sudo pkill -9 screen



### VARIABLES
BITSTREAM=0
FLASHING=0
COMPILE=0
TERMINALS=0
NOTHING=1
USB="ttyUSB0"
BUILD_SDK_OPENOCD=0

exitflag=0
LOG=$DIR"/pulp_app_log"
ENVIRON_FILE=$DIR/.environ.env
###

#######################################################################
####### COMMAND LINE ARGUMENT HANDLE ##################################

TEMP=`getopt -o sfc:u:t:hb --long bitstream,flashing,compile:,usb-for-screen:,terminals:,help,build-sdk-openocd -- "$@"`

eval set -- "$TEMP"

while true; do
	echo $1
	case $1 in
		-b|--build-sdk-openocd)
			BUILD_SDK_OPENOCD=1
			NOTHING=0
			shift
			;;
		-s|--bitstream)
			BITSTREAM=1	
			NOTHING=0
			shift
			;;
		-f|--flashing)
			FLASHING=1	
			NOTHING=0
			shift
			;;
	       	-c|--compile)
			COMPILE=1
			shift
			C_OPT=$1
			echo $1
			NOTHING=0
			shift
			;;
		-u|--usb-for-screen)
			shift
			USB=$1
			echo $1
			shift
			;;
		-t|--terminals)
			TERMINALS=1
			shift
			T_OPT=$1
			echo $1
			NOTHING=0
			shift
			;;
		-h|--help)
			UsageExit
			;;
		--)
			break;;
		*)
			UsageExit
			;;
	esac		
done

if [[ $NOTHING -eq 1 ]]; then
	echo $Red"Please give at least an argument!!"
	UsageExit
fi

#######################################################################
###### PROGRAM ######################################################

# Setting environment variable
if test -f "$ENVIRON_FILE"; then
	Print "n" "Set environment var"
	while read var; do
		export $var;
		echo "$var exported";
	done < $ENVIRON_FILE
else
	echo "Error environment not setted!!!"
	exitflag=1
fi

mkdir -p $LOG

if [[ $BITSTREAM -eq 1 ]]; then
	Print "b" " Bitstream generation:"
	mon_run "./PULPissimo_bitstream.sh" "$LOG/PULPissimo_bitstream_log.txt" 1 $LINENO
fi

if [[ $FLASHING -eq 1 ]]; then
	Action "Have you connected two usb cables for riscv flashing at port J83 and J2 of zcu102?"
	cd $DIR/pulpissimo/fpga
	Print "f" " Flashing fpga"
	mon_run "make -C pulpissimo-zcu102 download" "$LOG/flashing_log.txt" 1 $LINENO
fi

if [[ $BUILD_SDK_OPENOCD -eq 1 ]]; then
	cd $DIR/pulp-sdk
	source configs/pulpissimo.sh
	source configs/fpgas/pulpissimo/zcu102.sh
	source sourceme.sh
	export PULP_RISCV_GCC_TOOLCHAIN="/opt/riscv"
	#source sourceme.sh && ./pulp-tools/bin/plpbuild checkout build --p openocd --stdout
	export OPENOCD="$DIR/pulp-sdk/pkg/openocd/1.0/bin"
	#mon_run "make all" "$LOG/make_all.txt" 1 $LINENO
	env | grep -e "PULP\|OPENOCD" > $ENVIRON_FILE
fi

if [[ $COMPILE -eq 1 ]]; then
	cd $DIR/pulp-sdk
	source configs/pulpissimo.sh
	source configs/fpgas/pulpissimo/zcu102.sh
	source sourceme.sh
	export OPENOCD="$DIR/pulp-sdk/pkg/openocd/1.0/bin"
	export PULP_RISCV_GCC_TOOLCHAIN="/opt/riscv"
	Print "c" " Compiling"
	cd $DIR/pulp-rt-examples/$C_OPT
	echo $(pwd)
        mon_run "make clean all" "$LOG/make_log.txt" 1 $LINENO
fi

if [[ $TERMINALS -eq 1 ]] && [[ $exitflag -eq 0 ]]; then
 	cd $DIR
        gnome-terminal --geometry=70x15+0+0 -- bash -c "$OPENOCD/openocd -f $DIR/pulpissimo/fpga/pulpissimo-zcu102/olimex-arm-usb-tiny-h.cfg; exec bash"

	gnome-terminal --geometry=70x15+1000+0 -- bash -c "$PULP_RISCV_GCC_TOOLCHAIN/bin/riscv32-unknown-elf-gdb -x $DIR/pulpissimo/fpga/pulpissimo-zcu102/elf_run.gdb ./pulp-rt-examples/$T_OPT/build/pulpissimo/test/test; exec bash"

	if [[ $USB != "all" ]]; then
		sudo chmod 777 /dev/$USB
		sudo gnome-terminal --geometry=70x15+1000+355 -- bash -c "sudo screen /dev/$USB 115200; exec bash"
	else
		sudo chmod 777 /dev/ttyUSB0
		sudo chmod 777 /dev/ttyUSB1
		sudo chmod 777 /dev/ttyUSB2
		sudo chmod 777 /dev/ttyUSB3
		sudo chmod 777 /dev/ttyUSB4
		sudo chmod 777 /dev/ttyUSB5
		sudo gnome-terminal --geometry=70x15+0+355 -- bash -c "sudo screen /dev/ttyUSB0 115200; exec bash"
		sudo gnome-terminal --geometry=70x15+200+355 -- bash -c "sudo screen /dev/ttyUSB1 115200; exec bash"
		sudo gnome-terminal --geometry=70x15+300+355 -- bash -c "sudo screen /dev/ttyUSB2 115200; exec bash"
		sudo gnome-terminal --geometry=70x15+400+355 -- bash -c "sudo screen /dev/ttyUSB3 115200; exec bash"
		sudo gnome-terminal --geometry=70x15+500+355 -- bash -c "sudo screen /dev/ttyUSB4 115200; exec bash"
		sudo gnome-terminal --geometry=70x15+600+355 -- bash -c "sudo screen /dev/ttyUSB5 115200; exec bash"
	fi

fi




