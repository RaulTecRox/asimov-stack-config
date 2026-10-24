"""
Laya Decision Service — MCP Wrapper (FastMCP)

Expondo a Laya como um servidor MCP oficial (SSE/Streamable-HTTP).
Isso permite que Claude Code, OpenClaw, Orca e outros agentes
usem a Laya nativamente como tool MCP.

Endpoints MCP expostos:
- GET  /health           → Health check
- POST /mcp              → MCP protocol endpoint (tools/list, tools/call)
- GET  /mcp/sse          → SSE endpoint para conexões persistentes
"""

from fastmcp import FastMCP
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import time

# Reutiliza a lógica de roteamento do laya_service.py
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

class RouteRequest(BaseModel):
    text: str = Field(..., description="Texto da demanda/pedido do usuário")
    context_json: Optional[Dict[str, Any]] = Field(None, description="Contexto adicional opcional")

class RouteResponse(BaseModel):
    status: str
    route: Dict[str, Any]
    orchestration: Dict[str, Any]
    performance: Dict[str, Any]

def simulate_laya_choice(text: str, options: Dict[str, Dict]):
    """Simula o comportamento do modelo de decisão não-autorregressivo (Laya)."""
    scores = {}
    text_lower = text.lower()
    for key, data in options.items():
        match_count = sum(1 for kw in data["keywords"] if kw in text_lower)
        scores[key] = 0.1 + (match_count * 0.2)
    total = sum(scores.values())
    probs = {k: v/total for k, v in scores.items()}
    selected = max(probs, key=probs.get)
    return {"selected": selected, "probabilities": probs, "confidence": probs[selected]}

def simulate_specialist_choice(text: str, agents: List[str]):
    """Simula a escolha do subagente dentro do cluster selecionado."""
    text_lower = text.lower()
    agent_scores = {}
    for agent in agents:
        agent_scores[agent] = 0.5 + (0.5 if any(p in text_lower for p in agent.lower().split()) else 0)
    total = sum(agent_scores.values())
    probs = {k: v/total for k, v in agent_scores.items()}
    selected = max(probs, key=probs.get)
    return {"selected": selected, "confidence": probs[selected]}

# ===== FastMCP Server =====
mcp = FastMCP("Laya Decision Service (System 1)")

@mcp.tool
def route_agent(request: RouteRequest) -> RouteResponse:
    """
    Roteia uma demanda para o agente especialista ideal via roteamento hierárquico (System 1).

    Usa o modelo de decisão Laya (Convai Innovations) para triagem em ~33ms:
    1. Macro-cluster: backend, frontend, database, security, qa_testing, devops_infra
    2. Micro-agente: seleciona o especialista dentro do cluster
    3. Retorna comando de orquestração Orca pronto para execução
    """
    start_time = time.time()

    # 1. Roteamento Macro (Cluster)
    cluster_decision = simulate_laya_choice(request.text, ROSTER_CLUSTERS)
    cluster_name = cluster_decision["selected"]

    # 2. Roteamento Micro (Agente Especialista)
    specialist_decision = simulate_specialist_choice(request.text, ROSTER_CLUSTERS[cluster_name]["agents"])
    agente = specialist_decision["selected"]

    latency = (time.time() - start_time) * 1000

    return RouteResponse(
        status="success",
        route={
            "cluster": cluster_name,
            "agent": agente,
            "confidence": round(specialist_decision["confidence"], 3)
        },
        orchestration={
            "command": f'orca orchestration worker-start --agent "{agente}" --spec "{request.text[:50]}..."',
            "task_objective": request.text[:80] + "..." if len(request.text) > 80 else request.text
        },
        performance={
            "latency_ms": round(latency, 2),
            "model": "laya-hierarchical-v1"
        }
    )

@mcp.tool
def health_check() -> Dict[str, str]:
    """Health check do serviço Laya Decision Service."""
    return {"status": "alive", "engine": "Laya Simulator (MCP)"}

@mcp.tool
def list_clusters() -> Dict[str, List[str]]:
    """Lista todos os clusters de agentes disponíveis no roster da Laya."""
    return {cluster: data["agents"] for cluster, data in ROSTER_CLUSTERS.items()}

if __name__ == "__main__":
    import sys
    # Suporta tanto SSE (para daemon/background) quanto stdio (para MCP direto)
    if "--stdio" in sys.argv:
        mcp.run(transport="stdio")
    else:
        mcp.run(transport="sse", host="127.0.0.1", port=8000)