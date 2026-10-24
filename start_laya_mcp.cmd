@echo off
REM Script de inicialização da Laya Decision Service como MCP Server (FastMCP SSE)
REM Roda na porta 8000 com endpoint SSE em /sse

set LAYA_HOME=C:\Users\raul.guimaraes\projects\asimov-stack-config

REM Verificar se a porta 8000 já está em uso
netstat -ano | findstr :8000 >nul
if %errorlevel% equ 0 (
    echo [Laya MCP] Porta 8000 já está em uso. Serviço já pode estar rodando.
    exit /b 0
)

echo [Laya MCP] Iniciando Laya Decision Service (MCP SSE) em http://127.0.0.1:8000/sse
cd /d %LAYA_HOME%

REM Iniciar servidor MCP FastMCP (SSE transport)
python laya_mcp.py >> laya_mcp.log 2>&1