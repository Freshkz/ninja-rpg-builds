# Publica una version nueva de NinjaRPG en este repo PRIVADO: comprime el build de Windows y lo sube como Release.
# Solo pueden bajarlo Fresh y quien este invitado al repo. No hacer publico este repo: el build lleva assets extraidos.
#
# Uso:  doble clic en publicar_juego.bat
#       o: powershell -ExecutionPolicy Bypass -File publicar_juego.ps1 [-Notas "que cambio"] [-Prueba] [-Build "ruta"]
#   -Prueba : solo arma el ZIP (no sube nada) para revisar que todo anda.
#   -Build  : carpeta del build (por defecto, ..\NinjaRPG\Builds\Windows).
#
# Requisitos: este repo clonado al lado de NinjaRPG y gh con sesion iniciada (gh auth login).

param(
    [string]$Notas = "",
    [switch]$Prueba,
    [string]$Build = ""
)

$ErrorActionPreference = "Stop"
$repo = "Freshkz/ninja-rpg-builds"
$juego = "NinjaRPG"
function Salir($msg) { Write-Host ""; Write-Host $msg -ForegroundColor Red; exit 1 }

# Corre gh y devuelve su codigo de salida. En PowerShell 5.1, con ErrorActionPreference = Stop, cualquier texto que gh
# escriba en stderr corta el script como si fuera un error: por eso se baja a Continue solo mientras corre gh.
function Invocar-GitHub {
    $antes = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try { & gh.exe @args 2>&1 | ForEach-Object { if ($_ -is [System.Management.Automation.ErrorRecord]) { $_.ToString() } else { $_ } } | Out-Host }
    finally { $ErrorActionPreference = $antes }
    return $LASTEXITCODE
}

function Invocar-GitHubSilencioso {
    $antes = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try { & gh.exe @args *> $null }
    finally { $ErrorActionPreference = $antes }
    return $LASTEXITCODE
}

# Lee un valor del repo con gh. Devuelve texto vacio si falla.
function Leer-GitHub {
    $antes = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try { return (& gh.exe @args 2>$null | Out-String).Trim() }
    finally { $ErrorActionPreference = $antes }
}

if ($Build) { $carpetaBuild = $Build } else { $carpetaBuild = Join-Path (Split-Path $PSScriptRoot -Parent) "$juego\Builds\Windows" }
$carpetaBuild = [System.IO.Path]::GetFullPath($carpetaBuild)
Write-Host "Juego: $carpetaBuild"

if (-not (Test-Path (Join-Path $carpetaBuild "$juego.exe"))) {
    Salir "No encontre el juego compilado en $carpetaBuild. Primero genera el build de Windows."
}

if (-not $Prueba) {
    if ((Invocar-GitHubSilencioso auth status) -ne 0) { Salir "GitHub no tiene sesion iniciada. Corre: gh auth login" }
    # El build lleva assets extraidos: si el repo dejo de ser privado, no se sube nada.
    $visibilidad = Leer-GitHub repo view $repo --json visibility --jq ".visibility"
    if ($visibilidad -ne "PRIVATE") { Salir "El repo $repo no es privado (visibilidad: '$visibilidad'). No se sube nada." }
}

# Version = fecha y hora del build (asi dos builds distintos nunca chocan).
$exe     = Get-Item (Join-Path $carpetaBuild "$juego.exe")
$datos   = Get-ChildItem (Join-Path $carpetaBuild "${juego}_Data") -Recurse -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
$fecha   = @($exe.LastWriteTime, $datos.LastWriteTime) | Sort-Object -Descending | Select-Object -First 1
$version = "v" + $fecha.ToString("yyyy.MM.dd-HHmm")
Write-Host "Version a publicar: $version (build del $($fecha.ToString('dd/MM/yyyy HH:mm')))" -ForegroundColor Yellow

if (-not $Prueba) {
    if ((Invocar-GitHubSilencioso release view $version --repo $repo) -eq 0) { Salir "La version $version ya esta publicada. Genera un build nuevo antes de volver a publicar." }
}

# Copia temporal sin las carpetas de depuracion (no se reparten) y ZIP con tar (rapido, sin limite de 2 GB).
$tmp = Join-Path $env:TEMP ("ninjarpg_publicar_" + [guid]::NewGuid().ToString("N").Substring(0, 8))
$carpeta = Join-Path $tmp $juego
$zip = Join-Path $tmp "$juego.zip"
try {
    Write-Host "Copiando el juego..."
    New-Item -ItemType Directory -Force $carpeta | Out-Null
    robocopy $carpetaBuild $carpeta /E /NFL /NDL /NJH /NJS /NP /XD "*_DoNotShip" "*_BackUpThisFolder_ButDontShipItWithYourGame" | Out-Null
    if ($LASTEXITCODE -ge 8) { Salir "Fallo la copia del juego (robocopy $LASTEXITCODE)." }
    Set-Content -Path (Join-Path $carpeta "VERSION.txt") -Value "$juego $version" -Encoding utf8

    Write-Host "Comprimiendo..."
    # El tar de Windows, con ruta completa: el de Git, si esta primero en el PATH, confunde "C:" con un servidor.
    & (Join-Path $env:SystemRoot "System32\tar.exe") -a -c -f $zip -C $tmp $juego
    if ($LASTEXITCODE -ne 0) { Salir "Fallo al comprimir." }
    $mb = [math]::Round((Get-Item $zip).Length / 1MB, 1)
    Write-Host "ZIP listo: $mb MB"
    if ($mb -gt 1990) { Salir "El ZIP pasa los 2 GB que permite GitHub por archivo." }

    if ($Prueba) {
        $destino = Join-Path ([Environment]::GetFolderPath("Desktop")) "${juego}_prueba.zip"
        Move-Item $zip $destino -Force
        Write-Host ""; Write-Host "Prueba OK (no se subio nada): $destino" -ForegroundColor Green
        exit 0
    }

    if (-not $Notas) { $Notas = "Build del $($fecha.ToString('dd/MM/yyyy HH:mm')). Descomprimi el ZIP y abri $juego.exe. Los dos jugadores tienen que usar la misma version." }
    Write-Host "Subiendo a GitHub (puede tardar unos minutos)..."
    if ((Invocar-GitHub release create $version $zip --repo $repo --title "$juego $version" --notes $Notas --latest) -ne 0) { Salir "Fallo la subida a GitHub." }

    Write-Host ""
    Write-Host "Publicado $version ($mb MB)." -ForegroundColor Green
    Write-Host "Link para bajarlo: https://github.com/$repo/releases/latest"
}
finally {
    if (Test-Path $tmp) { Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue }
}
