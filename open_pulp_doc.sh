#!/bin/bash

find_start(){
	file_name=$1
	stopper=$2
	cnt=0
	while read line; do 
		cnt=$(($cnt+1));  
		if [[ $line == $stopper ]]; then 
			echo $cnt;
			break;
		fi; 
	done < $file_name
}

script_name=`basename "$0"`

file_len=$(cat $script_name | wc -l)
start=$(find_start $script_name "##### BEGIN LINKS #####")
link_num=$(($file_len-$start))

links=$(tail -n $link_num $script_name | sed "s/#//g")
echo $links | tr " " "\n"

firefox_args=""
for link in $links; do
	firefox_args+="--new-tab -url $link "
done
echo "firefox "$firefox_args
firefox $firefox_args &


##### BEGIN LINKS #####
#https://www.overleaf.com/project/5eb9915e6f47b20001579d90
#https://www.deepl.com/translator
#https://github.com/pulp-platform/pulpissimo
#https://github.com/pulp-platform/pulpissimo/blob/master/doc/datasheet/datasheet.pdf
#https://github.com/pulp-platform/pulp-sdk
#https://github.com/pulp-platform/pulp-riscv-gnu-toolchain
#https://github.com/pulp-platform/pulp-builder
#https://github.com/lucafiore/RISCV_OS
#https://github.com/cmcmicrosystems/pulpissimo-zcu102
#https://pulp-platform.org/index.html

