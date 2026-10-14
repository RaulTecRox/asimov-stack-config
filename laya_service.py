"""
Laya Decision Service — System 1 / Reflex Layer
Simulação de modelo não-autorregressivo (Convai Innovations) p/ Roteamento Hierárquico.

Este serviço implementa a lógica do "Maestro" da Asimov Stack:
1. Recebe demanda do usuário.
2. Faz triagem macro (Cluster).
3. Seleciona agente especialista (Subagente).
4. Retorna comando de orquestração do Orca.
"""

from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional, Dict
import uvicorn
import time

app = FastAPI(title="Laya System 1 — Hierarchical Agent Router")

# Configuração do Roster (Clusters e Agentes extraídos de ~/.claude/agents/)
ROSTER_CLUSTERS = {
    "backend": {
        "keywords": ["api", "rota", "backend", "fastapi", "python", "server", "logic", "microservice", "arquiteto", "entidade"],
        "agents": ["Backend Architect", "arquiteto", "implementador", "fastapi-expert"]
    },
    "frontend": {
        "keywords": ["tela", "componente", "react", "nextjs", "css", "tailwind", "ui", "ux", "interface", "frontend", "visual"],
        "agents": ["Frontend Developer", "UI Designer", "react-expert", "nextjs-developer"]
    },
    "database": {
        "keywords": ["banco", "query", "sql", "postgres", "performance", "database", "migração", "schema", "db", "tabela"],
        "agents": ["Database Optimizer", "Database Reliability Engineer", "postgres-pro"]
    },
    "security": {
        "keywords": ["vulnerabilidade", "ataque", "segurança", "seguranca", "hack", "penetration", "pentest", "invasao", "injection", "audit", "security", "phishing", "leak", "secret", "autenticacao", "auth"],
        "agents": ["Security Architect", "Penetration Tester", "Application Security Engineer", "AI-Generated Code Security Auditor"]
    },
    "qa_testing": {
        "keywords": ["teste", "bug", "falha", "testar", "revisar", "review", "revisor", "coverage", "cobertura", "playwright"],
        "agents": ["testador", "revisor", "debugger", "Test Automation Engineer"]
    },
    "devops_infra": {
        "keywords": ["docker", "container", "pipeline", "ci", "cd", "deploy", "aws", "vps", "sre", "automator", "infra"],
        "agents": ["DevOps Automator", "SRE (Site Reliability Engineer)", "Cloud Security Architect"]
    }
}

class DecisionRequest(BaseModel):
    text: str
    context_json: Optional[dict] = None

def simulate_laya_choice(text: str, options: Dict[str, Dict]):
    """
    Simula o comportamento de um modelo de decisão não-autorregressivo (Laya).
    Em vez de geração LLM, calcula pontuações baseadas em vetores de densidade de keywords.
    """
    scores = {}
    text_lower = text.lower()

    for key, data in options.items():
        match_count = sum(1 for kw in data["keywords"] if kw in text_lower)
        # Score base + boost por keywords
        scores[key] = 0.1 + (match_count * 0.2)

    # Normaliza probabilidades (softmax-like)
    total = sum(scores.values())
    probs = {k: v/total for k, v in scores.items()}

    selected = max(probs, key=probs.get)
    return {
        "selected": selected,
        "probabilities": probs,
        "confidence": probs[selected]
    }

def simulate_specialist_choice(text: str, agents: List[str]):
    """Simula a escolha do subagente dentro do cluster selecionado."""
    text_lower = text.lower()
    # Lógica simples de matching de nome/função
    agent_scores = {}
    for agent in agents:
        agent_scores[agent] = 0.5 + (0.5 if any(p in text_lower for p in agent.lower().split()) else 0)

    total = sum(agent_scores.values())
    probs = {k: v/total for k, v in agent_scores.items()}
    selected = max(probs, key=probs.get)

    return {
        "selected": selected,
        "confidence": probs[selected]
    }

@app.post("/route-agent")
def route_agent(req: DecisionRequest):
    """
    Endpoint principal para o Maestro.
    Faz o roteamento hierárquico em ~70ms (simulado).
    """
    start_time = time.time()

    # 1. Roteamento Macro (Cluster)
    cluster_decision = simulate_laya_choice(req.text, ROSTER_CLUSTERS)
    cluster_name = cluster_decision["selected"]

    # 2. Roteamento Micro (Agente Especialista)
    specialist_decision = simulate_specialist_choice(req.text, ROSTER_CLUSTERS[cluster_name]["agents"])
    agente = specialist_decision["selected"]

    latency = (time.time() - start_time) * 1000

    return {
        "status": "success",
        "route": {
            "cluster": cluster_name,
            "agent": agente,
            "confidence": specialist_decision["confidence"]
        },
        "orchestration": {
            "command": f'orca orchestration worker-start --agent "{agente}" --spec "{req.text}"',
            "task_objective": req.text[:50] + "..." if len(req.text) > 50 else req.text
        },
        "performance": {
            "latency_ms": round(latency, 2),
            "model": "laya-hierarchical-v1"
        }
    }

@app.get("/health")
def health():
    return {"status": "alive", "engine": "Laya Simulator"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
