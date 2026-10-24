<#
.SYNOPSIS
    Sincronizador Automático do Obsidian Vault com o GitHub.
.DESCRIPTION
    Puxa atualizações do repositório remoto, adiciona alterações locais,
    faz commit automático com timestamp e dá push para o GitHub.
#>

param(
    [string]$VaultPath = "$HOME\Documents\Obsidian Vault",
    [string]$RepoUrl = "https://github.com/RaulTecRox/obsidian-vault.git",
    [string]$CommitMessage = "chore(vault): sync $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
)

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "🔄 Obsidian Vault Sync (GitHub)" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Verificar se o diretório do Vault existe
if (-not (Test-Path $VaultPath)) {
    Write-Host "[1/4] Vault não encontrado em $VaultPath. Clonando do GitHub..." -ForegroundColor Yellow
    $parentDir = Split-Path -Parent $VaultPath
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }
    git clone $RepoUrl $VaultPath
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Falha ao clonar o repositório do Obsidian Vault."
        exit 1
    }
    Write-Host "✅ Vault clonado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "[1/4] Diretório do Vault confirmado: $VaultPath" -ForegroundColor Green
}

Set-Location $VaultPath

# 2. Verificar se é repositório Git
if (-not (Test-Path ".git")) {
    Write-Host "[AVISO] Diretório existe mas não é repositório Git. Inicializando..." -ForegroundColor Yellow
    git init
    git remote add origin $RepoUrl
    git branch -M main
    git pull origin main --rebase
}

# 3. Pull das alterações remotas
Write-Host "[2/4] Sincronizando com o GitHub (pull)..." -ForegroundColor Cyan
git pull origin main --rebase
if ($LASTEXITCODE -ne 0) {
    Write-Host "⚠️ Conflito no pull ou erro de rebase. Abortando rebase e tentando merge..." -ForegroundColor Yellow
    git rebase --abort 2>$null
    git pull origin main --no-rebase
}

# 4. Verificar status de alterações locais
Write-Host "[3/4] Verificando modificações locais..." -ForegroundColor Cyan
$status = git status --porcelain
if ($status) {
    Write-Host "📝 Alterações locais detectadas. Adicionando e commitando..." -ForegroundColor Yellow
    git add -A
    git commit -m "$CommitMessage"
    Write-Host "[4/4] Enviando alterações para o GitHub (push)..." -ForegroundColor Cyan
    git push origin main
    if ($LASTEXITCODE -eq 0) {
        Write-Host "🚀 Obsidian Vault sincronizado com sucesso!" -ForegroundColor Green
    } else {
        Write-Error "Falha no git push. Verifique credenciais e conexão com GitHub."
    }
} else {
    Write-Host "✨ Nenhuma alteração pendente. O Vault já está sincronizado!" -ForegroundColor Green
}
