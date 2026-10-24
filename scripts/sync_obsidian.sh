#!/usr/bin/env bash
# Sincronizador Automático do Obsidian Vault com o GitHub (Linux/macOS)
set -e

VAULT_PATH="${1:-$HOME/Documents/Obsidian Vault}"
REPO_URL="${2:-https://github.com/RaulTecRox/obsidian-vault.git}"
COMMIT_MSG="chore(vault): sync $(date '+%Y-%m-%d %H:%M:%S')"

echo "========================================="
echo "🔄 Obsidian Vault Sync (GitHub)"
echo "========================================="

# 1. Verificar se diretório existe
if [ ! -d "$VAULT_PATH" ]; then
    echo "[1/4] Vault não encontrado em $VAULT_PATH. Clonando..."
    mkdir -p "$(dirname "$VAULT_PATH")"
    git clone "$REPO_URL" "$VAULT_PATH"
fi

cd "$VAULT_PATH"

# 2. Inicializar se necessário
if [ ! -d ".git" ]; then
    echo "[AVISO] Inicializando repositório Git no Vault..."
    git init
    git remote add origin "$REPO_URL"
    git branch -M main
    git pull origin main --rebase || true
fi

# 3. Pull
echo "[2/4] Atualizando do repositório remoto..."
git pull origin main --rebase || {
    echo "⚠️ Erro no rebase, tentando merge padrão..."
    git rebase --abort 2>/dev/null || true
    git pull origin main --no-rebase || true
}

# 4. Commit & Push se houver mudanças
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 Alterações detectadas. Commitando..."
    git add -A
    git commit -m "$COMMIT_MSG"
    echo "[4/4] Enviando para o GitHub..."
    git push origin main
    echo "🚀 Obsidian Vault sincronizado com sucesso!"
else
    echo "✨ Nenhuma alteração pendente. Vault atualizado!"
fi
