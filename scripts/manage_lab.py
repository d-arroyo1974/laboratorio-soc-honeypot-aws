#!/usr/bin/env python3
"""
Script de Gestión de Costos y Ciclo de Vida del Laboratorio SOC en AWS.
Permite apagar o encender todas las instancias con un solo comando para ahorrar créditos.
"""

import sys
import subprocess
import json

REGION = "us-east-1"
TAG_KEY = "Environment"
TAG_VAL = "Cybersecurity-Lab"

def run_aws(cmd):
    full_cmd = f"aws {cmd} --region {REGION} --output json"
    res = subprocess.run(full_cmd, shell=True, capture_output=True, text=True)
    if res.returncode != 0:
        print(f"[ERROR] {res.stderr.strip()}")
        return None
    try:
        return json.loads(res.stdout) if res.stdout.strip() else {}
    except Exception:
        return res.stdout.strip()

def get_lab_instances():
    cmd = f'ec2 describe-instances --filters "Name=tag:{TAG_KEY},Values={TAG_VAL}"'
    data = run_aws(cmd)
    instances = []
    if not data or "Reservations" not in data:
        return instances
    for res in data["Reservations"]:
        for inst in res["Instances"]:
            name = "Unknown"
            for t in inst.get("Tags", []):
                if t["Key"] == "Name":
                    name = t["Value"]
            instances.append({
                "id": inst["InstanceId"],
                "name": name,
                "state": inst["State"]["Name"],
                "public_ip": inst.get("PublicIpAddress", "N/A"),
                "private_ip": inst.get("PrivateIpAddress", "N/A"),
                "type": inst["InstanceType"]
            })
    return instances

def show_status():
    instances = get_lab_instances()
    print("\n" + "="*70)
    print("      ESTADO ACTUAL DE LAS INSTANCIAS DEL LABORATORIO SOC")
    print("="*70)
    if not instances:
        print("[-] No se encontraron instancias con el tag 'Environment: Cybersecurity-Lab'.")
        return
    for i in instances:
        state_icon = "[RUNNING]" if i['state'] == 'running' else "[STOPPED]" if i['state'] == 'stopped' else f"[{i['state'].upper()}]"
        print(f"* {state_icon:<10} {i['name']:<25} ({i['id']})")
        print(f"    Tipo: {i['type']:<15} IP Publica: {i['public_ip']:<16} IP Privada: {i['private_ip']}")
    print("="*70 + "\n")

def stop_all():
    instances = get_lab_instances()
    running_ids = [i["id"] for i in instances if i["state"] == "running"]
    if not running_ids:
        print("[!] No hay instancias encendidas actualmente.")
        return
    print(f"[*] Deteniendo {len(running_ids)} instancias para pausar el consumo de creditos...")
    ids_str = " ".join(running_ids)
    run_aws(f"ec2 stop-instances --instance-ids {ids_str}")
    print("[+] Comando enviado exitosamente. Las instancias se estan apagando.")
    print("[TIP] El costo de computo pasa a $0.00 mientras esten detenidas.")

def start_all():
    instances = get_lab_instances()
    stopped_ids = [i["id"] for i in instances if i["state"] == "stopped"]
    if not stopped_ids:
        print("[!] No hay instancias detenidas para iniciar.")
        return
    print(f"[*] Encendiendo {len(stopped_ids)} instancias del laboratorio...")
    ids_str = " ".join(stopped_ids)
    run_aws(f"ec2 start-instances --instance-ids {ids_str}")
    print("[+] Instancias iniciando. Espera 60 segundos y ejecuta 'status' para ver las nuevas IPs.")

def main():
    if len(sys.argv) < 2:
        print("\nUso del script de control:")
        print("  python manage_lab.py status  -> Ver estado de todas las máquinas")
        print("  python manage_lab.py stop    -> Apagar todas las máquinas (Ahorrar créditos)")
        print("  python manage_lab.py start   -> Encender todas las máquinas para clases/labs\n")
        sys.exit(1)

    action = sys.argv[1].lower()
    if action == "status":
        show_status()
    elif action == "stop":
        stop_all()
    elif action == "start":
        start_all()
    else:
        print(f"[!] Accion no valida: {action}. Usa status, stop o start.")

if __name__ == "__main__":
    main()
