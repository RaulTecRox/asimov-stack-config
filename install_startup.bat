@echo off
REM Script de instalação para start automático da Laya Service
REM Copie este script para a pasta de Startup do usuário atual

set LAYA_HOME=C:\Users\raul.guimaraes\projects\asimov-stack-config
set LAYA_CMD=%LAYA_HOME%\start_laya.cmd

echo [Laya] Configurando start automático...

REM Executar o start_laya.cmd apenas se a porta 8000 não estiver em uso
%LAYA_CMD%

echo [Laya] ✅ Start automático configurado via startup folder