# Script para descargar dependencias locales necesarias para el APK offline
# Ejecutar: powershell -ExecutionPolicy Bypass -File descargar_libs.ps1

Write-Host "Descargando dependencias offline para UCV Academic Master..." -ForegroundColor Cyan

# Crear carpeta libs si no existe
New-Item -ItemType Directory -Force -Path ".\libs" | Out-Null
New-Item -ItemType Directory -Force -Path ".\icons" | Out-Null

$urls = @{
    ".\libs\tailwind.min.css"    = "https://cdn.tailwindcss.com"
    ".\libs\chart.min.js"        = "https://cdn.jsdelivr.net/npm/chart.js/dist/chart.umd.min.js"
    ".\libs\fontawesome.min.css" = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css"
}

foreach ($dest in $urls.Keys) {
    $url = $urls[$dest]
    Write-Host "Descargando $dest ..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "  OK: $dest" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: $dest - $_" -ForegroundColor Red
    }
}

# Descargar webfonts de Font Awesome
Write-Host "Descargando webfonts de Font Awesome..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path ".\libs\webfonts" | Out-Null

$faFonts = @(
    "fa-solid-900.woff2",
    "fa-regular-400.woff2",
    "fa-brands-400.woff2"
)
$faBase = "https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/webfonts/"
foreach ($font in $faFonts) {
    try {
        Invoke-WebRequest -Uri "$faBase$font" -OutFile ".\libs\webfonts\$font" -UseBasicParsing
        Write-Host "  OK: webfonts/$font" -ForegroundColor Green
    } catch {
        Write-Host "  ERROR: webfonts/$font - $_" -ForegroundColor Red
    }
}

# Arreglar rutas de webfonts en el CSS descargado
Write-Host "Corrigiendo rutas en fontawesome.min.css..." -ForegroundColor Yellow
$css = Get-Content ".\libs\fontawesome.min.css" -Raw
$css = $css -replace '\.\.\/webfonts\/', 'webfonts/'
$css = $css -replace '\.\/webfonts\/', 'webfonts/'
Set-Content ".\libs\fontawesome.min.css" $css
Write-Host "  OK: rutas de webfonts corregidas" -ForegroundColor Green

# Descargar icono de placeholder para la app
Write-Host "Descargando icono de la app..." -ForegroundColor Yellow
try {
    Invoke-WebRequest -Uri "https://cdn-icons-png.flaticon.com/512/2845/2845722.png" -OutFile ".\icons\icon-512.png" -UseBasicParsing
    Invoke-WebRequest -Uri "https://cdn-icons-png.flaticon.com/192/2845/2845722.png" -OutFile ".\icons\icon-192.png" -UseBasicParsing
    Write-Host "  OK: iconos descargados" -ForegroundColor Green
} catch {
    Write-Host "  ERROR descargando iconos: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "Listo! Estructura generada:" -ForegroundColor Cyan
Get-ChildItem -Recurse .\libs | Select-Object FullName
Write-Host ""
Write-Host "Ahora puedes copiar todo a Android Studio en assets/www/" -ForegroundColor Cyan
