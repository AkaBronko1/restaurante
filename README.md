# 🍕 Pizzas Brandini - Sistema de Autenticación

Sistema de gestión de restaurante desarrollado con Django 5.2.5 que incluye:

## ✨ Características

- Sistema de autenticación completo (login/logout)
- Páginas protegidas con decoradores `@login_required`
- Modelo de usuario personalizado
- Interfaz moderna con Bootstrap 5
- Diseño responsivo con tema amarillo/negro

## 🚀 Instalación

1. Clonar el repositorio
2. Crear entorno virtual: `python -m venv venv`
3. Activar entorno: `venv\Scripts\activate` (Windows)
4. Instalar dependencias: `pip install django`
5. Ejecutar migraciones: `python manage.py migrate`
6. Crear superusuario: `python manage.py createsuperuser`
7. Ejecutar servidor: `python manage.py runserver`

## 🔐 Credenciales de prueba

- **Usuario:** 1234
- **Contraseña:** 1234

## 📁 Estructura

- `apps/accounts/` - Sistema de autenticación
- `apps/platillos/` - Gestión de platillos
- `templates/` - Templates HTML
- `static/` - Archivos estáticos (CSS, JS)

---
*Proyecto académico - Django 5.2.5*