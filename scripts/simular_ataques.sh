#!/bin/bash
# ==============================================================================
# Script de Simulación de Ataques para Validación de Detección en Wazuh SIEM
# Ejecutar en el servidor víctima (SOC-Ubuntu-Victim-SRV01)
# ==============================================================================

echo "=============================================================================="
echo "      SIMULADOR DE EVENTOS DE SEGURIDAD - MITRE ATT&CK PARA WAZUH SIEM"
echo "=============================================================================="

# 1. Simulación de Inyección SQL contra el servidor web (T1190)
echo "[*] 1. Simulando intento de Inyeccion SQL (MITRE T1190)..."
curl -s "http://localhost/?id=1'%20UNION%20SELECT%20null,version()--" > /dev/null
curl -s "http://localhost/index.php?search=<script>alert('XSS')</script>" > /dev/null
echo "[+] Peticiones HTTP maliciosas enviadas a Apache."

# 2. Modificación de Integridad de Archivos Críticos - FIM (T1565 / T1562)
echo "[*] 2. Simulando creación de backdoor y modificación FIM (MITRE T1565)..."
sudo touch /etc/cron.d/malicious_cron_job
sudo touch /etc/wazuh_backdoor_test.conf
echo "backdoor_active=true" | sudo tee -a /etc/wazuh_backdoor_test.conf > /dev/null
echo "[+] Archivos sospechosos creados en /etc."

# 3. Simulación de Escaneo y Reconocimiento Local (T1082 / T1087)
echo "[*] 3. Simulando comandos de reconocimiento interno del sistema..."
cat /etc/passwd | head -n 5 > /dev/null
uname -a > /dev/null

echo ""
echo "=============================================================================="
echo "[+] Simulación completada."
echo "Ve a tu consola Web de Wazuh > Security Events y revisa las alertas generadas."
echo "=============================================================================="
