# ============================================
# Script de Transformación: Diego's Burger
# ============================================
# Este script transforma el proyecto Restaurante en Diego's Burger
# con cambios visuales y de contexto (hamburguesería)

$ErrorActionPreference = "Stop"
$sourceDir = "C:\Users\akabr\DiegosBurger"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  Transformando a Diego's Burger" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe la carpeta fuente
if (-not (Test-Path $sourceDir)) {
    Write-Host "ERROR: No existe la carpeta $sourceDir" -ForegroundColor Red
    Write-Host "Por favor verifica que se haya copiado correctamente el proyecto." -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/8] Modificando archivos de configuración..." -ForegroundColor Yellow

# Modificar settings.py - cambiar nombre del proyecto
$settingsFile = Join-Path $sourceDir "restaurante\settings.py"
if (Test-Path $settingsFile) {
    $content = Get-Content $settingsFile -Raw -Encoding UTF8
    $content = $content -replace "restaurante", "diegosburger"
    $content = $content -replace "Restaurante", "Diego's Burger"
    Set-Content $settingsFile -Value $content -Encoding UTF8
    Write-Host "  ✓ settings.py modificado" -ForegroundColor Green
}

# Renombrar carpeta restaurante a diegosburger
$oldDir = Join-Path $sourceDir "restaurante"
$newDir = Join-Path $sourceDir "diegosburger"
if (Test-Path $oldDir) {
    Rename-Item -Path $oldDir -NewName "diegosburger" -Force
    Write-Host "  ✓ Carpeta renombrada: restaurante -> diegosburger" -ForegroundColor Green
}

# Modificar manage.py
$manageFile = Join-Path $sourceDir "manage.py"
if (Test-Path $manageFile) {
    $content = Get-Content $manageFile -Raw -Encoding UTF8
    $content = $content -replace "restaurante", "diegosburger"
    Set-Content $manageFile -Value $content -Encoding UTF8
    Write-Host "  ✓ manage.py modificado" -ForegroundColor Green
}

# Modificar wsgi.py y asgi.py
$wsgiFile = Join-Path $sourceDir "diegosburger\wsgi.py"
$asgiFile = Join-Path $sourceDir "diegosburger\asgi.py"
if (Test-Path $wsgiFile) {
    $content = Get-Content $wsgiFile -Raw -Encoding UTF8
    $content = $content -replace "restaurante", "diegosburger"
    Set-Content $wsgiFile -Value $content -Encoding UTF8
    Write-Host "  ✓ wsgi.py modificado" -ForegroundColor Green
}
if (Test-Path $asgiFile) {
    $content = Get-Content $asgiFile -Raw -Encoding UTF8
    $content = $content -replace "restaurante", "diegosburger"
    Set-Content $asgiFile -Value $content -Encoding UTF8
    Write-Host "  ✓ asgi.py modificado" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/8] Creando archivo CSS personalizado..." -ForegroundColor Yellow

# Crear custom.css con tema de hamburguesas
$cssDir = Join-Path $sourceDir "static\css"
$customCss = Join-Path $cssDir "custom_burger.css"

$cssContent = @"
/* ============================================
   Diego's Burger - Tema Visual Personalizado
   ============================================ */

:root {
    /* Paleta de colores hamburguesas */
    --burger-red: #D32F2F;
    --burger-yellow: #FBC02D;
    --burger-orange: #F57C00;
    --burger-brown: #5D4037;
    --burger-cream: #FFF8E1;
    --burger-dark: #212121;
}

/* Navbar personalizado */
.navbar {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%) !important;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.navbar-brand {
    font-weight: 700 !important;
    font-size: 1.5rem !important;
    color: var(--burger-yellow) !important;
    text-shadow: 2px 2px 4px rgba(0,0,0,0.3);
}

/* Sidebar personalizado */
.sidebar {
    background: linear-gradient(180deg, var(--burger-brown) 0%, var(--burger-dark) 100%) !important;
}

.menu-link {
    color: var(--burger-cream) !important;
    transition: all 0.3s ease;
}

.menu-link:hover {
    background-color: var(--burger-orange) !important;
    color: white !important;
    transform: translateX(5px);
    border-left: 4px solid var(--burger-yellow);
}

/* Botones estilo hamburguesa */
.btn-primary {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%) !important;
    border: none !important;
    color: white !important;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    padding: 10px 25px;
    border-radius: 25px;
    box-shadow: 0 4px 6px rgba(211, 47, 47, 0.3);
    transition: all 0.3s ease;
}

.btn-primary:hover {
    background: linear-gradient(135deg, var(--burger-orange) 0%, var(--burger-red) 100%) !important;
    transform: translateY(-2px);
    box-shadow: 0 6px 12px rgba(211, 47, 47, 0.4);
}

.btn-danger {
    background-color: #C62828 !important;
    border: none !important;
    border-radius: 25px;
}

.btn-secondary {
    background-color: var(--burger-brown) !important;
    border: none !important;
    border-radius: 25px;
}

/* Títulos estilo hamburguesa */
h1, h2, h3 {
    color: var(--burger-red) !important;
    font-weight: 700 !important;
    text-transform: uppercase;
    letter-spacing: 1px;
}

h1 {
    border-bottom: 3px solid var(--burger-yellow);
    padding-bottom: 10px;
    margin-bottom: 25px;
}

/* Tablas con tema burger */
.table {
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.table thead {
    background: linear-gradient(135deg, var(--burger-red) 0%, var(--burger-orange) 100%);
    color: white;
}

.table tbody tr:hover {
    background-color: var(--burger-cream);
    transition: background-color 0.2s ease;
}

/* Cards personalizadas */
.card {
    border: none !important;
    border-radius: 15px !important;
    box-shadow: 0 4px 12px rgba(0,0,0,0.1) !important;
    transition: transform 0.3s ease;
}

.card:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 20px rgba(0,0,0,0.15) !important;
}

.card-header {
    background: linear-gradient(135deg, var(--burger-yellow) 0%, var(--burger-orange) 100%) !important;
    color: var(--burger-dark) !important;
    font-weight: 700;
    border-radius: 15px 15px 0 0 !important;
}

/* Forms estilo burger */
.form-control {
    border: 2px solid var(--burger-cream);
    border-radius: 10px;
    padding: 12px;
    transition: all 0.3s ease;
}

.form-control:focus {
    border-color: var(--burger-orange);
    box-shadow: 0 0 0 0.2rem rgba(245, 124, 0, 0.25);
}

/* Badges temáticos */
.badge {
    padding: 8px 15px;
    border-radius: 20px;
    font-weight: 600;
}

/* Contenedor principal */
.content {
    background-color: #FAFAFA;
    min-height: 100vh;
}

/* Animaciones */
@keyframes slideIn {
    from {
        opacity: 0;
        transform: translateY(20px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.table, .card, form {
    animation: slideIn 0.5s ease;
}
"@

Set-Content $customCss -Value $cssContent -Encoding UTF8
Write-Host "  ✓ custom_burger.css creado" -ForegroundColor Green

Write-Host ""
Write-Host "[3/8] Modificando templates base..." -ForegroundColor Yellow

# Modificar base.html
$baseFile = Join-Path $sourceDir "templates\main\base.html"
if (Test-Path $baseFile) {
    $content = Get-Content $baseFile -Raw -Encoding UTF8
    
    # Cambiar título
    $content = $content -replace "<title>.*?</title>", "<title>Diego's Burger - Sistema de Gestion</title>"
    
    # Agregar link al CSS personalizado antes del cierre de head
    $cssLink = "    <link rel='stylesheet' href='{% static ''css/custom_burger.css'' %}'>"
    if ($content -notmatch "custom_burger.css") {
        $content = $content -replace "</head>", "$cssLink`n</head>"
    }
    
    Set-Content $baseFile -Value $content -Encoding UTF8
    Write-Host "  ✓ base.html modificado" -ForegroundColor Green
}

# Modificar base_user.html
$baseUserFile = Join-Path $sourceDir "templates\main\base_user.html"
if (Test-Path $baseUserFile) {
    $content = Get-Content $baseUserFile -Raw -Encoding UTF8
    
    # Cambiar título/nombre del restaurante
    $content = $content -replace "Restaurante", "Diego's Burger"
    $content = $content -replace "restaurante", "hamburguesería"
    
    # Cambiar iconos (ejemplos principales)
    $content = $content -replace "bi-shop", "bi-shop-window"
    $content = $content -replace "bi-person-circle", "bi-person-badge"
    
    # Agregar link al CSS personalizado si no existe
    $cssLink = "    <link rel='stylesheet' href='{% static ''css/custom_burger.css'' %}'>"
    if ($content -notmatch "custom_burger.css") {
        $content = $content -replace "</head>", "$cssLink`n</head>"
    }
    
    Set-Content $baseUserFile -Value $content -Encoding UTF8
    Write-Host "  ✓ base_user.html modificado" -ForegroundColor Green
}

# Modificar index.html y main_index.html
$indexFile = Join-Path $sourceDir "templates\main\index.html"
if (Test-Path $indexFile) {
    $content = Get-Content $indexFile -Raw -Encoding UTF8
    $content = $content -replace "Restaurante", "Diego's Burger"
    $content = $content -replace "Bienvenido al sistema", "Bienvenido a Diego's Burger"
    Set-Content $indexFile -Value $content -Encoding UTF8
    Write-Host "  ✓ index.html modificado" -ForegroundColor Green
}

$mainIndexFile = Join-Path $sourceDir "templates\main\main_index.html"
if (Test-Path $mainIndexFile) {
    $content = Get-Content $mainIndexFile -Raw -Encoding UTF8
    $content = $content -replace "Restaurante", "Diego's Burger"
    Set-Content $mainIndexFile -Value $content -Encoding UTF8
    Write-Host "  ✓ main_index.html modificado" -ForegroundColor Green
}

Write-Host ""
Write-Host "[4/8] Modificando templates de platillos (ahora hamburguesas)..." -ForegroundColor Yellow

# Modificar todos los templates de platillos
$platillosTemplates = Get-ChildItem -Path (Join-Path $sourceDir "templates\platillos") -Filter "*.html" -ErrorAction SilentlyContinue

foreach ($template in $platillosTemplates) {
    $content = Get-Content $template.FullName -Raw -Encoding UTF8
    
    # Reemplazos de texto
    $content = $content -replace "Platillo", "Hamburguesa"
    $content = $content -replace "platillo", "hamburguesa"
    $content = $content -replace "Platillos", "Hamburguesas"
    $content = $content -replace "platillos", "hamburguesas"
    $content = $content -replace "Categoría", "Tipo"
    $content = $content -replace "categoría", "tipo"
    
    # Cambiar iconos relacionados
    $content = $content -replace "bi-basket", "bi-basket3"
    
    Set-Content $template.FullName -Value $content -Encoding UTF8
}
Write-Host "  ✓ Templates de platillos modificados (ahora hamburguesas)" -ForegroundColor Green

Write-Host ""
Write-Host "[5/8] Modificando templates de categorías..." -ForegroundColor Yellow

# Modificar templates de categorías
$categoriasTemplates = Get-ChildItem -Path (Join-Path $sourceDir "templates\categorias") -Filter "*.html" -ErrorAction SilentlyContinue

foreach ($template in $categoriasTemplates) {
    $content = Get-Content $template.FullName -Raw -Encoding UTF8
    
    $content = $content -replace "Categoría", "Tipo de Hamburguesa"
    $content = $content -replace "categoría", "tipo de hamburguesa"
    $content = $content -replace "Categorias", "Tipos"
    $content = $content -replace "categorias", "tipos"
    
    Set-Content $template.FullName -Value $content -Encoding UTF8
}
Write-Host "  ✓ Templates de categorías modificados" -ForegroundColor Green

Write-Host ""
Write-Host "[6/8] Modificando templates de órdenes..." -ForegroundColor Yellow

# Modificar templates de órdenes
$ordenesTemplates = Get-ChildItem -Path (Join-Path $sourceDir "templates\ordenes") -Filter "*.html" -ErrorAction SilentlyContinue -Recurse

foreach ($template in $ordenesTemplates) {
    $content = Get-Content $template.FullName -Raw -Encoding UTF8
    
    $content = $content -replace "Orden", "Pedido"
    $content = $content -replace "orden", "pedido"
    $content = $content -replace "Ordenes", "Pedidos"
    $content = $content -replace "ordenes", "pedidos"
    $content = $content -replace "Platillo", "Hamburguesa"
    $content = $content -replace "platillo", "hamburguesa"
    
    # Cambiar iconos
    $content = $content -replace "bi-cart", "bi-bag-check"
    
    Set-Content $template.FullName -Value $content -Encoding UTF8
}
Write-Host "  ✓ Templates de órdenes modificados" -ForegroundColor Green

Write-Host ""
Write-Host "[7/8] Modificando templates de mesas..." -ForegroundColor Yellow

# Modificar templates de mesas
$mesasTemplates = Get-ChildItem -Path (Join-Path $sourceDir "templates\mesas") -Filter "*.html" -ErrorAction SilentlyContinue

foreach ($template in $mesasTemplates) {
    $content = Get-Content $template.FullName -Raw -Encoding UTF8
    
    # Cambiar iconos de mesas
    $content = $content -replace "bi-table", "bi-grid-3x3"
    
    Set-Content $template.FullName -Value $content -Encoding UTF8
}
Write-Host "  ✓ Templates de mesas modificados" -ForegroundColor Green

Write-Host ""
Write-Host "[8/8] Creando README personalizado..." -ForegroundColor Yellow

# Crear README.md personalizado
$readmeFile = Join-Path $sourceDir "README.md"
$readmeContent = @"
# Diego's Burger - Sistema de Gestion

Sistema de gestion para hamburgueseria desarrollado con Django 5.2.6

## Caracteristicas

- Gestion de hamburguesas y tipos
- Control de mesas y estados
- Sistema de pedidos y detalles
- Gestion de pagos y metodos de pago
- Autenticacion de usuarios
- Interfaz responsive con Bootstrap 5
- Tema visual personalizado (rojo/amarillo/naranja)

## Instalacion

### 1. Crear entorno virtual

python -m venv .venv
.venv\Scripts\activate

### 2. Instalar dependencias

pip install django==5.2.6

### 3. Aplicar migraciones

python manage.py migrate

### 4. Crear superusuario

python manage.py createsuperuser

### 5. Ejecutar servidor

python manage.py runserver

### 6. Acceder al sistema

- URL: http://127.0.0.1:8000/
- Admin: http://127.0.0.1:8000/admin/

## Estructura del Proyecto

diegosburger/
├── apps/
│   ├── accounts/      # Gestion de usuarios
│   ├── platillos/     # Hamburguesas y tipos
│   └── ordenes/       # Pedidos, mesas, pagos
├── diegosburger/      # Configuracion del proyecto
├── static/            # Archivos estaticos (CSS, JS)
├── templates/         # Plantillas HTML
└── manage.py

## Personalizacion Visual

El proyecto incluye:
- Paleta de colores tematica de hamburguesas (rojo, amarillo, naranja)
- CSS personalizado en static/css/custom_burger.css
- Iconos Bootstrap Icons
- Diseno responsive

## Desarrollador

Proyecto desarrollado para Diego's Burger

## Licencia

Proyecto educativo - Todos los derechos reservados
"@

Set-Content $readmeFile -Value $readmeContent -Encoding UTF8
Write-Host "  ✓ README.md creado" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Transformacion completada!" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Proximos pasos:" -ForegroundColor Cyan
Write-Host "1. Revisar la carpeta: C:\Users\akabr\DiegosBurger" -ForegroundColor White
Write-Host "2. Comprimir la carpeta en un ZIP" -ForegroundColor White
Write-Host "3. Enviar el ZIP a tu amigo" -ForegroundColor White
Write-Host ""
Write-Host "Tu amigo debera:" -ForegroundColor Cyan
Write-Host "1. Descomprimir el ZIP" -ForegroundColor White
Write-Host "2. Crear entorno virtual: python -m venv .venv" -ForegroundColor White
Write-Host "3. Activar entorno: .venv\Scripts\activate" -ForegroundColor White
Write-Host "4. Instalar Django: pip install django==5.2.6" -ForegroundColor White
Write-Host "5. Migrar: python manage.py migrate" -ForegroundColor White
Write-Host "6. Crear superusuario: python manage.py createsuperuser" -ForegroundColor White
Write-Host "7. Ejecutar: python manage.py runserver" -ForegroundColor White
Write-Host ""
Write-Host "Listo!" -ForegroundColor Yellow
