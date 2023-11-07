#!/bin/bash
set -x
# Configuración para envío de email
mail_root="root"
titulo_mail="Reporte del Script de Backup"

# Función para mostrar la ayuda
mostrar_ayuda() {
  echo "Uso: $0 [directorio origen] [directorio destino]"
  echo "Ejemplo: $0 /u01 /u03"
}

# Función para generar logs con el formato HH:MM:SS - Mensaje
genero_log() {
  local mensaje=$1
  local log=$2
  # Seteo el formato de la hora actual con el formato HH:MM:SS
  local hora=$(date +"%H:%M:%S")
  # Escribe la hora y el mensaje al archivo de log
  echo "$hora - $mensaje" >> "$log"
}


# Función para verificar directorios
checkear_directorios() {
  local directorio_origen="$1"
  local directorio_destino="$2"

  # Verificar existencia del directorio origen
  if [[ ! -d "$directorio_origen" ]]; then
    echo "El directorio origen $directorio_origen no existe."
    genero_log "El directorio origen $directorio_origen no existe | ........" "$archivo_log"
    return 1
  fi

  # Verificar existencia del directorio destino y si está montado
  if [[ ! -d "$directorio_destino" ]] || ! mountpoint -q "$directorio_destino"; then
    echo "El directorio destino $directorio_destino no existe o no está montado."
    genero_log "El directorio destino $directorio_destino no existe | ........" "$archivo_log"
    return 1
  fi

  return 0
}

# Función para reemplazar todas las barras '/' si la barra está al principio o al final se elimina y después las que quedan se reemplazan por guiones bajos '_' para nombrar los archivos de backup
reemplazo_barras() {
  local nombre_directorio_origen=$1
  # Elimina barras al principio y al final.
  local nombre_sin_barra_inicial=${nombre_directorio_origen#/}  # Elimina la barra del principio
  nombre_sin_barras=${nombre_sin_barra_inicial%/}                  # Elimina la barra del final
  # Reemplaza todas las ocurrencias de '/' por '_' en el medio.
  local salida_directorio=${nombre_sin_barras//\//_}
  echo "$salida_directorio"
}

# Función para realizar el backup completo con tar
hacer_backup() {
  local directorio_origen="$1"
  local directorio_destino="$2"
  local nombre_directorio=$(reemplazo_barras "$directorio_origen")
  local archivo_backup="${nombre_directorio}_bkp_$(date +"%Y%m%d-%H%M%S").tar.gz"  
  local archivo_log="$directorio_destino/backup_log_$(date +"%Y%m%d-%H%M%S").txt"

  # Crear el backup y guardar la salida en un archivo de log
  tar -cvzf "$directorio_destino/$archivo_backup" -C "$directorio_origen" . >> "$archivo_log" 2>&1
  
  # Logueo actividad
  genero_log "Iniciando el backup | ........" "$archivo_log"
 
  local status=$?
  echo "Backup y log creados en $directorio_destino"

  genero_log "Backup generado | Log creado " "$archivo_log"
  

  # Llamar a la función de log
  genero_log "$archivo_log" "$status"

  # Llamar a la función de envío de email
  envio_mail "$archivo_log" "$status"
}

# Función para generar logs
generar_log() {
  local archivo_log="$1"
  local status="$2"

  if [[ $status -eq 0 ]]; then
    echo "Backup realizado con éxito el $(date)." >> "$archivo_log"
  else
    echo "Error durante el backup el $(date)." >> "$archivo_log"
  fi
}

# Función para enviar un email con mutt
envio_mail() {
  local archivo_log="$1"
  local status="$2"

  # Construir el cuerpo del mensaje basado en el estado del backup
  local cuerpo="El proceso de backup ha finalizado."
  if [[ $status -eq 0 ]]; then
    cuerpo+=" El backup se completó con éxito."
  else
    cuerpo+=" Hubo un error durante el backup."
  fi

  # Envío de email usando mutt
  echo "$cuerpo" | mutt -a "$archivo_log" -s "$titulo_mail" -- "$mail_root"
}

# Llamada principal
main() {
  # Mostrar ayuda si se solicita o si no hay suficientes argumentos
  if [[ "$1" == "-h" ]] || [[ "$1" == "-H" ]] || [[ $# -lt 2 ]]; then
    mostrar_ayuda
    exit 0
  fi

  local directorio_origen="$1"
  local directorio_destino="$2"

  if checkear_directorios "$directorio_origen" "$directorio_destino"; then
    hacer_backup "$directorio_origen" "$directorio_destino"
  else
    echo "No se pudo realizar el backup debido a un error en la verificación de los directorios. O no existe o no está montado"
    exit 1
  fi
}

# Ejecutar la función principal con los argumentos pasados al script
main "$@"
