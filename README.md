# Asimov Stack Config (Custom Edition)

[![Status](https://img.shields.io/badge/status-active-success.svg)]()
[![Architecture](https://img.shields.io/badge/architecture-4--layer-blue.svg)]()
[![Model](https://img.shields.io/badge/System%201-Laya%20(Convai)-orange.svg)]()
[![Runtime](https://img.shields.io/badge/Runtime-Orca%20(StablyAI)-purple.svg)]()

Repositório central de configuração e automação da **Asimov Stack Personalizada**, integrando **Triple Memory Architecture**, **Laya Decision Model (System 1)** e **Orquestração Nativa com Orca CLI**.

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
└──────────────────────────────────────┘
```

---

## 📦 Componentes da Stack

### 1. Camada de Reflexo Rápido: Laya Decision Service (`laya_service.py`)
Microserviço em FastAPI que atua como porta de entrada. Em vez de acionar modelos generativos lentos para decisões operacionais, a Laya resolve em **~33ms**:
- **`POST /route-agent`**: Roteia hierarquicamente entre 6 clusters e seleciona o subagente especialista.
- **`POST /choice`**: Seleção discreta tipada.
- **`POST /score`**: Avaliação contínua de risco/urgência (0.0 a 1.0).
- **`POST /binary`**: Guardrails de segurança e validação booleana.

### 2. Memória Tripla (Precedência Obrigatória)
1. **`claude-mem` (Experiência):** Gotchas, preferências de ambiente e histórico da sessão.
2. **`codebase-memory-mcp` (Implementação):** Grafo semântico e estrutural do código (AST / dependências).
3. **`Obsidian Vault` (Sabedoria):** Especificações de produto, documentações e board de demandas (`board/DEM-*.md`).

### 3. Orquestrador Físico: Orca CLI (`orca orchestration`)
- Despacho de workers em ambientes isolados via Git Worktree (`orca worktree create`).
- Protocolo assíncrono de comunicação inter-agente (`orca orchestration ask/reply/check`).
- Auditoria via Decision Gates (`orca gate-create/resolve`).

---

## ⚡ Inicialização Automática no Claude Code

O serviço da Laya está configurado para **subir automaticamente em segundo plano** assim que você inicia uma sessão no Claude Code:

- **Hook de Disparo:** Integrado no `claude-hook-impl.cmd` do Orca.
- **Script de Inicialização:** `run_laya_daemon.py`
- **Comportamento:** Checa se a porta `8000` está aberta em <10ms; se não estiver, inicializa o uvicorn de forma desacoplada e silenciosa.

---

## 🧪 Testes Automatizados

Para testar a bateria de roteamento com demandas reais:

```bash
python test_router.py
```

### Resultados Validados:
- **Demanda 1 (PostgreSQL):** Roteado para `Database Optimizer` (`database`)
- **Demanda 2 (React/Tailwind):** Roteado para `Frontend Developer` (`frontend`)
- **Demanda 3 (Pentest/Auth):** Roteado para `Security Architect` (`security`)
- **Demanda 4 (Playwright/E2E):** Roteado para `Test Automation Engineer` (`qa_testing`)
- **Demanda 5 (Docker/CI-CD):** Roteado para `DevOps Automator` (`devops_infra`)

**Score:** 100% de precisão nos testes.

---

## 📚 Documentação Complementar

- [Arquitetura Detalhada](docs/architecture.md)
- [Deep Dive: Laya Decision Layer](docs/laya-decision-layer.md)
- [Guia de Comandos: Orca Orchestration](docs/orca-orchestration.md)
- [Ciclo de Trabalho Oficial](ciclo-de-trabalho.md)
- [Triple Memory Architecture](triple-memory-architecture.md)
