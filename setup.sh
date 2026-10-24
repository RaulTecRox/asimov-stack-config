#!/usr/bin/env bash
# ==========================================================
# 🚀 BOOTSTRAP DA ASIMOV STACK (Linux / macOS / WSL)
# ==========================================================
set -e

STACK_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
USER_CLAUDE_DIR="$HOME/.claude"
VAULT_PATH="$HOME/Documents/Obsidian Vault"

echo "=========================================================="
echo "🚀 INICIANDO SETUP DA ASIMOV STACK"
echo "=========================================================="

# 1. Dependências Python
echo -e "\n[1/7] 📦 Instalando dependências Python..."
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi
$PYTHON_CMD -m pip install --upgrade pip || true
$PYTHON_CMD -m pip install -r "$STACK_DIR/requirements.txt"
echo "✅ Dependências Python instaladas."

# 2. Configurar Diretórios do Claude
echo -e "\n[2/7] 📁 Configurando diretórios base em $USER_CLAUDE_DIR..."
mkdir -p "$USER_CLAUDE_DIR/agents"
mkdir -p "$USER_CLAUDE_DIR/skills"
mkdir -p "$USER_CLAUDE_DIR/hooks"
mkdir -p "$USER_CLAUDE_DIR/rules/common"

# 3. Copiar Subagentes
echo -e "\n[3/7] 🤖 Instalando Subagentes Especialistas..."
cp -r "$STACK_DIR/agents/"* "$USER_CLAUDE_DIR/agents/"
AGENT_COUNT=$(ls -1 "$USER_CLAUDE_DIR/agents" | wc -l)
echo "✅ $AGENT_COUNT Subagentes instalados."

# 4. Copiar Skills
echo -e "\n[4/7] ⚡ Instalando Skills Nativas..."
cp -r "$STACK_DIR/skills/"* "$USER_CLAUDE_DIR/skills/"
SKILL_COUNT=$(ls -1 "$USER_CLAUDE_DIR/skills" | wc -l)
echo "✅ $SKILL_COUNT Skills instaladas."

# 5. Copiar Hooks, Rules e CLAUDE.md
echo -e "\n[5/7] 🛡️ Configurando Hooks, Regras e Instruções Globais..."
if [ -d "$STACK_DIR/hooks" ]; then
    cp -r "$STACK_DIR/hooks/"* "$USER_CLAUDE_DIR/hooks/" || true
fi
if [ -d "$STACK_DIR/rules" ]; then
    cp -r "$STACK_DIR/rules/"* "$USER_CLAUDE_DIR/rules/" || true
fi
cp "$STACK_DIR/CLAUDE.md" "$USER_CLAUDE_DIR/CLAUDE.md"

if [ ! -f "$USER_CLAUDE_DIR/settings.json" ]; then
    cp "$STACK_DIR/claude-config/settings.json.template" "$USER_CLAUDE_DIR/settings.json"
    echo "✅ Arquivo settings.json criado a partir do template."
fi

# 6. Sincronizar Obsidian Vault
echo -e "\n[6/7] 📓 Sincronizando Obsidian Vault..."
chmod +x "$STACK_DIR/scripts/sync_obsidian.sh"
"$STACK_DIR/scripts/sync_obsidian.sh" "$VAULT_PATH"

# 7. Iniciar Laya e Testar
echo -e "\n[7/7] 🧠 Inicializando Laya Decision Service..."
chmod +x "$STACK_DIR/start_laya.sh"
"$STACK_DIR/start_laya.sh"

sleep 2

echo "🧪 Executando testes automatizados do roteador Laya..."
cd "$STACK_DIR"
$PYTHON_CMD test_router.py

echo "=========================================================="
echo "✨ ASIMOV STACK INSTALADA COM SUCESSO!"
echo "=========================================================="
echo "- Subagentes: $AGENT_COUNT prontos"
echo "- Skills: $SKILL_COUNT prontas"
echo "- Laya: Rodando na porta 8000"
echo "- Obsidian: Sincronizado em $VAULT_PATH"
echo "=========================================================="
