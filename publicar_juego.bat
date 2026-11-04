@echo off
rem Doble clic: sube el build actual de NinjaRPG como version nueva a este repo privado.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0publicar_juego.ps1" %*
echo.
pause
