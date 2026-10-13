---
name: triple-memory-architecture
description: "Arquitetura de memória em 3 camadas para agentes de codificação: Sabedoria (Obsidian/NLM), Experiência (claude-mem), Implementação (CBM)"
metadata:
  node_type: memory
  type: project
  originSessionId: 8a12c742-cfcf-43d6-9dba-7109aca79148
  modified: 2026-10-13T20:38:11.432Z
---

A stack oficial utiliza uma topologia de memória em 3 camadas para maximizar a eficiência de tokens e precisão:

### 1. Camada de Sabedoria (Longo Prazo)
*   **Ferramentas:** Obsidian + NotebookLM.
*   **Domínio:** O "Porquê". Especificações, requisitos de negócio, arquitetura teórica (Briefs) e quadro de demandas (`board/`).
*   **Uso:** Insumo inicial para planejamento.

### 2. Camada de Experiência (Episódica)
*   **Ferramentas:** `claude-mem` (`MEMORY.md` + `work_state_write`).
*   **Domínio:** O "Histórico". Preferências do usuário, decisões de sessão, gotchas de ambiente e trajetórias de sucesso/falha.
*   **Uso:** Grounding histórico no `SessionStart` e preservação de contexto pós-compactação.

### 3. Camada de Implementação (Estrutural)
*   **Ferramentas:** `codebase-memory-mcp` (CBM).
*   **Domínio:** O "Mapa". Grafo estrutural (AST + Hybrid LSP), dependências técnicas, rotas HTTP e busca vetorial em código.
*   **Uso:** Navegação técnica ultra-rápida (redução de 99.2% de tokens vs busca manual).

**Why:** Evita o "Gap de Reinicialização" (re-explorar o repo a cada sessão) e garante que o agente saiba *por que* algo foi feito (Sabedoria) e *como* foi implementado (Implementação).
**How to apply:** Seguir o fluxo unificado: `Grounding Histórico (claude-mem) → Navegação Estrutural (CBM) → Execução → Registro de Trajetória (claude-mem)`.
