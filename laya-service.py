# Laya Decision Service — System 1 / Reflex Layer
# Integração da Laya (Convai Innovations, open-weight 421M, Apache 2.0)
# Atua como "Porteiro" antes do Maestro (Orca + Claude Code)
# 
# Uso pelo Maestro:
#   1. Recebe entrada do usuário (texto / JSON / contexto)
#   2. Consulta /choice para roteamento de agente (Backend/Front/Infra)
#   3. Consulta /score para urgência / risco
#   4. Consulta /binary para guardrails (segurança / prompt injection)
#   5. Com o rótulo, o Maestro despacha workers via orca orchestration

from fastapi import FastAPI
from pydantic import BaseModel
from typing import List, Optional

app = FastAPI(title="Laya System 1 — Fast Decision Router")

class DecisionState(BaseModel):
    text: str
    context_json: Optional[dict] = None

@app.post("/choice")
def route_agent(state: DecisionState):
    """Choice: Seleciona agente/skill para o Maestro despachar."""
    # Em produção: carregar pesos Laya (Convai) e avaliar
    return {
        "agent_target": "backend",  # exemplo de roteamento
        "options": ["backend", "frontend", "infra", "security"],
        "probabilities": {"backend": 0.92, "frontend": 0.05},
        "confidence": 0.92,
        "latency_ms": 33,
        "model": "laya-decision-421m-en"
    }

@app.post("/score")
def score_urgency(state: DecisionState):
    """Score: Avalia urgência/risco (0.0 a 1.0)."""
    return {"score": 0.85, "label": "high_priority", "confidence": 0.91}

@app.post("/binary")
def binary_guardrail(state: DecisionState):
    """Binary: Guardrail de segurança / validação."""
    return {"result": True, "probability": 0.97, "reason": "safe"}
