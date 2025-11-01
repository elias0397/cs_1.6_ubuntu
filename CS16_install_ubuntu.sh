#!/usr/bin/env bash
# ==============================================================
# Script de instalación de Counter-Strike 1.6 en Ubuntu (Método 1)
# Autor: Elias Araujo
# Basado en el instructivo de TheLinuxCode
# Versión: Instalador local (Cs16.exe en misma carpeta)
# Uso: sudo ./install_cs_method1.sh
# ==============================================================

set -euo pipefail

# --- CONFIGURACIÓN ---
INSTALLER_NAME="Cs16.exe"
INSTALLER_PATH="$(dirname "$(realpath "$0")")/$INSTALLER_NAME"
WINEPREFIX_HOME="$HOME/.wine_cs"
WINEARCH="win32"
DEBIAN_FRONTEND=noninteractive

# --- VERIFICACIONES ---
if [[ $EUID -ne 0 ]]; then
  echo "❌ Este script requiere permisos de superusuario (sudo)."
  echo "Ejecuta: sudo ./install_cs_method1.sh"
  exit 1
fi

if [[ ! -f "$INSTALLER_PATH" ]]; then
  echo "❌ No se encontró el instalador '$INSTALLER_NAME' en la misma carpeta."
  echo "Asegúrate de que esté junto al script en: $(dirname "$(realpath "$0")")/"
  exit 2
fi

echo ">>> Actualizando repositorios..."
apt update -y

echo ">>> Habilitando arquitectura i386 (necesaria para Wine 32-bit)..."
dpkg --add-architecture i386 || true
apt update -y

echo ">>> Instalando Wine y Winetricks..."
apt install -y wine winetricks

# --- CREAR PREFIJO ---
echo ">>> Creando prefijo Wine aislado en: $WINEPREFIX_HOME"
export WINEPREFIX="$WINEPREFIX_HOME"
export WINEARCH="$WINEARCH"

if [[ -d "$WINEPREFIX" ]]; then
  echo "⚠️  Se detectó un prefijo existente. Se renombrará como copia de seguridad."
  mv "$WINEPREFIX" "${WINEPREFIX}_backup_$(date +%Y%m%d%H%M%S)"
fi

sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" WINEARCH="$WINEARCH" wineboot >/dev/null 2>&1 || true

echo ">>> Instalando fuentes y librerías básicas con Winetricks..."
sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" winetricks -q corefonts vcrun6 || true

# --- COPIAR E INSTALAR ---
echo ">>> Copiando instalador Cs16.exe al prefijo..."
cp "$INSTALLER_PATH" "$WINEPREFIX/drive_c/"

echo ">>> Ejecutando instalador..."
sudo -u "$SUDO_USER" env WINEPREFIX="$WINEPREFIX" wine "$WINEPREFIX/drive_c/$INSTALLER_NAME"

# --- FINALIZACIÓN ---
echo
echo "✅ Instalación iniciada correctamente."
echo "Cuando termine el asistente, podrás ejecutar el juego con:"
echo "  env WINEPREFIX=\"$WINEPREFIX\" wine \"\$WINEPREFIX/drive_c/Program Files/Counter-Strike/hl.exe\""
echo
echo "🎮 ¡Disfruta de Counter-Strike 1.6 en Ubuntu!"
