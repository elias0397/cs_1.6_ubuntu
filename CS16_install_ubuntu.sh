#!/usr/bin/env bash
# ==============================================================
# Instalador automático de Counter-Strike 1.6 (Método 1 - Wine)
# Autor: Elias Araujo
# Descarga, descomprime y ejecuta el instalador desde Wine.
# ==============================================================

set -euo pipefail

# --- CONFIGURACIÓN ---
DOWNLOAD_URL="https://dl.skachat-cs.su/nc/2.3.1/CS1.6_NextClient.zip"
ZIP_NAME="CS1.6_NextClient.zip"
WORK_DIR="$(dirname "$(realpath "$0")")"
EXTRACT_DIR="$WORK_DIR/CS16_NextClient"
INSTALLER_NAME="Cs16.exe"
WINEPREFIX_HOME="$HOME/.wine_cs"
WINEARCH="win32"
DEBIAN_FRONTEND=noninteractive

# --- VERIFICACIONES ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ Este script requiere permisos de superusuario (sudo)."
  echo "Ejecuta: sudo ./install_cs_method1.sh"
  exit 1
fi

echo ">>> Actualizando repositorios..."
apt update -y

echo ">>> Habilitando arquitectura i386..."
dpkg --add-architecture i386 || true
apt update -y

echo ">>> Instalando dependencias: Wine, Winetricks, wget y unzip..."
apt install -y wine winetricks wget unzip

# --- DESCARGA ---
cd "$WORK_DIR"
echo ">>> Descargando instalador de Counter-Strike 1.6..."
echo "URL: $DOWNLOAD_URL"
echo
echo "📦 Descargando, por favor espera..."
wget --progress=dot:mega -O "$ZIP_NAME" "$DOWNLOAD_URL"

if [[ ! -f "$ZIP_NAME" ]]; then
  echo "❌ Error: el archivo no se descargó correctamente."
  exit 2
fi

echo "✅ Descarga completada: $ZIP_NAME"

# --- DESCOMPRESIÓN ---
echo ">>> Descomprimiendo contenido..."
rm -rf "$EXTRACT_DIR"
mkdir -p "$EXTRACT_DIR"
unzip -q "$ZIP_NAME" -d "$EXTRACT_DIR"

if [[ ! -f "$EXTRACT_DIR/$INSTALLER_NAME" ]]; then
  echo "❌ No se encontró $INSTALLER_NAME dentro del ZIP."
  echo "Verifica que la URL y el contenido sean correctos."
  exit 3
fi

# --- CONFIGURAR WINE ---
echo ">>> Configurando Wine en prefijo: $WINEPREFIX_HOME"
export WINEPREFIX="$WINEPREFIX_HOME"
export WINEARCH="$WINEARCH"

if [[ -d "$WINEPREFIX" ]]; then
  echo "⚠️  Prefijo existente detectado. Se renombrará como copia de seguridad."
  mv "$WINEPREFIX" "${WINEPREFIX}_backup_$(date +%Y%m%d%H%M%S)"
fi

sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" WINEARCH="$WINEARCH" wineboot >/dev/null 2>&1 || true

echo ">>> Instalando fuentes y librerías básicas con Winetricks..."
sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" winetricks -q corefonts vcrun6 || true

# --- EJECUTAR INSTALADOR ---
echo ">>> Ejecutando instalador con Wine..."
sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" wine "$EXTRACT_DIR/$INSTALLER_NAME"

# --- FINAL ---
echo
echo "✅ Instalación iniciada correctamente."
echo "Cuando finalice, podrás ejecutar el juego con:"
echo "  env WINEPREFIX=\"$WINEPREFIX\" wine \"\$WINEPREFIX/drive_c/Program Files/Counter-Strike/hl.exe\""
echo
echo "🎮 ¡Disfruta de Counter-Strike 1.6 en Ubuntu!"
