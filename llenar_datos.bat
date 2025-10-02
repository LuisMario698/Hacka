@echo off
echo 🚀 Llenando base de datos con datos de prueba...
echo.

cd /d "%~dp0"

echo 📦 Instalando dependencias...
call flutter pub get
echo.

echo 🗃️  Ejecutando script de datos de prueba...
call dart scripts/datos_prueba_simple.dart

echo.
echo ✅ ¡Proceso completado!
echo.
echo 🔐 Credenciales de prueba creadas:
echo    📧 admin@test.com ^| 🔑 password123
echo    📧 user1@test.com ^| 🔑 password123
echo.
pause