# Orquestração Supervisionada com Orca CLI

O **Orca (StablyAI)** atua como a infraestrutura física de execução, multiplexação de terminais e controle de *worktrees* na Asimov Stack.

Enquanto o **Claude Code** opera como o **Maestro (Coordenador & Juiz)**, o Orca fornece o motor determinístico para despachar, isolar e monitorar tarefas paralelas.

---

## 🛠️ Comandos Centrais do Ciclo de Orquestração

### 1. Criar uma Run (Namespace da Demanda)
```bash
orca orchestration run-create --objective "Implementar Feature X" --json
```

### 2. Despachar um Worker em Worktree Isolado
```bash
# Cria o task e o dispatch em um único comando
orca orchestration worker-start \
  --spec "Criar rotas de autenticação JWT com FastAPI" \
  --agent claude \
  --worktree current \
  --json
```

### 3. Monitorar a Conclusão dos Workers
```bash
# Aguarda de forma síncrona/bloqueante até a chegada do evento worker_done
orca orchestration check --wait --types "worker_done,escalation,question" --timeout-ms 300000 --json
```

### 4. Responder Dúvidas de Workers (Ask/Reply Loop)
```bash
orca orchestration reply --id <message_id> --body "Use a tabela users do schema auth" --json
```

### 5. Liberar Recursos e Limpar Terminais
```bash
# Após aceitar a entrega do worker
orca orchestration worker-release --dispatch <dispatch_id> --json
```

---

## 🔒 Princípios de Segurança e Isolamento

1. **Isolamento via Git Worktree:** Cada worker opera em seu próprio checkout temporário, prevenindo conflitos em arquivos concorrentes.
2. **Proteção de Contexto do Maestro:** O Claude Code Coordenador não lê o histórico de digitação ou o código intermediário do worker — ele recebe apenas o resumo executivo e os arquivos modificados via payload do `worker_done`.
3. **Auditoria Obrigatória (Juiz):** O Maestro só aceita a entrega se os critérios de aceitação passarem nos testes (`[Passo] -> verify: [check]`).
