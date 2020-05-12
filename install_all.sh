# This file install pulpissimo and all dependecies:
# 
# pulpissimo dipendencies:
#		installation of pulp-builder:
#			https://github.com/pulp-platform/pulp-builder/blob/master/README.md
# 			pulp-builder dependencies:
#  				installation of pulp-riscv-gnu-toolchain 
#					https://github.com/pulp-platform/pulp-riscv-gnu-toolchain
# rtl requirements:
# 		Ubuntu 16.04 and CentOS 7.
#		Mentor ModelSim tested with 10.6b
#		python3.4  (and pyyaml)
#		installation of SDK (software development kit):
#			https://github.com/pulp-platform/pulp-sdk/blob/master/README.md
#		
source ccommon.sh

gitclone() {
	# $1 comando
	# $2 clone dir
	# $3 log file
	cmd=$1
	clone_name=$2
	log_file=$3

	if ! test -d $CLONE/$clone_name; then
		Print_verbose "[*] 		Download of $clone_name" $verbose	
		cd $CLONE
		#mon_run "$cmd" "$LOG_DIR/log/$log_file.txt" 1 $LINENO
		$cmd
		cd ..
	fi
	if test -d $clone_name; then
		rm -r $clone_name
	fi
	cp -r $CLONE/$clone_name .
}

UsageExit() {
	   echo \
"installall.sh help:\n \
	Options:
	   	-v|--verbose   
			verbose option, script print many others information

		-c|--cross_compiler [pulp|linux|linux32|linuxm]
			This option define what cross compiler the script install:
				pulp ->  newlib cross-compiler for all pulp variants
					 This will use the multilib support to build the libraries for 
					 the various cores (riscy, zeroriscy and so on). The right libraries 
					 will be selected depending on which compiler options you use.
				newlib -> Newlib cross-compiler, You should now be able
					 to use riscv-gcc and its cousins.
				linux -> Linux cross compiler 64 bit
					 Supported architectures are rv64i plus standard extensions (a)tomics, 
					 (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
					 Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
					 (32-bit with single-precision in registers and double in memory, niche use only), 
					 lp64 lp64f lp64d (same but with 64-bit long and pointers).
				linux32 -> Linux cross compiler 32 bit
					 Supported architectures are rv32i plus standard extensions (a)tomics, 
					 (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
					 Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
					 (32-bit with single-precision in registers and double in memory, niche use only), 
					 lp64 lp64f lp64d (same but with 64-bit long and pointers).
				linuxm ->  Linux cross-compiler, both 32 and 64 supported
		-t|--test_suite [y|n]
			Decide if install test suite or not, this test suite 

"
	   exit 1;
}



########### Variable
SYSTEM="ubuntu"
DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
INSTALL_DIR="/opt/riscv"
LOG_DIR=$DIR
# variabili per il cross compiler
CROSS_COMPILER="pulp" #decide il tipo di compilatore da installare
TEST_SUITE=1 # se 1 la test suite viene installata altrimenti no
TEST_SUITE_BIT=64 
# pulpussimo
PULPISSIMO_ROOT="$DIR/pulpissimo"
CLONE="clone_dir"
########### end variable

TEMP=`getopt -o vc:t: --long verbose,cross_compiler:,test_suite: -- "$@"`
eval set -- "$TEMP"
echo $@

while true; do
	case $1 in
		-v|--verbose)
			# verbose print using print_verbose
			verbose=1; shift
			;;
		-c|--cross_compiler)
			# decide cross compiler for gnu toolchain
			shift 
			case $1 in 
				pulp)
					# newlib cross-compiler for all pulp variants
					# This will use the multilib support to build the libraries for 
					# the various cores (riscy, zeroriscy and so on). The right libraries 
					# will be selected depending on which compiler options you use.
					CROSS_COMPILER="pulp";;
				newlib)
					# Newlib cross-compiler, You should now be able to use riscv-gcc and its cousins.
					CROSS_COMPILER="newlib";;
				linux|linux64)
					# Linux cross-compiler
					# Supported architectures are rv32i or rv64i plus standard extensions (a)tomics, 
					# (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
					# Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
					# (32-bit with single-precision in registers and double in memory, niche use only), 
					# lp64 lp64f lp64d (same but with 64-bit long and pointers).
                    CROSS_COMPILER="linux64";;
				linux32)
					# as before but 32bit
					CROSS_COMPILER="linux32"
					;;
				linuxm)
					# Linux cross-compiler, both 32 and 64 supported
					CROSS_COMPILER="linuxm"
					;;
				*)
					echo "[!!] error on cross compiler option!!"
					UsageExit;
					;;
			esac
			shift
			;;
		-t|--test_suite)
			# The DejaGnu test suite has been ported to RISC-V. This can run with GDB simulator for elf
			# toolchain or Qemu for linux toolchain, and GDB simulator doesn't support
			# floating-point.
			shift 
			case $1 in
				y)
					TEST_SUITE=1;;
				n) 
					TEST_SUITE=0;;
				y32)
					TEST_SUITE=1;
					TEST_SUITE_BIT=32;;
				*)
					echo "[!!] error on test suite option, only y/n are allowed!!"
					UsageExit;;
			esac
			shift
			;;
		--)
			break;;
		*)
			UsageExit
			;;
	esac
done
############# Allargo la finestra per far  stare tutte le scritte 
mon_run "sudo apt-get install xterm -y" $LOG_DIR/log/xterm.txt  1 $LINENO 
resize -s 30 145

############# verifica del sistema operativo
Print_verbose "[*] Operative system check:" $verbose
if [[ $(uname -a | grep -i ubuntu | wc -l) = 1 ]]; then
	SYSTEM=ubuntu
elif [[ $(uname -a | grep -i centos | wc -l) = 1 ]]; then
	SYSTEM=centos
else
	echo "System not supported!!!"
	exit 1;
fi
Print_verbose "[*]		Your os is $SYSTEM" $verbose
############# Git instllation
if ! hash git 2>/dev/null ; then
	Print_verbose "[*] Install git"
	mon_run "sudo apt-get install git -y" $LOG_DIR/log/git.txt 1 $LINENO 
	# when git install finish this command finished
fi

############# installation of pulp-riscv-gnu-toolchain
# da https://github.com/pulp-platform/pulp-riscv-gnu-toolchain
# RISC-V GNU Compiler Toolchain supports two build modes:
#		generic ELF/Newlib toolchain
#       more sophisticated Linux-ELF/glibc toolchain

# Dipendecies of pulp-riscv-gnu-toolchain
Print_verbose "[+] Installation of pulp-riscv-gnu-toolchain: " $verbose
Print_verbose "[*] 		Install dipendecies" $verbose
if [[ $SYSTEM = "ubuntu" ]]; then
        mon_run "sudo apt-get install autoconf automake autotools-dev curl\
		libmpc-dev libmpfr-dev libgmp-dev gawk build-essential\
		 bison flex texinfo gperf libtool patchutils bc zlib1g-dev -y" $LOG_DIR/log/dep_toolchain.txt 1 $LINENO
else
	mon_run "sudo yum install autoconf automake libmpc-devel mpfr-devel \
		gmp-devel gawk  bison flex texinfo patchutils \
		gcc gcc-c++ zlib-devel -y" $LOG_DIR/log/dep_toolchain.txt 0 $LINENO
fi
mkdir -p $CLONE
# Download of toolchain
gitclone "git clone --recursive https://github.com/pulp-platform/pulp-riscv-gnu-toolchain" "pulp-riscv-gnu-toolchain" "toolchain"

sudo mkdir -p $INSTALL_DIR
cd pulp-riscv-gnu-toolchain
export PATH=$PATH:$INSTALL_DIR/bin
echo "export PATH=$PATH:$INSTALL_DIR/bin" >> ~/.bash_profile
# Install cross compiler 

Print_verbose "[*] 		Install selected cross compiler: $CROSS_COMPILER" $verbose
case $CROSS_COMPILER in
	pulp)
		mon_run "sudo ./configure --prefix=$INSTALL_DIR --with-arch=rv32imc --with-cmodel=medlow --enable-multilib"\
		       	$LOG_DIR/log/cross_compiler.txt 1 $LINENO
		mon_run "sudo make" $LOG_DIR/log/cross_compiler.txt 0 $LINENO
		;;
	newlib)
		mon_run "sudo ./configure --prefix=$INSTALL_DIR"  $LOG_DIR/log/cross_compiler.txt 1 $LINENO
		mon_run "sudo make" $LOG_DIR/log/cross_compiler.txt 0 $LINENO
		;;
	linux64)
		mon_run "sudo ./configure --prefix=$INSTALL_DIR" $LOG_DIR/log/cross_compiler.txt 1  $LINENO
		mon_run "make linux" $LOG_DIR/log/cross_compiler.txt 0 $LINENO
		;;
	linux32)
		mon_run "./configure --prefix=$INSTALL_DIR --with-arch=rv32g --with-abi=ilp32d" $LOG_DIR/log/cross_compiler.txt 1 $LINENO
		mon_run "make linux" $LOG_DIR/log/cross_compiler.txt 0 $LINENO
		;;
	linuxm)
		mon_run "./configure --prefix=$INSTALL_DIR --enable-multilib" $LOG_DIR/log/cross_compiler.txt 1 $LINENO
		mon_run "make linux" $LOG_DIR/log/cross_compiler.txt 0 $LINENO
		;;
	*)
		echo "[!!] Inter error on cross_compiler options"
		UsageExit
		;;
esac


# Install Test Suite

if [[ $TEST_SUITE -eq 1 ]]; then
	Print_verbose "[*] 		Install Test Suite\n[*]	Configure" $verbose
	
	case $CROSS_COMPILER in
		pulp|newlib)
			if [[ $TEST_SUITE_BIT -eq 64 ]]; then
				mon_run "sudo ./configure --prefix=$RISCV --disable-linux --with-arch=rv64ima"\
				       	$LOG_DIR/log/test_suite.txt 1 $LINENO
			else
				mon_run "sudo ./configure --prefix=$RISCV --disable-linux --with-arch=rv32ima"\
				       	$LOG_DIR/log/test_suite.txt 1 $LINENO
			fi
			Print_verbose "[*] make" $verbose
			
			mon_run "sudo make newlib" $LOG_DIR/log/test_suite.txt 0 $LINENO

			mon_run "sudo make check-gcc-newlib" $LOG_DIR/log/test_suite.txt 0 $LINENO
			;;
		linux|linux32|linux64)
			mon_run "./configure --prefix=$RISCV" $LOG_DIR/log/test_suite.txt 1 $LINENO
		 
			mon_run "make linux" $LOG_DIR/log/test_suite.txt 0 $LINENO

			mon_run "make check-gcc-linux" $LOG_DIR/log/test_suite.txt 0 $LINENO
			;;
	esac
fi

export_var "PULP_RISCV_GCC_TOOLCHAIN" "$INSTALL_DIR"
export_var "VSIM_PATH" "$PULPISSIMO_ROOT"

cd ../ # exit from tooolchain

############# PULP SDK build process
## see https://github.com/pulp-platform/pulp-sdk/blob/master/README.md

Print_verbose "[+] Installaition of SDK build process " $verbose
# install dipendecies
if ! hash pip2 2>/dev/null; then
	Print_verbose "[*] 		Pip installation"
	mon_run "sudo apt-get install pip2 pip3 -y" $LOG_DIR/log/pip.txt 1 $LINENO
fi

###### Install dipendecies for SDK build process
Print_verbose "[*] 		Install dipendecies for SDK build process " $verbose
mon_run "sudo apt install git python3-pip python-pip gawk texinfo \
	libgmp-dev libmpfr-dev libmpc-dev swig3.0 libjpeg-dev lsb-core \
	doxygen python-sphinx sox graphicsmagick-libmagick-dev-compat \
	libsdl2-dev libswitch-perl libftdi1-dev cmake scons libsndfile1-dev -y"\
	$LOG_DIR/log/sdk_dep.txt 1 $LINENO
mon_run "sudo pip3 install openpyxl" $LOG_DIR/log/sdk_dep.txt 0 $LINENO
mon_run "sudo pip3 install artifactory twisted prettytable sqlalchemy \
	pyelftools openpyxl==2.6.4 xlsxwriter pyyaml numpy configparser pyvcd"\
	$LOG_DIR/log/sdk_dep.txt 0 $LINENO
mon_run "sudo pip2 install configparser" $LOG_DIR/log/sdk_dep.txt 0 $LINENO

######  Installation of gcc5 and g++5
Print_verbose "[*]  	Installation of gcc5 and g++5" $verbose
mon_run "sudo apt-get install gcc-5 g++-5 -y" $LOG_DIR/log/gcc++.txt 1 $LINENO
mon_run "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10" $LOG_DIR/log/gcc++.txt 0 $LINENO
mon_run "sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-5 10" $LOG_DIR/log/gcc++.txt 0 $LINENO
mon_run "sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30" $LOG_DIR/log/gcc++.txt 0 $LINENO
mon_run "sudo update-alternatives --set cc /usr/bin/gcc" $LOG_DIR/log/gcc++.txt 0 $LINENO
mon_run "sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30" $LOG_DIR/log/gcc++.txt 0 $LINENO
mon_run "sudo update-alternatives --set c++ /usr/bin/g++" $LOG_DIR/log/gcc++.txt 0 $LINENO

gitclone "git clone https://github.com/pulp-platform/pulp-sdk.git -b master --progress" "pulp-sdk"  "sdk_downl"

cd pulp-sdk
Print_verbose "[*] 		Target and platform selection" $verbose
source configs/pulpissimo.sh
# devo scegliere la piattaforma: board,fpga,gvsoc,hsas,rtl
source configs/platform-rtl.sh
Print_verbose "[*] 		Build" $verbose
mon_run "make all"  $LOG_DIR/log/sdk_build.txt 1 $LINENO

cd ../ #exit from sdk


############# Pulp builder install
gitclone "git clone https://github.com/pulp-platform/pulp-builder.git --progress" "pulp_builder" "pulp_builder"

cd pulp-builder
mon_run "git checkout 0e51ae60d66f4ec326582d63a9fcd40ed2a70e15" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "source configs/pulpissimo.sh" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "./scripts/clean" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "./scripts/update-runtime" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "./scripts/build-runtime" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "source sdk-setup.sh" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
mon_run "source configs/rtl.sh" $LOG_DIR/log/pulp_builder.txt 0 $LINENO
cd ..


########### Pulpissimo 
Print_verbose "[*] 	Installation of Pulpissimo"
gitclone "git clone https://github.com/pulp-platform/pulpissimo.git --progress " "pulpissimo" "pulpissimo"
cd pulpissimo
mon_run "./update-ips" $LOG_DIR/log/update_ips.txt 0 $LINENO
i
