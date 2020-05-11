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
INSTALL_DIR="$DIR/opt/riscv"
# variabili per il cross compiler
CROSS_COMPILER="pulp" #decide il tipo di compilatore da installare
TEST_SUITE=1 # se 1 la test suite viene installata altrimenti no
TEST_SUITE_BIT=64 
# pulpussimo
PULPISSIMO_ROOT="$DIR/pulpissimo"
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
					CROSS_COMPILER="pulp"; break;;
				newlib)
					# Newlib cross-compiler, You should now be able to use riscv-gcc and its cousins.
					CROSS_COMPILER="newlib"; break;;
				linux|linux64)
					# Linux cross-compiler
					# Supported architectures are rv32i or rv64i plus standard extensions (a)tomics, 
					# (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
					# Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
					# (32-bit with single-precision in registers and double in memory, niche use only), 
					# lp64 lp64f lp64d (same but with 64-bit long and pointers).
                    CROSS_COMPILER="linux64"; break;;
				linux32)
					# as before but 32bit
					CROSS_COMPILER="linux32"; break;;
				linuxm)
					# Linux cross-compiler, both 32 and 64 supported
					CROSS_COMPILER="linuxm"; break;;
				*)
					echo "[!!] error on cross compiler option!!"
					UsageExit;
					break;;
			esac
			shift
			break;;
		-t|--test_suite)
			# The DejaGnu test suite has been ported to RISC-V. This can run with GDB simulator for elf
			# toolchain or Qemu for linux toolchain, and GDB simulator doesn't support
			# floating-point.
			shift 
			case $1 in
				y)
					TEST_SUITE=1; break;;
				n) 
					TEST_SUITE=0; break;;
				y32)
					TEST_SUITE=1;
					TEST_SUITE_BIT=32
					break;;
				*)
					echo "[!!] error on test suite option, only y/n are allowed!!"
					UsageExit;
					break;;
			esac
			shift
			break;;					
		--)
			break;;
		*)
			UsageExit;;
	esac
done


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
	mon_run "sudo apt-get install git -y" $INSTALL_DIR/log/git.txt 1 
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
		 bison flex texinfo gperf libtool patchutils bc zlib1g-dev -y" $INSTALL_DIR/log/dep_toolchain.txt 1
else
	mon_run "sudo yum install autoconf automake libmpc-devel mpfr-devel \
		gmp-devel gawk  bison flex texinfo patchutils \
		gcc gcc-c++ zlib-devel -y" $INSTALL_DIR/log/dep_toolchain.txt 0

# Download of toolchain
if ! test -d pulp-riscv-gnu-toolchain; then
	Print_verbose "[*] 		Download of toolchain" $vp-perbose
	mon_run "git clone --recursive https://github.com/pulp-platform/pulp-riscv-gnu-toolchain -y" \
				$INSTALL_DIR/log/toolchain.txt 1
fi

mkdir -p $INSTALL_DIR
cd pulp-riscv-gnu-toolchain
export PATH=$PATH:$INSTALL_DIR/bin
echo "export PATH=$PATH:$INSTALL_DIR/bin" >> ~/.bash_profile
# Install cross compiler 

Print_verbose "[*] 		Install selected cross compiler: $CROSS_COMPILER" $verbose
case $CROSS_COMPILER in
	pulp)
		mon_run "./configure --prefix=/opt/riscv --with-arch=rv32imc \
			--with-cmodel=medlow --enable-multilib" $DIR/log/cross_compiler.txt 1 
		mon_run "make" $DIR/log/cross_compiler.txt 0
		break;;
	newlib)
		mon_run "./configure --prefix=/opt/riscv"  $DIR/log/cross_compiler.txt 1
		mon_run "make" $DIR/log/cross_compiler.txt 0
		break;;
	linux64)
		mon_run "./configure --prefix=/opt/riscv" $DIR/log/cross_compiler.txt 1 
		mon_run "make linux" $DIR/log/cross_compiler.txt 0
		break;;
	linux32)
		mon_run "./configure --prefix=/opt/riscv --with-arch=rv32g \ 
			--with-abi=ilp32d" $DIR/log/cross_compiler.txt 1
		mon_run "make linux" $DIR/log/cross_compiler.txt 0
		break;;
	linuxm)
		mon_run "./configure --prefix=/opt/riscv --enable-multilib" $DIR/log/cross_compiler.txt 1 
		mon_run "make linux" $DIR/log/cross_compiler.txt 0
		break;;
	*)
		echo "[!!] Inter error on cross_compiler options"
		UsageExit
		break;;
esac


# Install Test Suite

if [[ $TEST_SUITE -eq 1 ]]; then
	Print_verbose "[*] 		Install Test Suite\n[*]	Configure" $verbose
	
	case $CROSS_COMPILER in
		pulp|newlib)
			if [[ $TEST_SUITE_BIT -eq 64 ]]; then
				mon_run "./configure --prefix=$RISCV --disable-linux \
					--with-arch=rv64ima" $DIR/log/test_suite.txt 1
			else
				mon_run "./configure --prefix=$RISCV --disable-linux \
					--with-arch=rv32ima" $DIR/log/test_suite.txt 1
			fi
			Print_verbose "[*] make" $verbose
			
			mon_run "make newlib" $DIR/log/test_suite.txt 0

			mon_run "make check-gcc-newlib" $DIR/log/test_suite.txt 0
			break;;	
		linux|linux32|linux64)
			mon_run "./configure --prefix=$RISCV" $DIR/log/test_suite.txt 1
		 
			mon_run "make linux" $DIR/log/test_suite.txt 0

			mon_run "make check-gcc-linux" $DIR/log/test_suite.txt 0
			break;;
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
	mon_run "sudo apt-get install pip2 pip3 -y" $DIR/log/pip.txt 1
fi
Print_verbose "[*] 		Install dipendecies for SDK build process " $verbose
mon_run "sudo apt install git python3-pip python-pip gawk texinfo \
	libgmp-dev libmpfr-dev libmpc-dev swig3.0 libjpeg-dev lsb-core \
	doxygen python-sphinx sox graphicsmagick-libmagick-dev-compat \
	libsdl2-dev libswitch-perl libftdi1-dev cmake scons libsndfile1-dev -y"\
	$DIR/log/sdk_dep.txt 1
mon_run "sudo pip3 install artifactory twisted prettytable sqlalchemy \
	pyelftools 'openpyxl==2.6.4' xlsxwriter pyyaml numpy configparser pyvcd -y"\
	$DIR/log/sdk_dep.txt 0
mon_run "sudo pip2 install configparser -y" $DIR/log/sdk_dep.txt 0

Print_verbose "[*]  	Installation of gcc5 and g++5" $verbose
mon_run "sudo apt-get install gcc-5 g++-5 -y" $DIR/log/gcc++.txt 1
mon_run "sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-5 10" $DIR/log/gcc++.txt 0
mon_run "sudo update-alternatives --install /usr/bin/g++ g++ usr/bin/g++-5 10" $DIR/log/gcc++.txt 0
mon_run "sudo update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30" $DIR/log/gcc++.txt 0
mon_run "sudo update-alternatives --set cc /usr/bin/gcc" $DIR/log/gcc++.txt 0
mon_run "sudo update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30" $DIR/log/gcc++.txt 0
mon_run "sudo update-alternatives --set c++ /usr/bin/g++" $DIR/log/gcc++.txt 0

if ! test --d pulp_sdk; then
	Print_verbose "[*]		Download of SDK:" $verbose
	mon_run "git clone https://github.com/pulp-platform/pulp-sdk.git -b master" $DIR/log/sdk_downl.txt 1
fi
cd pulp-sdk
Print_verbose "[*] 		Target and platform selection" $verbose
mon_run "source configs/pulpissimo.sh" $DIR/log/sdk_target.txt 1
# devo scegliere la piattaforma: board,fpga,gvsoc,hsas,rtl
mon_run "source configs/platform-rtl.sh" $DIR/log/sdk_target.txt 0
Print_verbose "[*] 		Build" $verbose
mon_run "make all"  $DIR/log/sdk_build.txt 1

cd ../ #exit from sdk


############# Pulp builder install

mon_run "git clone https://github.com/pulp-platform/pulp-builder.git" $DIR/log/pulp_builder.txt 1
cd pulp-builder
mon_run "git checkout 0e51ae60d66f4ec326582d63a9fcd40ed2a70e15" $DIR/log/pulp_builder.txt 0
mon_run "source configs/pulpissimo.sh" $DIR/log/pulp_builder.txt 0
mon_run "./scripts/clean" $DIR/log/pulp_builder.txt 0
mon_run "./scripts/update-runtime" $DIR/log/pulp_builder.txt 0
mon_run "./scripts/build-runtime" $DIR/log/pulp_builder.txt 0
mon_run "source sdk-setup.sh" $DIR/log/pulp_builder.txt 0
mon_run "source configs/rtl.sh" $DIR/log/pulp_builder.txt 0
cd ..

