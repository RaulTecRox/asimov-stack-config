from fastapi.testclient import TestClient
from laya_service import app

client = TestClient(app)

TEST_CASES = [
    {
        "demanda": "Otimizar as queries lentas do PostgreSQL que estao causando timeout na API de pagamentos.",
        "expected_cluster": "database",
        "expected_agent": "Database Optimizer"
    },
    {
        "demanda": "Criar um formulario interativo de cadastro em React com Tailwind CSS e validacao Zod.",
        "expected_cluster": "frontend",
        "expected_agent": "Frontend Developer"
    },
    {
        "demanda": "Realizar teste de invasao (pentest) nas rotas de autenticacao para achar vulnerabilidade de SQL Injection.",
        "expected_cluster": "security",
        "expected_agent": "Penetration Tester"
    },
    {
        "demanda": "Escrever testes automatizados de ponta a ponta com Playwright para o fluxo de checkout.",
        "expected_cluster": "qa_testing",
        "expected_agent": "Test Automation Engineer"
    },
    {
        "demanda": "Subir o container da aplicacao no Docker e configurar a esteira de CI/CD para deploy na VPS.",
        "expected_cluster": "devops_infra",
        "expected_agent": "DevOps Automator"
    }
]

def run_tests():
    print("="*80)
    print("TESTE DE ROTEAMENTO HIERARQUICO COM LAYA DECISION SERVICE")
    print("="*80)

    passed = 0
    for i, test in enumerate(TEST_CASES, 1):
        print(f"\n[Caso {i}] Demanda: \"{test['demanda']}\"")
        response = client.post("/route-agent", json={"text": test["demanda"]})

        if response.status_code != 200:
            print(f"Erro HTTP: {response.status_code}")
            continue

        data = response.json()
        route = data["route"]
        orchestration = data["orchestration"]

        print(f"  |-> Cluster Escolhido: {route['cluster']} (Esperado: {test['expected_cluster']})")
        print(f"  |-> Agente Selecionado: {route['agent']}")
        print(f"  |-> Latencia: {data['performance']['latency_ms']}ms")
        print(f"  |-> Comando Orca: {orchestration['command']}")

        if route["cluster"] == test["expected_cluster"]:
            print("  [OK] Roteamento Correto!")
            passed += 1
        else:
            print("  [WARN] Roteamento Divergente!")

    print("\n" + "="*80)
    print(f"RESULTADO: {passed}/{len(TEST_CASES)} testes passaram com sucesso.")
    print("="*80)

if __name__ == "__main__":
    run_tests()
