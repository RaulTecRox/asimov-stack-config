# 🤖 Prompt de Inicialização para Novo Agente (Bootstrap em Outra Máquina)

Copie e cole as instruções abaixo diretamente no Claude Code (ou outro agente de IA) ao iniciar em uma máquina nova ou ambiente limpo.

---

```markdown
Você é o Agente de Infraestrutura e Setup responsável por inicializar a **Asimov Stack** nesta máquina.

Siga rigorosamente os passos abaixo para configurar o ambiente de desenvolvimento completo:

### 1. Clonar o Repositório de Configuração da Stack
Se este repositório ainda não estiver clonado, clone-o:
- Windows: `cd $HOME\projects && git clone https://github.com/RaulTecRox/asimov-stack-config.git`
- Linux/Mac: `mkdir -p ~/projects && cd ~/projects && git clone https://github.com/RaulTecRox/asimov-stack-config.git`

### 2. Executar o Script de Bootstrap Automatizado
Navegue até a pasta do repositório `asimov-stack-config` e execute:

**No Windows (PowerShell):**
```powershell
Set-Location "$HOME\projects\asimov-stack-config"
.\setup.ps1
```

**No Linux / macOS / WSL (Bash):**
```bash
cd ~/projects/asimov-stack-config
chmod +x setup.sh scripts/*.sh
./setup.sh
```

### 3. O que o Setup automatizado faz:
1. Instala dependências Python: `fastapi`, `uvicorn`, `pydantic`, `httpx`, `fastmcp`, `mcp`, `pytest`.
2. Instala todos os 290+ Subagentes especialistas em `~/.claude/agents/`.
3. Instala todas as 440+ Skills nativas em `~/.claude/skills/`.
4. Instala os Hooks e Regras de Segurança em `~/.claude/hooks/` e `~/.claude/rules/`.
5. Configura `~/.claude/CLAUDE.md` com a arquitetura de Memória Tripla e o Modo Maestro.
6. Inicializa o serviço de decisão ultrarrápido **Laya System 1** (`http://127.0.0.1:8000`).
7. Clona e sincroniza o **Obsidian Vault** a partir de `https://github.com/RaulTecRox/obsidian-vault.git` em `~/Documents/Obsidian Vault`.
8. Executa a bateria de testes automatizados do roteador da Laya (`python test_router.py`).

### 4. Validação e Teste do Ambiente
Após a execução do script:
1. Verifique se o serviço da Laya responde em `GET http://127.0.0.1:8000/health`.
2. Verifique se `git status` no Obsidian Vault está limpo e sincronizado.
3. Teste o roteamento com `python test_router.py`.

Apresente um relatório confirmando cada um dos 4 pilares:
- [x] Laya Decision Layer ativa
- [x] Subagentes & Skills instalados
- [x] Memória Tripla (claude-mem + CBM + Obsidian) operacional
- [x] Obsidian sincronizado com o GitHub
```
