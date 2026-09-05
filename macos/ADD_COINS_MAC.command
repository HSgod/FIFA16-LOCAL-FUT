#!/bin/bash
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "============================================================"
echo " FIFA 16 LOCAL FUT — DODAWANIE MONET (MACOS / CROSSOVER)"
echo "============================================================"
echo ""
read -p "Ile monet chcesz dodac? [domyslnie 1000000]: " AMOUNT
AMOUNT=${AMOUNT:-1000000}

python3 add_coins.py "$AMOUNT"
echo ""
read -p "Nacisnij Enter, aby zamknac..."
