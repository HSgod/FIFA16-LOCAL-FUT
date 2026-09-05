#!/bin/bash
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "============================================================"
echo " FIFA 16 LOCAL FUT — MAC SERWER (CROSSOVER / MACOS)"
echo "============================================================"
echo ""
echo "Uruchamianie serwera FUT na macOS (localhost: 127.0.0.1)..."
echo "CrossOver / Wine laczy sie automatycznie z tym serwerem."
echo ""
echo "Aby zakonczyc dzialanie serwera, nacisnij Ctrl+C."
echo "============================================================"
echo ""

python3 payload/localfut16/server.py
