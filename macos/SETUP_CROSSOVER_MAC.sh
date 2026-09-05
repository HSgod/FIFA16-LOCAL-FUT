#!/bin/bash
set -e
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

echo "============================================================"
echo " FIFA 16 LOCAL FUT — INSTALATOR DLA CROSSOVER (MACOS)"
echo "============================================================"
echo ""

BOTTLES_ROOT="$HOME/Library/Application Support/CrossOver/Bottles"
TARGET_BOTTLE="$BOTTLES_ROOT/FIFA16"

if [ ! -d "$TARGET_BOTTLE" ]; then
    echo "Szukanie butelek CrossOver z FIFA 16..."
    FOUND_EXE=$(find "$BOTTLES_ROOT" -iname "fifa16.exe" 2>/dev/null | head -n 1 || true)
    if [ -n "$FOUND_EXE" ]; then
        GAME_DIR=$(dirname "$FOUND_EXE")
        TARGET_BOTTLE=$(echo "$FOUND_EXE" | awk -F'/drive_c/' '{print $1}')
    else
        echo "ERROR: Nie znaleziono butelki z FIFA 16 w $BOTTLES_ROOT"
        echo "Upewnij sie, ze zainstalowales FIFA 16 w CrossOver."
        exit 1
    fi
else
    if [ -f "$TARGET_BOTTLE/drive_c/Games/FIFA 16/fifa16.exe" ]; then
        GAME_DIR="$TARGET_BOTTLE/drive_c/Games/FIFA 16"
    else
        FOUND_EXE=$(find "$TARGET_BOTTLE/drive_c" -iname "fifa16.exe" 2>/dev/null | head -n 1 || true)
        if [ -n "$FOUND_EXE" ]; then
            GAME_DIR=$(dirname "$FOUND_EXE")
        else
            echo "ERROR: Nie znaleziono fifa16.exe w butelce $TARGET_BOTTLE"
            exit 1
        fi
    fi
fi

echo "Wykryto butelke CrossOver: $TARGET_BOTTLE"
echo "Wykryto folder gry FIFA 16: $GAME_DIR"
echo ""

echo "1. Konfiguracja cl.ini dla silnika gry FIFA 16..."
cp -f payload/cl.ini "$GAME_DIR/"
cp -f payload/ItsAMe_Origin.dll "$GAME_DIR/" 2>/dev/null || true

# Usuniecie starego dinput8.dll (powodujacego Failed to initialize ProtoSSL)
if [ -f "$GAME_DIR/dinput8.dll" ]; then
    echo "   Usuwanie niekompatybilnego dinput8.dll z folderu gry..."
    rm -f "$GAME_DIR/dinput8.dll"
fi

echo ""
echo "2. Konfiguracja przekierowan domen EA w butelce CrossOver (etc/hosts)..."
BOTTLE_HOSTS="$TARGET_BOTTLE/drive_c/windows/system32/drivers/etc/hosts"
mkdir -p "$(dirname "$BOTTLE_HOSTS")"
cat << 'EOF' > "$BOTTLE_HOSTS"
# Local FUT 16 Redirection
127.0.0.1 localhost
127.0.0.1 winter15.gosredirector.ea.com
127.0.0.1 winter15.gosredirector.sdev.ea.com
127.0.0.1 winter15.gosredirector.stest.ea.com
127.0.0.1 winter15.gosredirector.scert.ea.com
127.0.0.1 spring15.gosredirector.ea.com
127.0.0.1 spring14.gosredirector.ea.com
127.0.0.1 gosredirector.ea.com
127.0.0.1 easw.easports.com
127.0.0.1 fifa16.content.easports.com
EOF
echo "   Zaktualizowano plik hosts w butelce CrossOver!"

echo ""
echo "3. Czyszczenie starych override w rejestrze Wine (user.reg)..."
USER_REG="$TARGET_BOTTLE/user.reg"
if [ -f "$USER_REG" ]; then
    python3 -c '
import sys
path = "'"$USER_REG"'"
with open(path, "r", encoding="utf-8", errors="ignore") as f:
    lines = f.readlines()
new_lines = [l for l in lines if "\"dinput8\"" not in l]
with open(path, "w", encoding="utf-8") as f:
    f.writelines(new_lines)
'
    echo "   Rejestr Wine zostal oczyszczony."
fi

echo ""
echo "============================================================"
echo " INSTALACJA DLA CROSSOVER ZAKONCZONA POMYSLNIE!"
echo "============================================================"
echo ""
echo "JAK GRAC:"
echo " 1. Uruchom serwer na Macu, klikajac dwukrotnie w:"
echo "    START_SERVER_MAC.command"
echo "    (otworzy sie okno Terminala z dzialajacym serwerem)"
echo ""
echo " 2. Wlacz gre FIFA 16 w CrossOver tak jak zwykle."
echo ""
echo " 3. W menu gry wybierz 'Ultimate Team' — polaczy sie z serwerem lokalnym!"
echo "============================================================"
