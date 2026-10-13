# asimov-stack-config

Repositório central de configuração da **Asimov Stack** personalizada.

## 🏗️ Arquitetura de Memória Tripla

1.  **Camada de Sabedoria (Longo Prazo):** Obsidian + NotebookLM. O "Porquê".
2.  **Camada de Experiência (Episódica):** `claude-mem`. O "Histórico".
3.  **Camada de Implementação (Estrutural):** `codebase-memory-mcp` (CBM). O "Mapa".

## 🎼 Modo Maestro Automático (Orca Orchestration)

O modelo principal atua estritamente como **Coordenador e Juiz**, delegando execução para workers do **Orca (StablyAI)** em worktrees isoladas.

### Ciclo de Trabalho:
1.  **Pesquisa:** NotebookLM gera `RESEARCH_BRIEF.md`.
2.  **Planejamento:** Obsidian board cria meta verificável `[Passo] -> verify: [check]`.
3.  **Orquestração:** Despacho via `orca orchestration worker-start`.
4.  **Auditoria:** Validação final contra critérios de aceitação.

## 🛠️ Instalação
As configurações principais vivem no `~/.claude/CLAUDE.md`.

---
🤖 Generated with [Claude Code](https://claude.com/claude-code)
