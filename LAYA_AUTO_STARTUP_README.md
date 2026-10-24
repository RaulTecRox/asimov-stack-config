# Laya Decision Service — Auto Startup Configuration

Este documento descreve como configurar o serviço Laya para iniciar automaticamente no boot/login do Windows.

## Estado Atual

- ✅ **Código implementado**: `laya_service.py` (FastAPI em porta 8000)
- ✅ **Script de inicialização**: `start_laya.cmd` (verifica porta + sobe Uvicorn)
- ✅ **Testes**: `test_laya.py` (TestClient FastAPI)
- ✅ **MCP Wrapper**: `laya_mcp.py` (FastMCP SSE em porta 8000)
- ❌ **Inicialização automática**: Pendente configuração manual (ver opções abaixo)

---

## Opção 1: Agendador de Tarefas — Sistema (SYSTEM) — Recomendado para Servidor

**Requer Administrador.** Roda na inicialização do sistema (antes de qualquer login).

```cmd
cd C:\Users\raul.guimaraes\projects\asimov-stack-config
create_laya_autostart.cmd
```

**O que faz:**
- `/sc onstart` → Executa na **inicialização do sistema** (antes do login de qualquer usuário)
- `/ru SYSTEM` → Executa como conta **SYSTEM** (não depende de login)
- `/rl HIGHEST` → Privilégios elevados
- `/f` → Força sobrescrita se já existir

### Para remover/atualizar:
```cmd
schtasks /delete /tn "LayaMCPService" /f
create_laya_autostart.cmd
```

### Verificar status:
```cmd
schtasks /query /tn "LayaMCPService" /v /fo LIST
```

---

## Opção 2: Pasta de Inicialização do Usuário (Mais simples — Só após login)

Se preferir não lidar com Agendador de Tarefas, crie um atalho na pasta de Startup:

1. `Win + R` → digite `shell:startup` → Enter
2. Clique com botão direito → Novo → Atalho
3. Local: `C:\Users\raul.guimaraes\projects\asimov-stack-config\start_laya_mcp.cmd`
4. Nome: `Laya Decision Service (MCP)`

**Ou use o script VBS já criado (executa silencioso, sem janela CMD):**
```
C:\Users\raul.guimaraes\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\laya_mcp_startup.vbs
```
(Já criado — só testar com duplo-clique)

---

## Opção 3: NSSM (Non-Sucking Service Manager) — Serviço Windows Real

Se quiser um serviço Windows completo com recuperação automática, logs de eventos, etc:

1. Baixe NSSM: https://nssm.cc/download
2. Extraia e coloque `nssm.exe` em PATH (ex: `C:\Windows\`)
3. Execute como Admin:

```cmd
nssm install LayaDecisionService
# Na GUI:
# Path: C:\Users\raul.guimaraes\AppData\Local\Programs\Python\Python312\python.exe
# Startup directory: C:\Users\raul.guimaraes\projects\asimov-stack-config
# Arguments: -m uvicorn laya_service:app --host 127.0.0.1 --port 8000
# Service name: LayaDecisionService
# Display name: Laya Decision Service (System 1)
# Description: Asimov Stack - System 1 Reflex Layer (Agent Router)
```

```cmd
nssm set LayaDecisionService AppStdout C:\Users\raul.guimaraes\projects\asimov-stack-config\laya.log
nssm set LayaDecisionService AppStderr C:\Users\raul.guimaraes\projects\asimov-stack-config\laya.log
nssm set LayaDecisionService AppRotateFiles 1
nssm start LayaDecisionService
```

---

## Verificação Pós-Instalação

Após configurar e reiniciar (ou logar), teste:

```cmd
curl http://127.0.0.1:8000/health
# Esperado: {"status":"alive","engine":"Laya Simulator"}

curl -X POST http://127.0.0.1:8000/route-agent -H "Content-Type: application/json" -d "{\"text\":\"preciso de ajuda com backend\"}"
# Esperado: JSON com cluster="backend", agente="Backend Architect" etc.
```

---

## ✅ MCP Wrapper Implementado

`laya_mcp.py` está implementado e funcionando como servidor MCP (SSE em `http://127.0.0.1:8000/sse`).

Ferramentas MCP expostas:
- `health_check` → status do serviço
- `route_agent` → roteamento hierárquico da Laya (cluster + agente especialista + comando Orca)
- `list_clusters` → lista todos os clusters e agentes do roster

Clientes MCP (Claude Code, OpenClaw, Orca) conectam via:
```
http://127.0.0.1:8000/sse
```

Exemplo de chamada via FastMCP client:
```python
from fastmcp import Client
async with Client("http://127.0.0.1:8000/sse") as client:
    result = await client.call_tool("route_agent", {"request": {"text": "preciso de ajuda com backend"}})
```

---

## Arquivos Relacionados

| Arquivo | Função |
|---|---|
| `laya_service.py` | API FastAPI principal (porta 8000) |
| `laya_mcp.py` | **MCP Wrapper (FastMCP SSE)** — porta 8000/sse |
| `start_laya.cmd` | Script de inicialização Windows (verifica porta + sobe) |
| `run_laya_daemon.py` | Script Python equivalente (health check + background) |
| `test_laya.py` | Testes automatizados (TestClient) |
| `laya.log` | Logs do Uvicorn (append-only) |

---

**Última atualização:** 2026-10-23  
**Stack:** Asimov Stack — System 1 (Reflex Layer)  
**Responsável:** Raul Guimarães