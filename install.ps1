# Script de instalacion de 1 solo comando para Come Sano (Soporta repos privados con Token)
param(
    [string]$Repo = "",
    [string]$Token = ""
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "       INSTALADOR DE COME SANO          " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""

$installDir = "$env:LOCALAPPDATA\ComeSano"
$desktopExe = "$([Environment]::GetFolderPath('Desktop'))\AppComeSano.exe"
$tempZip = "$env:TEMP\ComeSano-bundle.zip"

# 1. Crear carpeta de instalacion
Write-Host "[1/4] Preparando carpeta en el sistema..." -ForegroundColor Cyan
New-Item -ItemType Directory -Force -Path $installDir | Out-Null

# 2. Descargar paquete
if ($Repo -and $Token) {
    Write-Host "[2/4] Descargando aplicacion desde repositorio privado..." -ForegroundColor Cyan
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $apiUrl = "https://api.github.com/repos/$Repo/contents/ComeSano-bundle.zip"
    $headers = @{
        "Authorization" = "Bearer $Token"
        "Accept"        = "application/vnd.github.v3.raw"
        "User-Agent"    = "PowerShell-Installer"
    }
    Invoke-WebRequest -Uri $apiUrl -Headers $headers -OutFile $tempZip -UseBasicParsing

    Write-Host "[3/4] Descomprimiendo archivos..." -ForegroundColor Cyan
    Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
    Remove-Item $tempZip -Force
} else {
    Write-Host "[2/4] Verificando archivos locales..." -ForegroundColor Yellow
    $localZip = Join-Path $PSScriptRoot "ComeSano-bundle.zip"
    if (Test-Path $localZip) {
        Expand-Archive -Path $localZip -DestinationPath $installDir -Force
    }
}

# 3. Colocar el ejecutable en el Escritorio
Write-Host "[4/4] Creando acceso en el Escritorio..." -ForegroundColor Cyan
if (Test-Path "$installDir\AppComeSano.exe") {
    Copy-Item -Path "$installDir\AppComeSano.exe" -Destination $desktopExe -Force
}

# 4. Iniciar la aplicacion de inmediato
if (Test-Path $desktopExe) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ¡Instalacion completada con exito!    " -ForegroundColor Green
    Write-Host "  Iniciando Come Sano en pantalla...    " -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Start-Process $desktopExe
} else {
    Write-Host "Error: No se encontro AppComeSano.exe en la instalacion." -ForegroundColor Red
}
