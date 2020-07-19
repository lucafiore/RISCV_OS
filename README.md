PULPissimo Installer 
====================================
### General Info
Apart many documentation file the PULPissimo installer bash script is the file install_all.sh (with his bash library ccommon.sh)
these files are able to download and configure the complete PULPissimo project with
all PULP toolchain repository. The installation is configurable via command line argument described below:

## Option
  * -v|--verbose   print more information about installation progress.
  * -c|--cross-compiler        \[pulp|newlib|linux|linux32|linuxm\]
      * pulp (defaul option): Install the Newlib cross compiler for all pulp variant and multilib support to build the library 
                          for the various cores (riscy, zeroriscy and so on). Newlib is a C library intended for use on embedded systems. 
                          It is a conglomeration of several library parts, all under free software licenses that make them easily usable 
                          on embedded products. It can be compiled for a wide array of processors, and will usually work on any 
                          architecture with the addition of a few low-level routines. https://www.sourceware.org/newlib/.
      * newlib : Install the Newlib cross compiler with gcc support for risc application, in order to use openOCD later.
      * linux:  Linux cross compiler 64 bit. Supported architectures are rv64i plus standard extensions (a)tomics, 
                (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
                Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
                (32-bit with single-precision in registers and double in memory, niche use only), 
                lp64 lp64f lp64d (same but with 64-bit long and pointers).
      * linux32:  Linux cross compiler 32 bit
                Supported architectures are rv32i plus standard extensions (a)tomics, 
                (m)ultiplication and division, (f)loat, (d)ouble, or (g)eneral for MAFD.
                Supported ABIs are ilp32 (32-bit soft-float), ilp32d (32-bit hard-float), ilp32f 
                (32-bit with single-precision in registers and double in memory, niche use only), 
                lp64 lp64f lp64d (same but with 64-bit long and pointers).
      * linuxm:  Linux cross-compiler, both 32 and 64 supported
  * -p|--part_install     \[0|1|2|3|4|5\] default 0
      * 0 start from scratch
			  	* 1 start after the toolchain
				  * 2 start after the sdk
				  * 3 start after pulp-builder
				  * 4 test (hello)
				  * 5 virtual platform
  * -t|--test_suite       \[y|n\]  Decide if install test suite or not, this test suite 

