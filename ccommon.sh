#!/usr/bin/bash
Print_verbose () {
       # stampa $1 solo se $2 = 1
       if [[ $2 = 1 ]]; then
           echo -e "$1"
        fi
}

monitor_file () {
	   # stampa in numero di righe del file in questione 
	   # riscrivendo la riga ogni volta dando l'effetto progressivo
	   file=$1 # name of file to monitor
	   str=$2  # str before line number
	   id=$3 # id of process ($!)
	   var=0
	   var_err=0
	   while true; do 
		   # calcolo delle righe dell'output file
		   var=$(cat $file | wc -l); 
		   # calcolo delle righe dell'error file
		   var_err=$(cat $(echo $file | cut -d "." -f 1)_err.txt | wc -l) 
	           # calcolo delle righe totali
		   res=$(($var+$var_err))
		   # se le righe sono maggiori di 1 stampo il log
		   if [[ $res -ne 0 ]]; then 
			if [[ $var -lt $var_old ]]; then
				lastline=$(tail -n 1 $file)
			else
				lastline=$(tail -n 1 $(echo $file | cut -d "." -f 1)_err.txt)
			fi
			
			if [[ $var -ne $var_old ]] || [[ $var_err -ne $var_err_old ]]; then
				printf "[i]  %-50s]:%-5d | %-70s\r" "${str:0:50}" "$res" "${lastline:0:70}"
			fi
			if ! test -d /proc/$id; then
				break
			fi
		   else
			   printf "[i]  %-50s]:%-5d \r" "${str:0:50}" "$res"
		   fi
		   var_old=$var
		   var_err_old=$var_err
	   done
	   printf "[i]  %-50s]:%-5d \n" "${str:0:50}" "$res"
}

monitor_file_error () {
	   # stampa tutte le righe con errore e 
	   # se  ce se sono chiude lo script
	   # $1 è il nome del file con eventuali errori
	   cat $1 | grep -ni "error" --color > error_log.txt
   	   if [[ $(cat error_log.txt | wc -l) -gt 0 ]]; then
		   echo "[!]  An error has been found!!!!!"
		   echo "[!]  command: $2"
		   echo "[!]  Log file with error: "$1
	   	   echo "[!]  These are error lines of the log file:"
		   cat error_log.txt
		   echo "[!]  These are error lines from the error log file:"
		   cat $(echo $1 | cut -d "." -f 1)_err.txt
		   echo "[!]  More info in file $1"
		   exit 1
		   return 0
	   fi
}
	
mon_run (){
	   # $1 è il comando da eseguire
	   # $2 è il file in cui scrivere il log
	   # $3 se è 1 sovrascrivo il file
	   # $4 è l'eventuale numero di riga

	   sudo mkdir -p $(dirname $2)
	   sudo touch $2
	   sudo touch $(echo $2 | cut -d "." -f 1)_err.txt
	   sudo chmod 777 $2
	   sudo chmod 777 $(echo $2 | cut -d "." -f 1)_err.txt
	   if [[ $3 -eq 1 ]]; then
		   $1 > $2 2> $(echo $2 | cut -d "." -f 1)_err.txt &
	   else
		   	$1 >> $2 2>> $(echo $2 | cut -d "." -f 1)_err.txt &
	   fi
	   monitor_file "$2" "line $4: [$1" $!
	   monitor_file_error $2 "Line $4: $1"
	   echo "Line $4: $1" >> trace_command.txt
}

export_path (){
	   export PATH=$PATH:$1
	   echo "export PATH=$PATH:$1" >> ~/.bash_profile
}

export_var (){
	   export $1=$2
	   echo "export $1=$2" >> ~/.bash_profile
}
