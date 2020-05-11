#!/usr/bin/bash
Print_verbose () {
       # stampa $1 solo se $2 = 1
       if [[ $2 = 1 ]]; then
           echo -e "$1\n"
        fi
}

monitor_file () {
	   # stampa in numero di righe del file in questione 
	   # riscrivendo la riga ogni volta dando l'effetto progressivo
	   file=$1 # name of file to monitor
	   str=$2  # str before line number
	   id=$3 # id of process ($!)
	   while true; do 
		   var=$(cat $file | wc -l); 
		   echo -ne "$str($var)\r"; 
		   if ! test -d /proc/$id; then
			   break
			 fi
	   done
	   echo ""
}

monitor_file_error () {
	   # stampa tutte le righe con errore e 
	   # se  ce se sono chiude lo script
	   cat $1 | grep -ni error --color > error_log.txt
   	   if [[ $(cat error_log.txt | wc -l) -gt 0 ]]; then
		   echo $1
	   		cat error_log.txt
		   exit 1
		   return 0
	   fi
}
	
mon_run (){
	   # $1 è il comando da eseguire
	   # $2 è il file in cui scrivere il log
	   # $3 se è 1 sovrascrivo il file
	   if [[ $3 -eq 1 ]]; then
	   		$1 > $2 &
	   else
		   	$1 >> $2 &
	   fi
	   monitor_file "$2" "[line]      " $!
	   monitor_file_error $2
}

export_path (){
	   export PATH=$PATH:$1
	   echo "export PATH=$PATH:$1" >> ~/.bash_profile
}

export_var (){
	   export $1=$2
	   echo "export $1=$2" >> ~/.bash_profile
}
