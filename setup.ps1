<#
.SYNOPSIS
    Instalação e Configuração Completa da Asimov Stack (Windows).
.DESCRIPTION
    Script de bootstrapping automatizado para replicar toda a stack:
    1. Instala dependências Python (FastAPI, uvicorn, pydantic, mcp).
    2. Instala e sincroniza os 290+ Subagentes em ~/.claude/agents/.
    3. Instala e sincroniza as 440+ Skills em ~/.claude/skills/.
    4. Configura Hooks e Regras de Segurança em ~/.claude/.
    5. Configura o CLAUDE.md e settings.json do Claude Code.
    6. Configura e inicia o Laya Decision Service (System 1).
    7. Clona e sincroniza o Obsidian Vault em Documents\Obsidian Vault.
    8. Executa bateria de testes automatizados do roteador Laya.
#>

$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🚀 BOOTSTRAP DA ASIMOV STACK (Windows)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$StackDir = $PSScriptRoot
$UserClaudeDir = "$HOME\.claude"
$VaultPath = "$HOME\Documents\Obsidian Vault"

# 1. Dependências Python
Write-Host "`n[1/7] 📦 Instalando dependências Python..." -ForegroundColor Yellow
python -m pip install --upgrade pip | Out-Null
python -m pip install -r "$StackDir\requirements.txt"
Write-Host "✅ Dependências Python instaladas com sucesso." -ForegroundColor Green

# 2. Configurar Diretórios do Claude
Write-Host "`n[2/7] 📁 Configurando diretórios base em $UserClaudeDir..." -ForegroundColor Yellow
$dirs = @(
    "$UserClaudeDir\agents",
    "$UserClaudeDir\skills",
    "$UserClaudeDir\hooks",
    "$UserClaudeDir\rules\common"
)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# 3. Copiar Subagentes
Write-Host "`n[3/7] 🤖 Instalando Subagentes Especialistas..." -ForegroundColor Yellow
Copy-Item -Path "$StackDir\agents\*" -Destination "$UserClaudeDir\agents" -Recurse -Force
$agentCount = (Get-ChildItem -Path "$UserClaudeDir\agents").Count
Write-Host "✅ $agentCount Subagentes instalados em $UserClaudeDir\agents." -ForegroundColor Green

# 4. Copiar Skills
Write-Host "`n[4/7] ⚡ Instalando Skills Nativas..." -ForegroundColor Yellow
Copy-Item -Path "$StackDir\skills\*" -Destination "$UserClaudeDir\skills" -Recurse -Force
$skillCount = (Get-ChildItem -Path "$UserClaudeDir\skills").Count
Write-Host "✅ $skillCount Skills instaladas em $UserClaudeDir\skills." -ForegroundColor Green

# 5. Copiar Hooks, Rules e CLAUDE.md
Write-Host "`n[5/7] 🛡️ Configurando Hooks, Regras e Instruções Globais..." -ForegroundColor Yellow
if (Test-Path "$StackDir\hooks") {
    Copy-Item -Path "$StackDir\hooks\*" -Destination "$UserClaudeDir\hooks" -Recurse -Force
}
if (Test-Path "$StackDir\rules") {
    Copy-Item -Path "$StackDir\rules\*" -Destination "$UserClaudeDir\rules" -Recurse -Force
}
Copy-Item -Path "$StackDir\CLAUDE.md" -Destination "$UserClaudeDir\CLAUDE.md" -Force

# Configurar settings.json se não existir
$settingsFile = "$UserClaudeDir\settings.json"
if (-not (Test-Path $settingsFile)) {
    Copy-Item -Path "$StackDir\claude-config\settings.json.template" -Destination $settingsFile -Force
    Write-Host "✅ Arquivo settings.json criado a partir do template." -ForegroundColor Green
} else {
    Write-Host "ℹ️ Arquivo settings.json já existe. Mantendo configurações locais." -ForegroundColor Gray
}

# 6. Sincronizar Obsidian Vault
Write-Host "`n[6/7] 📓 Sincronizando Obsidian Vault (Memória Tripla)..." -ForegroundColor Yellow
& "$StackDir\scripts\sync_obsidian.ps1" -VaultPath $VaultPath

# 7. Configurar Autostart da Laya e Rodar Testes
Write-Host "`n[7/7] 🧠 Inicializando Laya Decision Service (System 1)..." -ForegroundColor Yellow
& "$StackDir\create_laya_autostart_user.cmd" | Out-Null

# Iniciar Laya em segundo plano agora
Start-Process -FilePath "python" -ArgumentList "laya_service.py" -WorkingDirectory $StackDir -WindowStyle Hidden

Start-Sleep -Seconds 2

# Testar roteador
Write-Host "🧪 Executando testes automatizados do roteador Laya..." -ForegroundColor Cyan
Set-Location $StackDir
python test_router.py

Write-Host "`n==========================================================" -ForegroundColor Green
Write-Host "✨ ASIMOV STACK INSTALADA E PRONTA PARA OPERAÇÃO!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "- Subagentes: $agentCount prontos"
Write-Host "- Skills: $skillCount prontas"
Write-Host "- Laya: Rodando em http://127.0.0.1:8000"
Write-Host "- Obsidian: Sincronizado em $VaultPath"
Write-Host "==========================================================" -ForegroundColor Green
