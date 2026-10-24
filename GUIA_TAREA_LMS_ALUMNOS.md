# 🛡️ Guía de Tarea Práctica para Publicar en el LMS: Despliegue de Honeypot T-Pot, Auditoría con OpenVAS y Dashboard de Threat Intel en Wazuh

* **Módulo / Asignatura:** Ciberseguridad Defensiva, Operaciones SOC & Deception Technologies  
* **Modalidad:** Individual o en Parejas  
* **Repositorio Oficial de la Asignatura:** [https://github.com/d-arroyo1974/laboratorio-soc-honeypot-aws](https://github.com/d-arroyo1974/laboratorio-soc-honeypot-aws)  
* **Plazo de Entrega:** [Fecha y Hora Límite en el LMS]  

---

## 🎯 1. Objetivos del Laboratorio

1. **Tecnologías de Decepción (Honeypot):** Desplegar y configurar de forma operativa la plataforma multi-señuelo **T-Pot Community Edition** en Debian 12, verificando el funcionamiento de trampas como Cowrie, Dionaea y Suricata NIDS.
2. **Gestión de Vulnerabilidades (Vulnerability Assessment):** Configurar y ejecutar una tarea de auditoría con **OpenVAS / Greenbone** contra el servidor Linux víctima (`SOC-Ubuntu-Victim-SRV01`) a través de la red privada de la VPC.
3. **Monitoreo y Threat Intelligence (SIEM):** Correlacionar los eventos de ataque capturados en el Honeypot y construir un **Dashboard interactivo en Wazuh SIEM** para el análisis de amenazas en tiempo real.

---

## 📚 2. Repositorio de la Clase y Preparación de la Infraestructura

Antes de comenzar las tareas, deben ingresar al repositorio oficial creado para ustedes:  
🔗 **[github.com/d-arroyo1974/laboratorio-soc-honeypot-aws](https://github.com/d-arroyo1974/laboratorio-soc-honeypot-aws)**

En el archivo `README.md` encontrarán los pasos para crear en AWS la VPC (`10.100.0.0/16`), subredes, grupos de seguridad y lanzar las 4 instancias EC2 (`SOC-T-Pot-Honeypot`, `SOC-Wazuh-SIEM`, `SOC-OpenVAS-Scanner` y `SOC-Ubuntu-Victim-SRV01`).

---

## 🍯 3. Tarea 1: Despliegue y Configuración del Honeypot T-Pot (Evaluada)

El honeypot requiere configuraciones de sistema obligatorias para no colapsar por memoria RAM y operar sobre Debian 12:

1. **Configuración de Memoria Swap de 8 GB (Obligatorio):**
   * Conéctate por SSH a la máquina `SOC-T-Pot-Honeypot` (usuario `admin`, puerto 22 inicial).
   * Crea y activa el archivo Swap de 8 GB:
     ```bash
     sudo fallocate -l 8G /swapfile
     sudo chmod 600 /swapfile
     sudo mkswap /swapfile
     sudo swapon /swapfile
     echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
     sudo sysctl vm.swappiness=20
     ```

2. **Fijación de Versión Estable y Asistente de Instalación:**
   * Ve a `/opt/tpot`, descarga el repositorio y cambia a la rama estable:
     ```bash
     cd /opt/tpot
     sudo git checkout 24.04.1
     sudo ./install.sh
     ```
   * En el asistente:
     * Selecciona el perfil **`STANDARD`**.
     * Define un usuario administrativo web (ej: `admin`) y su contraseña.
     * Al finalizar la instalación, autoriza el reinicio del servidor (**`y`**).

3. **Verificación de Contenedores y Señuelos:**
   * Una vez reiniciado, conéctate al SSH real de administración por el **puerto 64295**:
     ```bash
     ssh -p 64295 admin@<IP_PUBLICA_HONEYPOT>
     ```
   * Ejecuta el comando de diagnóstico oficial de T-Pot para verificar el estado de los contenedores de señuelos:
     ```bash
     sudo dps.sh
     ```
   * Abre en tu navegador el portal web de T-Pot:  
     👉 **`https://<IP_PUBLICA_HONEYPOT>:64297`** e inicia sesión en la consola.

---

## 🔍 4. Tarea 2: Auditoría de Vulnerabilidades con OpenVAS (Evaluada)

Realizar un escaneo de seguridad a través de la red interna de la VPC contra el servidor víctima:

1. **Creación del Target:**
   * En la consola de OpenVAS (`https://<IP_PUBLICA_OPENVAS>`), ve a **Configuration** > **Targets** > **New Target**.
   * **Name:** `Target-Linux-Apache-SRV01`
   * **Hosts:** Ingresa la **IP PRIVADA** de la máquina víctima (ejemplo: `10.100.20.190` o `10.100.20.x`).
   * **Port List:** Selecciona `All IANA assigned TCP` o `OpenVAS Default`.

2. **Creación y Ejecución del Scan:**
   * Ve a **Scans** > **Tasks** > **New Task**.
   * **Name:** `Auditoria de Vulnerabilidades - Servidor Apache Linux`
   * **Scan Targets:** Selecciona `Target-Linux-Apache-SRV01`.
   * **Scan Config:** Selecciona **`Full and fast`**.
   * Inicia el escaneo presionando el botón verde **Start ▶️**.

3. **Reporte Final:**
   * Espera a que el escaneo llegue al estado **`Done (100%)`**.
   * Haz clic sobre la fecha de la ejecución para abrir los resultados y descarga el reporte en formato **PDF**.

---

## 📊 5. Tarea 3: Construcción del Dashboard en Wazuh SIEM (Evaluada)

En la consola de Wazuh (`https://<IP_PUBLICA_WAZUH>`), ve a **OpenSearch Dashboards / Visualize** y ensambla un Dashboard interactivo titulado exactamente:  
👉 **`T-Pot Honeypot - Live Threat Intel`**

El Dashboard debe contener los siguientes **5 componentes**:

| Título del Panel | Tipo de Gráfico | Configuración / Agregación |
| :--- | :--- | :--- |
| **Mapa Mundial de Amenazas - T-Pot** | `Coordinate Map` | **Geohash** sobre el campo `data.geoip.location` o `GeoLocation.location`. |
| **Top 10 IPs Atacantes - Honeypot** | `Horizontal Bar` | **Eje X:** Count \| **Split Series (Eje Y):** Terms en `data.src_ip` (Size: 10). |
| **Top 10 Países Atacantes - Honeypot** | `Pie` (Circular) | **Count** \| **Split Slices:** Terms en `data.geoip.country_name` (Size: 10). |
| **Top Puertos Atacados - Honeypot** | `Pie` (Circular) | **Count** \| **Split Slices:** Terms en `data.dest_port` (Size: 10). |
| **T-Pot Honeypot - Live Threat Intel** | `Saved Search` (Tabla) | Tabla de eventos en vivo con **6 columnas obligatorias en orden**: <br>`Time`, `data.src_ip`, `data.src_port`, `data.dest_port`, `data.alert.signature`, `rule.id`. |

---

## 📤 6. Entregables para el LMS

Deberán subir a la plataforma LMS un único archivo comprimido `.zip` o documento `.pdf` con:

1. **Evidencia del Honeypot T-Pot (Tarea 1):**
   * Captura de pantalla de la terminal ejecutando el comando `sudo dps.sh` mostrando los contenedores (*Cowrie, Dionaea, Suricata, Elastic, Kibana*) en estado **`UP`**.
   * Captura de pantalla del portal web de T-Pot (`https://<IP>:64297`) logueado con éxito.
2. **Evidencia de OpenVAS (Tarea 2):**
   * Captura de pantalla de la tarea de escaneo finalizada al **100% (Done)** apuntando a la IP privada de la víctima.
   * Archivo de reporte de vulnerabilidades descargado en formato **PDF**.
   * Análisis breve (1 párrafo) de los principales hallazgos o debilidades encontradas en Apache.
3. **Evidencia de Wazuh SIEM (Tarea 3):**
   * Captura de pantalla completa del Dashboard **`T-Pot Honeypot - Live Threat Intel`** con los 5 componentes cargados con datos reales.
   * Archivo de exportación del dashboard en formato `.ndjson` o `.json` (*Stack Management > Saved Objects*).
   * Análisis breve (1 párrafo) de las amenazas capturadas (IP atacante principal, país y firma de ataque detectada).

---

## 📋 7. Rúbrica de Calificación

| Criterio de Evaluación | Puntaje Máximo | Descripción del Desempeño Esperado |
| :--- | :---: | :--- |
| **Configuración y Validación de T-Pot (Honeypot)** | **25 pts** | Creación correcta del Swap de 8 GB, checkout a la versión 24.04.1, conexión por puerto 64295 y evidencia de contenedores activos con `sudo dps.sh` y acceso web. |
| **Auditoría de Vulnerabilidades con OpenVAS** | **25 pts** | Configuración adecuada del Target con la IP privada de la víctima, tarea ejecutada con éxito al 100% y adjunto del reporte PDF generado. |
| **Construcción de Visualizaciones en Wazuh (4 Paneles)** | **25 pts** | Mapa de Coordenadas, Barras Horizontales y Gráficos de Torta construidos con los tipos, métricas y agregaciones exactas solicitadas. |
| **Tabla de Telemetría en Vivo (6 Columnas)** | **15 pts** | Tabla integrada en el Dashboard respetando el orden estricto de columnas (`Time`, `src_ip`, `src_port`, `dest_port`, `signature`, `rule.id`). |
| **Análisis de Hallazgos y Amenazas** | **10 pts** | Interpretación técnica coherente de los hallazgos de OpenVAS y de las alertas reales de atacantes registradas en el Honeypot. |
| **Total** | **100 pts** | |
