<#
.SYNOPSIS
    Gestión del ciclo de vida y ahorro de créditos del SOC Lab en AWS.
.EXAMPLE
    .\manage_lab.ps1 status
    .\manage_lab.ps1 stop
    .\manage_lab.ps1 start
#>
param (
    [Parameter(Position=0, Mandatory=$false)]
    [ValidateSet("status", "stop", "start")]
    [string]$Action = "status"
)

$Region = "us-east-1"
$TagKey = "Environment"
$TagVal = "Cybersecurity-Lab"

function Get-LabInstances {
    $json = aws ec2 describe-instances --region $Region --filters "Name=tag:$TagKey,Values=$TagVal" --output json | ConvertFrom-Json
    $list = @()
    if ($json.Reservations) {
        foreach ($res in $json.Reservations) {
            foreach ($inst in $res.Instances) {
                $nameTag = ($inst.Tags | Where-Object { $_.Key -eq "Name" }).Value
                $list += [PSCustomObject]@{
                    Id       = $inst.InstanceId
                    Name     = if ($nameTag) { $nameTag } else { "Unknown" }
                    State    = $inst.State.Name
                    PublicIp = if ($inst.PublicIpAddress) { $inst.PublicIpAddress } else { "N/A" }
                    PrivIp   = if ($inst.PrivateIpAddress) { $inst.PrivateIpAddress } else { "N/A" }
                    Type     = $inst.InstanceType
                }
            }
        }
    }
    return $list
}

switch ($Action) {
    "status" {
        $instances = Get-LabInstances
        Write-Host "`n======================================================================" -ForegroundColor Cyan
        Write-Host "      ESTADO ACTUAL DE LAS INSTANCIAS DEL LABORATORIO SOC EN AWS" -ForegroundColor Cyan
        Write-Host "======================================================================" -ForegroundColor Cyan
        foreach ($i in $instances) {
            $color = if ($i.State -eq "running") { "Green" } elseif ($i.State -eq "stopped") { "Red" } else { "Yellow" }
            Write-Host "• [$($i.State.ToUpper())] " -NoNewline -ForegroundColor $color
            Write-Host "$($i.Name) ($($i.Id)) - Tipo: $($i.Type)"
            Write-Host "    IP Publica: $($i.PublicIp)  |  IP Privada: $($i.PrivIp)" -ForegroundColor Gray
        }
        Write-Host "======================================================================`n" -ForegroundColor Cyan
    }
    "stop" {
        $instances = Get-LabInstances
        $running = $instances | Where-Object { $_.State -eq "running" }
        if (-not $running) {
            Write-Host "[!] No hay instancias en ejecución para detener." -ForegroundColor Yellow
            return
        }
        $ids = $running.Id
        Write-Host "[*] Deteniendo $($ids.Count) instancias para pausar consumo de cómputo..." -ForegroundColor Yellow
        aws ec2 stop-instances --region $Region --instance-ids $ids | Out-Null
        Write-Host "[+] Instancias detenidas correctamente. Créditos salvados ($0.00 cómputo)." -ForegroundColor Green
    }
    "start" {
        $instances = Get-LabInstances
        $stopped = $instances | Where-Object { $_.State -eq "stopped" }
        if (-not $stopped) {
            Write-Host "[!] No hay instancias apagadas para iniciar." -ForegroundColor Yellow
            return
        }
        $ids = $stopped.Id
        Write-Host "[*] Encendiendo $($ids.Count) instancias del laboratorio..." -ForegroundColor Cyan
        aws ec2 start-instances --region $Region --instance-ids $ids | Out-Null
        Write-Host "[+] Instancias encendiéndose. Espera 60s y ejecuta: .\manage_lab.ps1 status" -ForegroundColor Green
    }
}
