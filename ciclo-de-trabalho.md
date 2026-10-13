---
name: ciclo-de-trabalho
description: "Ciclo de trabalho definido com o usuário: pesquisa NotebookLM → brief → plano → implementação → CBM Index (codebase-memory-mcp)"
metadata: 
  node_type: memory
  type: project
  originSessionId: 96307d3d-b189-4640-92f0-0860f9bd774c
  modified: 2026-10-13T22:03:43.900Z
---

Ciclo de trabalho combinado com o usuário (outubro/2026) para projetos:

1. **Orientação** — hook SessionStart roda project-startup (resumo do projeto, toda sessão) e recommend-once (recomendações de automação, 1x por projeto). Injeta contexto do `claude-mem` (experiência) e do board do Obsidian (demandas).
2. **Pesquisa** — skill `notebook-research` (NotebookLM via `nlm`): cria notebook `<Projeto> Research`, adiciona fontes/pesquisa web, consulta com citações, gera `research/RESEARCH_BRIEF.md` (Camada de Sabedoria).
3. **Planejamento** — `writing-plans` do superpowers ou skills `bmad-*`, com o brief como insumo principal.
4. **Orquestração & Implementação (Modo Maestro Automático via Orca)** — O modelo principal atua como Coordenador/Juiz. Despacha workers (`orca orchestration worker-start`) em worktrees isoladas para executar frentes paralelas (Backend, Frontend, Testes).
5. **Dúvidas de código** — **codebase-memory-mcp (CBM)**: consulta o mapa estrutural e semântico do código (Camada de Implementação). Substitui o `graphify`.
6. **Auditoria & Verificação** — O Maestro audita os entregáveis (`orca orchestration check`) contra os critérios de aceitação antes de aprovar. Trajetória da sessão salva no `claude-mem` (Camada de Experiência).

**Why:** Otimização da economia de tokens e precisão técnica. O CBM provê análise estrutural (Hybrid LSP) e busca semântica (embeddings) superior ao graphify, reduzindo o custo de exploração em até 99.2%.
**How to apply:** Em projetos novos ou sessões retomadas, priorizar consultas ao índice CBM (`search_graph`, `trace_path`) antes de ler arquivos exaustivamente. Versionar o `.codebase-memory/graph.db.zst` para trabalho em equipe.
