@echo off
REM Cria tarefa agendada para iniciar Laya MCP Server na inicialização do sistema (SYSTEM)
REM DEVE SER EXECUTADO COMO ADMINISTRADOR

echo ================================================
echo  Laya Decision Service - Auto-Start Setup (SYSTEM)
echo ================================================
echo.
echo ESTE SCRIPT DEVE SER EXECUTADO COMO ADMINISTRADOR
echo (Botao direito no cmd/powershell -> "Executar como administrador")
echo.

REM Verificar se é admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Permissao de administrador necessaria.
    echo.
    pause
    exit /b 1
)

set TASK_NAME=LayaMCPService
set LAYA_CMD=C:\Users\raul.guimaraes\projects\asimov-stack-config\start_laya_mcp.cmd

echo Criando tarefa agendada "%TASK_NAME%" para rodar na inicializacao do sistema...
echo Comando: %LAYA_CMD%
echo.

REM /sc onstart = na inicializacao do sistema (antes do login)
REM /ru SYSTEM = como conta SYSTEM (nao depende de login de usuario)
REM /rl HIGHEST = privilegios elevados
REM /f = forca sobrescrita se ja existir
schtasks /create /tn "%TASK_NAME%" /sc onstart /tr "%LAYA_CMD%" /ru SYSTEM /rl HIGHEST /f

if %errorlevel% equ 0 (
    echo.
    echo [SUCESSO] Tarefa agendada criada!
    echo.
    echo Verificando...
    schtasks /query /tn "%TASK_NAME%" /v /fo LIST
) else (
    echo.
    echo [FALHA] Nao foi possivel criar a tarefa.
)

echo.
pause