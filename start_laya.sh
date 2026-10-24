#!/usr/bin/env bash
# Start Laya Decision Service in background or foreground
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$DIR"

# Check if Python is available
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    PYTHON_CMD="python"
fi

# Check if port 8000 is already in use
if lsof -Pi :8000 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo "[LAYA] Service already running on port 8000."
    exit 0
fi

echo "[LAYA] Starting Laya Decision Service (System 1) on http://127.0.0.1:8000..."
nohup $PYTHON_CMD laya_service.py > laya.log 2>&1 &
PID=$!
echo "[LAYA] Started with PID $PID. Logs at $DIR/laya.log"
