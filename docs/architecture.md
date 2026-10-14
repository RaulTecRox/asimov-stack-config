# Arquitetura Asimov Stack (Custom Edition)

Esta arquitetura combina o modelo de 4 camadas da **Asimov Stack** com a **Triple Memory Architecture**, o **Laya Decision Model (System 1)** e a orquestração nativa via **Orca CLI**.

```mermaid
graph TD
    User[Usuário / Demanda] --> Laya[Laya Decision Service (System 1)]
    
    subgraph "Camada de Reflexo Rápido (<33ms)"
        Laya -->|Choice/Score/Binary| Router[Roteador Hierárquico]
    end
    
    Router -->|Comando Orca + Agente Alvo| Maestro[Claude Code (Maestro / Coordenador)]
    
    subgraph "Memória Tripla"
        Maestro <--> CM[claude-mem (Experiência / Histórico)]
        Maestro <--> CBM[codebase-memory-mcp (Implementação / AST Graph)]
        Maestro <--> Obs[Obsidian Vault (Sabedoria / Specs / Board)]
    end
    
    subgraph "Execução e Orquestração Supervisionada (Orca)"
        Maestro -->|orca orchestration worker-start| Orca[Orca Runtime]
        Orca --> WT1[Git Worktree A (Backend)]
        Orca --> WT2[Git Worktree B (Frontend)]
        Orca --> WT3[Git Worktree C (QA / Testes)]
    end
    
    subgraph "Auditoria e Fechamento (Juiz)"
        WT1 -->|worker_done| Judge[Maestro Audita Critérios de Aceitação]
        WT2 -->|worker_done| Judge
        WT3 -->|worker_done| Judge
        Judge -->|Aprovado| Integration[Merge Git + CBM Index + Obsidian Done]
    end
```

## 1. As 4 Camadas da Asimov Stack

| Camada | Tecnologia | Função |
| :--- | :--- | :--- |
| **0. Reflex Layer (System 1)** | **Laya Decision Model** | Roteamento não-autorregressivo ultrarrápido (<33ms), guardrails de segurança e scoring. |
| **1. Memory (Sabedoria & Estado)** | **Triple Memory** (Obsidian + claude-mem + CBM) | Contexto durável dividido em Estratégia, Histórico de Sessão e Grafo de Código. |
| **2. Skills (Instruções Especializadas)** | **459 Skills Nativas** (`~/.claude/skills/`) | Conhecimento procedimental ativado por demanda. |
| **3. Orchestration (Maestro)** | **Claude Code + Orca CLI** | O modelo principal atua como Juiz; o Orca gerencia worktrees e processos paralelos. |
| **4. Arms (Ferramentas de Execução)** | **MCPs & CLIs** (Firecrawl, n8n, Serena, NotebookLM) | Braços operacionais que conectam a stack ao mundo real. |
