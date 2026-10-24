# Asimov Stack Config (Custom Edition)

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Architecture](https://img.shields.io/badge/architecture-4--layer-blue.svg)]()
[![Model](https://img.shields.io/badge/System%201-Laya%20(Convai)-orange.svg)]()
[![Runtime](https://img.shields.io/badge/Runtime-Orca%20(StablyAI)-purple.svg)]()
[![Subagents](https://img.shields.io/badge/Subagents-290%2B-green.svg)]()
[![Skills](https://img.shields.io/badge/Skills-440%2B-yellow.svg)]()

Repositório central de configuração, replicação e automação da **Asimov Stack Personalizada**, integrando **Triple Memory Architecture**, **Laya Decision Model (System 1)**, **290+ Subagentes Especialistas**, **440+ Skills Nativas**, **Orquestração com Orca CLI** e **Sincronização Contínua do Obsidian Vault com o GitHub**.

---

## 🏛️ Visão Geral da Arquitetura

```
[ DEMANDA DO USUÁRIO ]
          │
          ▼
┌──────────────────────────────────────┐
│  LAYA DECISION SERVICE (System 1)    │ ◄── Triagem em <33ms (Single Forward Pass)
└──────────────────┬───────────────────┘
                   │
                   │ Roteamento Hierárquico: Cluster Macro + Subagente
                   ▼
┌──────────────────────────────────────┐
│  CLAUDE CODE (Maestro / Coordenador) │ ◄── Memória Tripla (claude-mem → CBM → Obsidian)
└──────────────────┬───────────────────┘
                   │
                   │ 1. Cria DEM-*.md com critérios de sucesso
                   │ 2. Despacha workers em Git Worktrees
                   ▼
┌────────────────────────────────────────────────────────┐
│  ORCA RUNTIME (Orquestração Supervisionada)           │
├────────────────────────────┬───────────────────────────┤
│ Backend / API              │ @arquiteto / @implementador│
│ Frontend / UI              │ @Frontend Developer       │
│ Database / Performance     │ @Database Optimizer       │
│ Segurança / Pentest        │ @Security Architect       │
│ QA / Automação             │ @Test Automation Engineer │
└────────────────────────────┴───────────────────────────┘
                   │
                   │ Retorna apenas o resultado final (worker_done)
                   ▼
┌──────────────────────────────────────┐
│  MAESTRO (Auditor & Juiz)            │ ◄── Audita contra: [Passo] -> verify: [check]
└──────────────────┬───────────────────┘
                   │
                   │ Aprovado?
                   ▼
┌──────────────────────────────────────┐
│  FECHAMENTO DO LOOP                  │
│  - Merge do Worktree                 │
│  - Atualização do Grafo (CBM)        │
│  - Registro de Gotchas (claude-mem)  │
│  - Kanban Atualizado (Obsidian)      │
│  - Git Push / Sync Automático        │
└──────────────────────────────────────┘
```

---

## 📦 Componentes Incluídos no Repositório

| Componente | Localização | Descrição |
|---|---|---|
| **Laya Service** | `laya_service.py` | FastAPI System 1: roteador não-autorregressivo em ~33ms |
| **Laya FastMCP** | `laya_mcp.py` | Servidor MCP oficial (SSE e stdio) para consumo nativo por agentes |
| **Subagentes** | `agents/` | 290+ definições de subagentes (`arquiteto`, `implementador`, `revisor`, etc.) |
| **Skills Nativas** | `skills/` | 440+ skills cobrindo engenharia, arquitetura, testes, design e automação |
| **Hooks do Harness** | `hooks/` | Hooks do Claude Code (formatação pós-edição, typecheck, gates de memória) |
| **Regras Globais** | `rules/` e `CLAUDE.md` | Diretrizes comportamentais, segurança obrigatória e precedência de memória |
| **Sincronizador Obsidian** | `scripts/sync_obsidian.ps1` | Sincronização bidirecional automatizada com o GitHub |
| **Setup Automatizado** | `setup.ps1` e `setup.sh` | Bootstrap completo em 1 clique para novas máquinas |
| **Prompt p/ Novo Agente** | `AGENT_BOOTSTRAP.md` | Prompt pronto para delegar a instalação a outro agente |

---

## 🚀 Como Subir em Outra Máquina (Instalação em 1 Passo)

### Opção A: Delegando para Outro Agente (Recomendado)
Basta copiar e colar o conteúdo de [AGENT_BOOTSTRAP.md](AGENT_BOOTSTRAP.md) para a sessão do Claude Code na nova máquina. O agente fará todo o clone, instalação, sincronização e validação sozinho.

### Opção B: Execução Manual

#### No Windows (PowerShell):
```powershell
git clone https://github.com/RaulTecRox/asimov-stack-config.git
cd asimov-stack-config
.\setup.ps1
```

#### No Linux / macOS / WSL (Bash):
```bash
git clone https://github.com/RaulTecRox/asimov-stack-config.git
cd asimov-stack-config
chmod +x setup.sh scripts/*.sh
./setup.sh
```

---

## 📓 Sincronização do Obsidian Vault

O Obsidian Vault armazena o conhecimento durável (`concepts/`, `entities/`, `references/`) e o quadro de demandas ativas (`board/DEM-*.md`).

Para sincronizar manualmente a qualquer momento:
- **Windows:** `powershell -File .\scripts\sync_obsidian.ps1`
- **Linux/macOS:** `./scripts/sync_obsidian.sh`

O script:
1. Puxa as alterações mais recentes com rebase (`git pull origin main --rebase`).
2. Identifica e adiciona novos arquivos e notas modificadas.
3. Cria um commit com carimbo de data/hora.
4. Faz push automático para `https://github.com/RaulTecRox/obsidian-vault.git`.

---

## ⚡ Inicialização da Laya (System 1)

O microserviço da Laya opera como porta de entrada de baixa latência:
- `POST /route-agent`: Triagem hierárquica por keyword-density / cluster matching.
- `GET /health`: Health check do serviço.

### Inicialização em Background no Windows:
```cmd
start_laya_mcp.cmd
```
Ou configure inicialização no boot do Windows:
```cmd
create_laya_autostart_user.cmd
```

### Inicialização no Linux/macOS:
```bash
./start_laya.sh
```

---

## 🧪 Testes Automatizados

Para validar o funcionamento do roteador Laya:
```bash
python test_router.py
```
Score esperado: **100% de precisão** nas baterias de roteamento (backend, frontend, database, security, qa_testing, devops_infra).

---

## 📚 Documentação Complementar
- [Prompt de Bootstrap para Agentes](AGENT_BOOTSTRAP.md)
- [Ciclo de Trabalho Oficial](ciclo-de-trabalho.md)
- [Triple Memory Architecture](triple-memory-architecture.md)
- [Deep Dive: Laya Decision Layer](docs/laya-decision-layer.md)
- [Guia de Comandos: Orca Orchestration](docs/orca-orchestration.md)
- [Autostart da Laya no Windows](LAYA_AUTO_STARTUP_README.md)
