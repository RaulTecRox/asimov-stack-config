# CLAUDE.md

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

# codebase-memory-mcp (CBM)
- **CBM:** Ferramenta primária de inteligência de código (substitui o graphify).
- **Uso:** Priorizar `search_graph`, `trace_path` e `detect_changes` antes de usar `Grep` ou `Read`.
- **Precedência:** Consultas estruturais e semânticas via CBM economizam 99% de tokens. Use para navegar em arquiteturas complexas.

# Memória Tripla (Precedência de Consulta)
1. **claude-mem:** Primeiro consulte o histórico para decisões e gotchas.
2. **CBM:** Segundo consulte o grafo para localização técnica e impacto.
3. **Obsidian:** Terceiro consulte as especificações para o "porquê".
4. **Ferramentas de Arquivo (Grep/Read):** Apenas se o CBM não estiver indexado ou for insuficiente.

# Onde vive o estado

Não carregue estado na cabeça — ele já tem lugar. Consulte antes de agir.

| Estado | Vive em |
|---|---|
| Demandas / "o que fazer agora" | `Documents/Obsidian Vault/board/` (`DEM-*.md` + `Board.base`) |
| Conhecimento durável | vault: `concepts/ entities/ skills/ references/ synthesis/` |
| Memória entre sessões (ambiente, gotchas, credenciais, runbooks) | `~/.claude/projects/<projeto>/memory/` (índice: `MEMORY.md`) |
| Fontes (camada 1) | `Documents/Obsidian Sources` — fora do vault, por contrato |
| Config do harness | `~/.claude/settings.json` e `~/.claude.json` ⚠️ revertem com sessão viva — ver `skills/reversao-settings-json-processo-stale` no vault |

- Tarefa não-trivial: consultar `board/` e `MEMORY.md` **antes** de propor implementação.
- Estado que depende de ambiente: ler a memória correspondente antes de recomendar caminho — memórias dizem "falta X", e X pode já ter sido feito.
- O detalhe mora onde já vive. Aqui é só o índice.

# Uso Nativo de Skills e Agentes (Auto-Routing)

Não espere o usuário pedir por `/skill` ou `@agent`. Selecione e ative proativamente conforme o domínio da tarefa:

1. **Skills Nativas (450+ em `~/.claude/skills/`):**
   - **Frontend / UI / Design:** Invoque `frontend-design`, `react-best-practices`, `web-design-guidelines` ou `theme-factory` antes de desenhar ou refatorar telas.
   - **Documentos & Escritório:** Invoque `docx`, `pdf`, `pptx` ou `xlsx` sempre que o foco for ler, gerar ou editar documentos nesses formatos.
   - **Testes & Qualidade:** Invoque `webapp-testing` ou `playwright-skill` para automação web; use `semgrep` ou `differential-review` para revisões de segurança.
   - **Engenharia & Specs:** Invoque `grill-me` para clarificar briefings complexos; use `spec-driven-development` ou `bmad-*` para planejamento robusto.
   - **Segurança & RE:** Use os servidores MCP e skills especializadas (incluindo `rea` para engenharia reversa) quando o domínio exigir.

2. **Subagentes Especializados (280+ em `~/.claude/agents/`):**
   - Se uma demanda exigir conhecimento vertical aprofundado (ex.: `Security Architect`, `Database Optimizer`, `Accessibility Auditor`, `arquiteto`, `implementador`), acione o subagente via `Agent(subagent_type: "...")`.
   - Em tarefas multifacetadas, distribua a análise e execução entre os agentes especializados adequados.

# Modo Maestro Automático (Orquestração Nativa com Orca)

**Regra de Ouro:** O modelo principal atua como **Coordenador e Juiz**, NUNCA como digitador de código braçal para tarefas não-triviais.
Diante de qualquer demanda complexa, multi-arquivo ou que envolva frentes paralelas (ex: Front + Back, Refatoração + Testes):
1. **Auto-Orquestração:** Ative proativamente o papel de **Coordinator** invocando a skill `orchestration` e utilizando o binário do Orca (`/c/Users/raul.guimaraes/AppData/Local/Programs/orca/resources/bin/orca`).
2. **Decomposição e Worktrees:** Crie a Run (`orca orchestration run-create`) e despache tarefas em worktrees isoladas (`orca orchestration worker-start`) para proteger a janela de contexto principal.
3. **Auditoria Rígida (Juiz):** Não escreva o código diretamente. Monitore (`orca orchestration check`) e avalie as entregas dos workers estritamente contra os critérios de aceitação (`[Passo] -> verify: [check]`). Devolva com correções pontuais se o resultado for insatisfatório.
4. **Fechamento do Loop:** Ao aprovar, integre o código, re-indexe no CBM, registre os aprendizados no `claude-mem` (`work_state_write`) e mova a demanda para Concluída no Obsidian (`board/`).