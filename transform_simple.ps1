# Script simplificado de transformacion a Diego's Burger
$ErrorActionPreference = "Stop"
$sourceDir = "C:\Users\akabr\DiegosBurger"

Write-Host "==========================================`n" -ForegroundColor Cyan
Write-Host "Transformando a Diego's Burger`n" -ForegroundColor Cyan
Write-Host "==========================================`n" -ForegroundColor Cyan

# 1. Renombrar carpeta restaurante a diegosburger
Write-Host "[1/7] Renombrando carpeta principal..." -ForegroundColor Yellow
$oldDir = Join-Path $sourceDir "restaurante"
$newDir = Join-Path $sourceDir "diegosburger"
if (Test-Path $oldDir) {
    Rename-Item -Path $oldDir -NewName "diegosburger" -Force
    Write-Host "  OK - Carpeta renombrada`n" -ForegroundColor Green
}

# 2. Modificar settings.py
Write-Host "[2/7] Modificando settings.py..." -ForegroundColor Yellow
$settingsFile = Join-Path $sourceDir "diegosburger\settings.py"
if (Test-Path $settingsFile) {
    (Get-Content $settingsFile -Raw) -replace 'restaurante','diegosburger' | Set-Content $settingsFile -Encoding UTF8
    Write-Host "  OK - settings.py actualizado`n" -ForegroundColor Green
}

# 3. Modificar manage.py
Write-Host "[3/7] Modificando manage.py..." -ForegroundColor Yellow
$manageFile = Join-Path $sourceDir "manage.py"
if (Test-Path $manageFile) {
    (Get-Content $manageFile -Raw) -replace 'restaurante','diegosburger' | Set-Content $manageFile -Encoding UTF8
    Write-Host "  OK - manage.py actualizado`n" -ForegroundColor Green
}

# 4. Modificar wsgi.py y asgi.py
Write-Host "[4/7] Modificando wsgi.py y asgi.py..." -ForegroundColor Yellow
$wsgiFile = Join-Path $sourceDir "diegosburger\wsgi.py"
$asgiFile = Join-Path $sourceDir "diegosburger\asgi.py"
if (Test-Path $wsgiFile) {
    (Get-Content $wsgiFile -Raw) -replace 'restaurante','diegosburger' | Set-Content $wsgiFile -Encoding UTF8
}
if (Test-Path $asgiFile) {
    (Get-Content $asgiFile -Raw) -replace 'restaurante','diegosburger' | Set-Content $asgiFile -Encoding UTF8
}
Write-Host "  OK - Archivos WSGI/ASGI actualizados`n" -ForegroundColor Green

# 5. Crear CSS personalizado
Write-Host "[5/7] Creando CSS personalizado..." -ForegroundColor Yellow
$cssDir = Join-Path $sourceDir "static\css"
$customCss = Join-Path $cssDir "custom_burger.css"

$cssContent = @'
/* Diego's Burger - Tema Visual */
:root {
    --burger-red: #D32F2F;
    --burger-yellow: #FBC02D;
    --burger-orange: #F57C00;
    --burger-brown: #5D4037;
    --burger-cream: #FFF8E1;
}

.navbar {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%) !important;
}

.navbar-brand {
    font-weight: 700 !important;
    color: var(--burger-yellow) !important;
}

.sidebar {
    background: linear-gradient(180deg, var(--burger-brown) 0%, #212121 100%) !important;
}

.menu-link:hover {
    background-color: var(--burger-orange) !important;
    border-left: 4px solid var(--burger-yellow);
}

.btn-primary {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%) !important;
    border: none !important;
    border-radius: 25px;
}

h1, h2, h3 {
    color: var(--burger-red) !important;
}

.table thead {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%);
    color: white;
}
'@

Set-Content $customCss -Value $cssContent -Encoding UTF8
Write-Host "  OK - CSS personalizado creado`n" -ForegroundColor Green

# 6. Modificar templates
Write-Host "[6/7] Modificando templates HTML..." -ForegroundColor Yellow

# Modificar base_user.html
$baseUserFile = Join-Path $sourceDir "templates\main\base_user.html"
if (Test-Path $baseUserFile) {
    $content = Get-Content $baseUserFile -Raw -Encoding UTF8
    $content = $content -replace 'Restaurante',"Diego's Burger"
    $content = $content -replace 'restaurante','hamburgueseria'
    $content = $content -replace 'Platillo','Hamburguesa'
    $content = $content -replace 'platillo','hamburguesa'
    
    # Agregar CSS personalizado
    if ($content -notmatch 'custom_burger.css') {
        $content = $content -replace '</head>',("    <link rel=`"stylesheet`" href=`"{% static 'css/custom_burger.css' %}`">`n</head>")
    }
    
    Set-Content $baseUserFile -Value $content -Encoding UTF8
}

# Modificar todos los templates de platillos
$platillosDir = Join-Path $sourceDir "templates\platillos"
if (Test-Path $platillosDir) {
    Get-ChildItem $platillosDir -Filter "*.html" | ForEach-Object {
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        $content = $content -replace 'Platillo','Hamburguesa'
        $content = $content -replace 'platillo','hamburguesa'
        $content = $content -replace 'Platillos','Hamburguesas'
        $content = $content -replace 'platillos','hamburguesas'
        Set-Content $_.FullName -Value $content -Encoding UTF8
    }
}

Write-Host "  OK - Templates actualizados`n" -ForegroundColor Green

# 7. Crear README
Write-Host "[7/7] Creando README..." -ForegroundColor Yellow
$readmeFile = Join-Path $sourceDir "README.md"
$readmeContent = @'
# Diego's Burger - Sistema de Gestion

Sistema de gestion para hamburgueseria con Django 5.2.6

## Instalacion

1. Crear entorno virtual:
   python -m venv .venv
   .venv\Scripts\activate

2. Instalar Django:
   pip install django==5.2.6

3. Aplicar migraciones:
   python manage.py migrate

4. Crear superusuario:
   python manage.py createsuperuser

5. Ejecutar servidor:
   python manage.py runserver

## Acceso

- URL: http://127.0.0.1:8000/
- Admin: http://127.0.0.1:8000/admin/

## Caracteristicas

- Gestion de hamburguesas
- Control de mesas
- Sistema de pedidos
- Gestion de pagos
- Tema visual personalizado (rojo/amarillo/naranja)

Proyecto educativo para Diego's Burger
'@

Set-Content $readmeFile -Value $readmeContent -Encoding UTF8
Write-Host "  OK - README creado`n" -ForegroundColor Green

Write-Host "==========================================`n" -ForegroundColor Green
Write-Host "Transformacion COMPLETADA!`n" -ForegroundColor Green
Write-Host "==========================================`n" -ForegroundColor Green
Write-Host "La carpeta esta lista en: C:\Users\akabr\DiegosBurger`n" -ForegroundColor White
Write-Host "Siguiente paso: Comprimirla en ZIP y enviarla`n" -ForegroundColor Yellow
