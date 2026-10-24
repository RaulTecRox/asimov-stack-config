@echo off
REM Cria tarefa agendada para iniciar Laya MCP Server no logon do usuario atual
REM Nao precisa de Admin, roda no contexto do usuario

echo ================================================
echo  Laya Decision Service - Auto-Start Setup (Usuario)
echo ================================================
echo.
echo Esta versao roda no SEU LOGON (após você entrar no Windows).
echo Nao precisa de permissao de administrador.
echo.

set TASK_NAME=LayaMCPService_User
set LAYA_CMD=C:\Users\raul.guimaraes\projects\asimov-stack-config\start_laya_mcp.cmd

echo Criando tarefa agendada "%TASK_NAME%" para rodar no logon...
echo Comando: %LAYA_CMD%
echo.

REM /sc onlogon = no logon do usuario atual
REM /f = forca sobrescrita se ja existir
schtasks /create /tn "%TASK_NAME%" /sc onlogon /tr "%LAYA_CMD%" /f

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