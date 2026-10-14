@echo off
rem Verifica se a porta 8000 ja esta em uso
netstat -ano | findstr :8000 | findstr LISTENING >nul
if %errorlevel% equ 0 (
    echo [Laya] Servico ja esta rodando na porta 8000.
    exit /b 0
)

echo [Laya] Iniciando Laya Decision Service em background...
cd /d "%~dp0"
start /B python -m uvicorn laya_service:app --host 127.0.0.1 --port 8000 > laya.log 2>&1
echo [Laya] Servico iniciado com sucesso.
exit /b 0
