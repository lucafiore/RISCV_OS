PULPissimo Installer 
====================================
## General Info
The installer bash script is the file install_all.sh with the bash library ccommon.sh
these file is able to download and configure the complete PULPissimo project with
all toolchain repository. The installation is configurable via command line argument described below:

## Option
#-c|--cross-compiler
  * pulp (defaul option): Install the Newlib cross compiler for all pulp variant and multilib support to build the library 
                          for the various cores (riscy, zeroriscy and so on). Newlib is a C library intended for use on embedded systems. 
                          It is a conglomeration of several library parts, all under free software licenses that make them easily usable 
                          on embedded products. It can be compiled for a wide array of processors, and will usually work on any 
                          architecture with the addition of a few low-level routines. https://www.sourceware.org/newlib/
