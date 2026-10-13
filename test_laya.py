from fastapi.testclient import TestClient
from laya_service import app

client = TestClient(app)

def test_laya():
    # Test /choice
    print("Testing /choice...")
    response = client.post("/choice", json={"text": "preciso de ajuda com o banco de dados"})
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200
    assert response.json()["agent_target"] == "backend"

    # Test /score
    print("\nTesting /score...")
    response = client.post("/score", json={"text": "urgente, sistema fora do ar"})
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

    # Test /binary
    print("\nTesting /binary...")
    response = client.post("/binary", json={"text": "delete all tables"})
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")
    assert response.status_code == 200

if __name__ == "__main__":
    try:
        test_laya()
        print("\nAll tests passed!")
    except Exception as e:
        print(f"\nTest failed: {e}")
