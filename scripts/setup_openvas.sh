#!/bin/bash
# ==============================================================================
# Script de Instalación Automatizada de OpenVAS / Greenbone Community Edition
# Ejecutar en la instancia SOC-OpenVAS-Scanner (Ubuntu 22.04 LTS)
# ==============================================================================

set -e

echo "=============================================================================="
echo "    INSTALADOR DE OPENVAS / GREENBONE COMMUNITY EDITION (DOCKER STACK)"
echo "=============================================================================="

# 1. Configurar Swap de 4 GB para optimizar indexación de feeds de vulnerabilidades
echo "[*] 1. Configurando 4 GB de memoria Swap..."
if [ ! -f /swapfile ]; then
    sudo fallocate -l 4G /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=4096
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
    echo "[+] Swap de 4 GB configurado."
else
    echo "[i] Swap ya configurado."
fi

# 2. Instalar Docker y dependencias
echo "[*] 2. Instalando Docker Engine y utilitarios..."
sudo apt-get update && sudo apt-get install -y docker.io docker-compose curl sed
sudo systemctl enable --now docker

# 3. Preparar directorio oficial de Greenbone
echo "[*] 3. Descargando stack oficial de Greenbone Community..."
sudo mkdir -p /opt/greenbone-community-container
cd /opt/greenbone-community-container

sudo curl -f -L https://greenbone.github.io/docs/latest/_static/compose.yaml -o compose.yaml

# 4. Exponer los puertos HTTPS 443 y 9392 hacia el exterior
echo "[*] 4. Configurando puertos de acceso web (443 y 9392)..."
sudo sed -i 's/127.0.0.1:9392:9392/0.0.0.0:9392:9392/g' compose.yaml
sudo sed -i 's/127.0.0.1:443:443/0.0.0.0:443:443/g' compose.yaml

# 5. Iniciar los contenedores
echo "[*] 5. Descargando imagenes e iniciando contenedores en segundo plano..."
sudo docker compose -f compose.yaml -p greenbone-community-edition up -d

echo ""
echo "=============================================================================="
echo " [!] OPENVAS DESPLEGADO EXITOSAMENTE"
echo " Los contenedores estan sincronizando las bases de datos de CVEs (SCAP/NVT)."
echo " Para definir la contrasena de administrador 'admin', ejecuta:"
echo "   sudo docker exec -u gvmd greenbone-community-edition-gvmd-1 gvmd --user=admin --new-password='TuPasswordSegura'"
echo " Accede por navegador a: https://<IP_PUBLICA_OPENVAS>"
echo "=============================================================================="
