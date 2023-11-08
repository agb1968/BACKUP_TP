#!/bin/bash

# Definir array que asocie los días feriados, seguro este array hay que actualizarlo cada año
declare -A feriados
feriados=(
  ["0101"]="Año Nuevo"
  ["2403"]="Día Nacional de la Memoria por la Verdad y la Justicia"
  ["0101"]="Año Nuevo"
  ["2002"]="Carnaval"
  ["2102"]="Carnaval"
  ["2403"]="Día Nacional de la Memoria por la Verdad y la Justicia"
  ["0204"]="Viernes Santo"
  ["0105"]="Día del Trabajador"
  ["2505"]="Día de la Revolución de Mayo"
  ["1706"]="Día del Paso a la Inmortalidad del General Martín Miguel de Güemes"
  ["2006"]="Día del Paso a la Inmortalidad del General Manuel Belgrano"
  ["0907"]="Día de la Independencia"
  ["1508"]="Día de la Asunción de la Virgen"
  ["1010"]="Día del Respeto a la Diversidad Cultural"
  ["2011"]="Día de la Soberanía Nacional"
  ["0812"]="Día de la Inmaculada Concepción de María"
  ["2512"]="Navidad"
  # Añadir más feriados aquí...
)

# Función para validar la fecha
validarFecha() {
  local fecha=$1
  if ! [[ $fecha =~ ^[0-3][0-9][0-1][0-9][0-9]{4}$ ]]; then
    echo "Formato de fecha incorrecto. Asegúrese de usar DDMMAAAA."
    exit 1
  fi
}

# Función para verificar si es fin de semana
esFinDeSemana() {
  local fecha=$1
  local diaSemana

  # Trato de convertir el día de la semana a número para identificar los sábados al número 6 y domingos al número 7
  diaSemana=$(date -d "${fecha:4:4}-${fecha:2:2}-${fecha:0:2}" +%u)

  # Si coincide puedo identificar cuando cae en un fin de semana 
  if [[ $diaSemana -eq 6 || $diaSemana -eq 7 ]]; then
    echo "La fecha $fecha cae en fin de semana."
    exit 0
  fi
}

# Función para verificar si es feriado, esto lo hago de la siguiente manera
# tomo la fecha larga en formao DDMMAAAA y le anulo el año creando la variable 
# Fecha_corta

# Con el if me aseguro si la fecha_corta está dentro del array de feriados que definímos arriba
# en ese caso confirmo que sea un feriado.

esFeriado() {
  local fecha_larga=$1
  local fecha_corta="${fecha_larga:0:4}"
  if [[ ${feriados[$fecha_corta]+_} ]]; then
    echo "La fecha $fecha_larga es un feriado: ${feriados[$fecha]}"
    exit 0
  else
    echo "La fecha $fecha no es un feriado."
  fi
}

# Verificar si se ha proporcionado un argumento
if [[ $# -ne 1 ]]; then
  echo "Uso: $0 DDMMAAAA"
  exit 1
fi

fecha="$1"
# Validar la fecha
validarFecha "$fecha"
# Verificar si es fin de semana
esFinDeSemana "$fecha"
# Verificar si es feriado
esFeriado "$fecha"
