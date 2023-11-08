#!/bin/bash
set -x

#########################################################################################
# Para ejecutar este comando cada 5 minutos agregar con crontab -e la siguiente linea   #
# */5 * * * * /<directorio adonde está el comando monitor.sh>                           #
#########################################################################################


# Configuración para envío de email
mail_root="root"
titulo_mail="Reporte monitor procesos"


# Función para mostrar la ayuda
mostrar_ayuda() {
  echo "ingrese el comando y el proceso a monitorear"
  echo "Uso: $0 [proceso a monitorear]"
  echo "Ejemplo: $0 systemd"
}

# Función para generar logs
generar_log() {
  local archivo_log="$1"
  local status="$2"
  local Pro="$3"

  if [[ $status -eq 0 ]]; then
    echo "El Proceso $Pro se encuentra en ejecución $(date)." >> "$archivo_log"
  else
    echo "El proceso $Pro no se encuentra en ejecución $(date)." >> "$archivo_log"
  fi
}

# Llamada principal
main() {
  # Mostrar ayuda si se solicita o si no hay suficientes argumentos
  if [[ "$1" == "-h" ]] || [[ "$1" == "-H" ]] || [[ $# -lt 1 ]]; then
    mostrar_ayuda
    exit 0
  fi
  local proceso="$1"

  if ps auxw | grep $proceso | grep -v grep | grep -v monitor.sh; then
    generar_log "/var/log/monitor.log" 0 $proceso
  else
    echo "Proceso no activo" | mutt -s "Proceso no activo" --"$mail_root"
    exit 1
  fi
}

# Ejecutar la función principal con los argumentos pasados al script
main "$@"
~
