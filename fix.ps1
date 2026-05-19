Write-Host "=== INICIANDO REPARACIÓN DE WINGET ===" -ForegroundColor Cyan

# 1. Forzar el registro del paquete AppInstaller en el sistema
Write-Host "[1/3] Re-registrando el instalador de aplicaciones de Windows..." -ForegroundColor Yellow
$AppInstaller = Get-AppxPackage -AllUsers | Where-Object {$_.Name -like "*DesktopAppInstaller*"}
if ($AppInstaller) {
    Add-AppxPackage -RegisterByFamilyName -MainPackage $AppInstaller.PackageFamilyName -ErrorAction SilentlyContinue
}

# 2. Reparar y añadir las rutas del PATH de forma absoluta
Write-Host "[2/3] Reparando variables de entorno (PATH)..." -ForegroundColor Yellow
$UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
$WingetPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps"

if ($UserPath -notlike "*$WingetPath*") {
    [Environment]::SetEnvironmentVariable("Path", $UserPath + ";$WingetPath", "User")
    Write-Host "-> Ruta añadida con éxito al PATH de usuario." -ForegroundColor Green
} else {
    Write-Host "-> La ruta ya existía en el PATH." -ForegroundColor Gray
}

# 3. Actualizar la sesión actual de PowerShell para aplicar cambios inmediatamente
Write-Host "[3/3] Aplicando cambios en la sesión actual..." -ForegroundColor Yellow
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")

Write-Host "=== REPARACIÓN FINALIZADA ===" -ForegroundColor Cyan
Write-Host "Comprobando si winget responde ahora..." -ForegroundColor Gray
winget --version
