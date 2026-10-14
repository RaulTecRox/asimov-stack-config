# Laya Decision Model (System 1)

O **Laya** (desenvolvido pela **Convai Innovations**) é um modelo de decisão não-autorregressivo (*open-weight*, licença Apache 2.0).

Diferente de um Large Language Model (LLM) tradicional que prevê o próximo token palavra por palavra consumindo centenas de milissegundos, o Laya avalia entradas em uma **única passagem matemática** (*single forward pass*), retornando probabilidades calibradas em cerca de **33 milissegundos**.

---

## 🚀 Modos de Consulta

### 1. Choice Mode (Roteamento Discreto)
Avalia a entrada contra uma lista finita de opções rotuladas.
- **Uso na Stack:** Roteamento de clusters e seleção de subagentes especializados (`~/.claude/agents/`).
- **Retorno:** Rótulo vencedor, mapa de probabilidades para cada opção e score de confiança.

### 2. Score Mode (Avaliação Contínua)
Gera uma pontuação contínua normalizada entre `0.0` e `1.0`.
- **Uso na Stack:** Avaliação de urgência de demandas, complexidade estimada e risco de regressão.
- **Retorno:** Float de 0 a 1 e nível categórico associado.

### 3. Binary Mode (Guarda Booleana)
Retorna probabilidades booleanas (`true` / `false`).
- **Uso na Stack:** Guardrails de segurança, detecção de *prompt injection*, validação de escopo e checagem de invariantes do `CLAUDE.md`.
- **Retorno:** Booleano e probabilidade de veracidade.

---

## 🏗️ Especificações do Modelo

| Parâmetro | Detalhes |
| :--- | :--- |
| **Arquitetura** | Non-autoregressive Transformer |
| **Checkpoints** | 421M (English Base), 322M (Multilingual), 421M (Typed-Decisions) |
| **Latência Média** | ~33 ms (NVIDIA Tesla T4 GPU) / Executável em CPU local |
| **Consumo de Memória** | < 2 GB VRAM |
| **Licença** | Apache 2.0 (Open-weight, self-hosted, custo zero de token) |
| **Repositório** | Hugging Face: `Convai/laya` / GitHub: `Convai/laya` |

---

## 🔄 Roteamento Hierárquico no `laya_service.py`

Para evitar a dispersão de probabilidade entre mais de 280 agentes, o serviço adota uma estratégia de dois passos:

1. **Passo 1 (Macro):** Classifica a demanda em um dos 6 clusters principais:
   - `backend`, `frontend`, `database`, `security`, `qa_testing`, `devops_infra`.
2. **Passo 2 (Micro):** Seleciona o subagente especialista dentro do cluster.
3. **Comando Gerado:** Retorna a string pronta de despacho para o Orca:
   `orca orchestration worker-start --agent "<Agente>" --spec "<Demanda>"`
