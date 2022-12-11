#!/bin/bash

# Inicializar variable para guardar puertos abiertos
PUERTOS_TCP=""
PUERTOS_UDP=""
# Iniciar bucle infinito
while :
do
  # Mostrar indicador de comando
  printf "# scanner > "
  
  # Leer entrada del usuario
  read INPUT
  
  # Separar modo, dirección IP y archivo de salida
  MODO=`echo $INPUT | awk '{print $1}'`
  IP=`echo $INPUT | awk '{print $2}'`
  ARCHIVO=`echo $INPUT | awk '{print $3}'`
  
  # Comprobar el modo de escaneo y ejecutar el comando adecuado
  if [ "$MODO" == "fast" ]; then
    # Ejecutar escaneo rápido y guardar puertos abiertos en variable
    PUERTOS_TCP=`nmap -sS --min-rate 5000 -p- --open -Pn $IP | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/tcp"`
    echo $PUERTOS
    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    nmap -sS --min-rate 5000 -p- --open -Pn $IP ${ARCHIVO:+"> $ARCHIVO"}
  elif [ "$MODO" == "normal" ]; then
    # Ejecutar escaneo normal y guardar puertos abiertos en variable
    PUERTOS_TCP=`nmap -p- --open -T5 -nv $IP | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/tcp"`
    
    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    nmap -p- --open -T5 -nv $IP ${ARCHIVO:+"> $ARCHIVO"}
  elif [ "$MODO" == "UDP" ]; then
    PUERTOS_UDP=`nmap -sU --open -T5 -nv $IP | grep open | awk '{print $1}' | tr '\n' ',' | sed 's/,$//' | tr -d "/udp"`
    # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
    nmap -sU --open -T5 -nv $IP ${ARCHIVO:+"> $ARCHIVO"}
  elif [ "$MODO" == "services" ]; then
    # Comprobar si hay puertos abiertos y ejecutar escaneo de servicios
    if [ "$PUERTOS_TCP" != "" ]; then
      # Ejecutar comando de nmap con el modo adecuado y opción de archivo de salida
      nmap -sCV -p$PUERTOS_TCP $IP ${ARCHIVO:+"> $ARCHIVO"}
    fi
  fi
done
