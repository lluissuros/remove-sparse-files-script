#!/bin/bash

# Crear carpeta 'sparse' si no existe
mkdir -p sparse

# Crear lista temporal
tempfile=$(mktemp)

echo "🔍 Escaneando archivos sospechosos de ser sparse..."
echo ""

find . -type f | while read -r path; do
  logical_size=$(stat -f%z "$path")     # Lógico en bytes
  real_size=$(du -k "$path" | cut -f1)  # Real en KB
  logical_size_kb=$((logical_size / 1024))

  if [ "$real_size" -gt $((logical_size_kb * 2)) ]; then
    echo "$path|$logical_size_kb|$real_size" >> "$tempfile"
  fi
done

if [ ! -s "$tempfile" ]; then
  echo "✅ No se encontraron archivos sparse con diferencia significativa."
  rm "$tempfile"
  exit 0
fi

# Mostrar lista previa
echo "⚠️  Se encontraron los siguientes archivos sospechosos:"
echo ""
printf "%-60s | %12s | %12s\n" "Archivo" "Lógico (MB)" "Real (MB)"
echo "----------------------------------------------------------------------------------------------"

while IFS="|" read -r path logical_kb real_kb; do
  logical_mb=$(echo "scale=2; $logical_kb / 1024" | bc -l)
  real_mb=$(echo "scale=2; $real_kb / 1024" | bc -l)
  printf "%-60s | %12s | %12s\n" "$path" "$logical_mb" "$real_mb"
done < "$tempfile"

echo ""
read -p "¿Quieres limpiar estos archivos y restaurar en su carpeta original? (Y/N): " confirm

if [[ "$confirm" != "Y" && "$confirm" != "y" ]]; then
  echo "❌ Cancelado. No se hizo ningún cambio."
  rm "$tempfile"
  exit 0
fi

# Ejecutar limpieza
while IFS="|" read -r path logical_kb real_kb; do
  filename=$(basename "$path")
  dirname=$(dirname "$path")

  sparse_dest="sparse/${filename%.*}__sparse.${filename##*.}"
  temp_clean="/tmp/$filename"

  # Copiar versión limpia a tmp
  cp -p "$path" "$temp_clean"

  # Renombrar original a sparse/
  mv "$path" "$sparse_dest"

  # Devolver archivo limpio a su ubicación original
  mv "$temp_clean" "$path"

  echo "✅ Limpieza restaurada:"
  echo "   - $path → limpio"
  echo "   - Original movido a: $sparse_dest"
  echo ""
done < "$tempfile"

rm "$tempfile"

# Mostrar tamaño con sparse incluido
size_with_sparse=$(du -sh . | cut -f1)
echo "📦 Tamaño actual de la carpeta (incluyendo 'sparse'): $size_with_sparse"

# Preguntar si se elimina la carpeta sparse
echo ""
read -p "¿Quieres eliminar la carpeta 'sparse'? (Y/N): " delete_sparse

if [[ "$delete_sparse" == "Y" || "$delete_sparse" == "y" ]]; then
  rm -rf sparse
  echo "🗑️  Carpeta 'sparse' eliminada."
else
  echo "📁 Carpeta 'sparse' conservada."
fi

# Mostrar tamaño final tras limpieza
size_final=$(du -sh . | cut -f1)
echo "✅ Tamaño final de la carpeta (después de limpiar 'sparse'): $size_final"
