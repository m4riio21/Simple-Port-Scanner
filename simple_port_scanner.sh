#!/bin/bash

# Inicializar variable para guardar puertos abiertos
PUERTOS_TCP=""
PUERTOS_UDP=""
# Iniciar bucle infinito
while :
do
  # Mostrar indicador de comando
  printf "\e[0;31m\033[1m# scanner > \033[0m\e[0m"
  
  # Leer entrada del usuario
  read INPUT
  
  # Separar modo, dirección IP y archivo de salida
  MODO=`echo $INPUT | awk '{print $1}'`
  IP=`echo $INPUT | awk '{print $2}'`
  ARCHIVO=`echo $INPUT | awk '{print $3}'`
  
  # Panel de ayuda
  if [ "$MODO" == "help" ]; then
	echo -e "\n\nUso: \e[0;31m\033[1m<modo> <host>\033[0m\e[0m [archivo]"
	echo -e "\nModos:\n\n\t\e[0;31m\033[1mnormal\033[0m\e[0m: escaneo de puertos tcp modo CONNECT\n\n\t\e[0;31m\033[1mfast\033[0m\e[0m: escaneo de puertos tcp modo SYN. Requiere permisos \e[0;31m\033[1mroot\033[0m\e[0m\n\n\t\e[0;31m\033[1mudp\033[0m\e[0m: escaneo de puertos comunes UDP\n\n\t\e[0;31m\033[1mservices\033[0m\e[0m: escaneo de versiones de los servicios tcp encontrados con el modo normal o fast ejecutado anteriormente\n"
  fi
  
  # Comprobar el modo de escaneo y ejecutar el comando adecuado
  if [ "$MODO" == "fast" ]; then
    # Ejecutar escaneo rápido y guardar puertos abiertos en variable
    PUERTOS_TCP=`nmap -sS --min-rate 5000 -p- --open -Pn $IP 2>/dev/null | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/tcp"`
    echo -e "\n"

    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    if [ "$ARCHIVO" != "" ]; then
        nmap -sS --min-rate 5000 -p- --open -Pn $IP -oN $ARCHIVO 2>/dev/null| grep -A 1000 "PORT"
    else
	nmap -sS --min-rate 5000 -p- --open -Pn $IP 2>/dev/null| grep -A 1000 "PORT"
    fi

    echo -e "\n"
  elif [ "$MODO" == "normal" ]; then
    # Ejecutar escaneo normal y guardar puertos abiertos en variable
    PUERTOS_TCP=`nmap -p- --open -T5 -n $IP 2>/dev/null | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/tcp"`
    echo -e "\n"

    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    if [ "$ARCHIVO" != "" ]; then
        nmap -p- --open -T5 -nv $IP -oN $ARCHIVO 2>/dev/null| grep -A 1000 "PORT"
    else
         nmap -p- --open -T5 -nv $IP 2>/dev/null| grep -A 1000 "PORT"
    fi

    echo -e "\n"
  elif [ "$MODO" == "UDP" ]; then
    PUERTOS_UDP=`nmap -sU --open -T5 -nv $IP 2>/dev/null | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/udp"`
    echo -e "\n"

    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    if [ "$ARCHIVO" != "" ]; then
        nmap -sU --open -T5 -nv $IP -oN $ARCHIVO 2>/dev/null| grep -A 1000 "PORT"
    else
        nmap -sU --open -T5 -nv $IP 2>/dev/null| grep -A 1000 "PORT"
    fi

    echo -e "\n"
  elif [ "$MODO" == "services" ]; then
    # Comprobar si hay puertos abiertos y ejecutar escaneo de servicios
    if [ "$PUERTOS_TCP" != "" ]; then

      echo -e "\n"
      # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
      if [ "$ARCHIVO" != "" ]; then
        nmap -p$PUERTOS_TCP -sCV $IP -oN $ARCHIVO 2>/dev/null | grep -A 1000 "PORT"
      else
	nmap -p$PUERTOS_TCP -sCV $IP 2>/dev/null | grep -A 1000 "PORT"
      fi

      echo -e "\n"
    fi
  fi
done
