#!/bin/bash
# ==============================================================================
# Script de preparación para T-Pot Community Edition en Debian 12 (Bookworm)
# Configura 8GB de memoria Swap y clona la versión estable 24.04.1
# ==============================================================================

set -e

echo "[*] 1. Creando archivo Swap de 8 GB para prevenir saturación de RAM..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    sudo sysctl vm.swappiness=20
    echo "[+] Swap de 8 GB creado y activado exitosamente."
else
    echo "[i] El archivo Swap ya existe. Omitiendo creación."
fi

echo "[*] 2. Instalando dependencias básicas del sistema..."
sudo apt-get update && sudo apt-get install -y git curl sudo ca-certificates procps

echo "[*] 3. Descargando T-Pot Community Edition..."
if [ ! -d /opt/tpot ]; then
    sudo mkdir -p /opt/tpot
    sudo git clone https://github.com/telekom-security/tpotce.git /opt/tpot
fi

cd /opt/tpot
echo "[*] 4. Fijando la versión estable compatible con Debian 12 (etiqueta 24.04.1)..."
sudo git checkout 24.04.1

echo ""
echo "=============================================================================="
echo " [!] PREPARACIÓN COMPLETADA CON ÉXITO"
echo " Para iniciar la instalación de T-Pot ejecuta:"
echo "   cd /opt/tpot && sudo ./install.sh"
echo "=============================================================================="
