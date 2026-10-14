import subprocess
import sys
import os
import urllib.request
import time

def is_running():
    try:
        with urllib.request.urlopen("http://127.0.0.1:8000/health", timeout=1) as resp:
            return resp.status == 200
    except Exception:
        return False

def start():
    if is_running():
        print("[Laya] Servico ja esta ativo em http://127.0.0.1:8000")
        return

    print("[Laya] Iniciando Laya Decision Service em segundo plano...")
    script_dir = os.path.dirname(os.path.abspath(__file__))
    log_file = os.path.join(script_dir, "laya.log")

    with open(log_file, "a") as f:
        flags = 0x00000008 if sys.platform == "win32" else 0
        subprocess.Popen(
            [sys.executable, "-m", "uvicorn", "laya_service:app", "--host", "127.0.0.1", "--port", "8000"],
            cwd=script_dir,
            stdout=f,
            stderr=f,
            creationflags=flags
        )

    # Aguarda 1s para confirmar startup
    time.sleep(1)
    if is_running():
        print("[Laya] Sucesso: Servico ativo em http://127.0.0.1:8000")
    else:
        print("[Laya] Processo disparado. Verifique laya.log para detalhes.")

if __name__ == "__main__":
    start()
