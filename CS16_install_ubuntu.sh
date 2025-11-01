#!/bin/bash
# ==============================================
# Instalador automático de Counter-Strike 1.6
# Método 1 adaptado de thelinuxcode.com
# ==============================================

echo "=============================================="
echo "   Instalador de Counter-Strike 1.6 para Linux"
echo "=============================================="
echo

# Verificar dependencias
echo "[*] Verificando dependencias..."
sudo apt update -y >/dev/null 2>&1
sudo apt install -y wget unzip wine >/dev/null 2>&1

# Ruta base donde se ejecuta el script
BASE_DIR="$(pwd)"

# Enlace de descarga
URL="https://dl.skachat-cs.su/nc/2.3.1/CS1.6_NextClient.zip"
ZIP_FILE="$BASE_DIR/CS1.6_NextClient.zip"

# Descargar con barra de progreso
echo "[*] Descargando instalador de Counter-Strike 1.6..."
wget --show-progress -O "$ZIP_FILE" "$URL"

# Verificar si la descarga fue exitosa
if [[ ! -f "$ZIP_FILE" ]]; then
    echo "[!] Error: no se pudo descargar el archivo."
    exit 1
fi

# Descomprimir el instalador
echo "[*] Descomprimiendo archivos..."
unzip -o "$ZIP_FILE" -d "$BASE_DIR" >/dev/null

# Eliminar el archivo ZIP después de extraerlo
rm -f "$ZIP_FILE"

# Cambiar permisos de carpetas y archivos
echo "[*] Ajustando permisos..."
chmod -R 755 "$BASE_DIR"
chown -R "$USER":"$USER" "$BASE_DIR"

# Buscar el instalador .exe
EXE_FILE=$(find "$BASE_DIR" -type f -iname "Cs16.exe" | head -n 1)

if [[ -z "$EXE_FILE" ]]; then
    echo "[!] No se encontró el archivo Cs16.exe en la carpeta."
    exit 1
fi

# Ejecutar el instalador con Wine
echo "[*] Iniciando instalador de Counter-Strike 1.6..."
wine "$EXE_FILE"

echo
echo "=============================================="
echo " Instalación completada o iniciada correctamente."
echo " Si es la primera vez, sigue las instrucciones del instalador."
echo "=============================================="
