#!/bin/bash
set -euo pipefail

# ==============================================================================
# FIFA 16 — CrossOver macOS (Apple Silicon / Rosetta 2) Patch Installer
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FIXES_DIR="$SCRIPT_DIR/fixes"
TARGET_APP=""
TARGET_BOTTLE="FIFA16"
SKIP_SIGN=0

usage() {
    cat << EOF
Sposób użycia:
  $0 [opcje]

Opcje:
  --app <ścieżka>       Ścieżka do aplikacji CrossOver (np. /Applications/CrossOver.app)
  --bottle <nazwa>      Nazwa butelki w CrossOver (domyślnie: FIFA16)
  --skip-sign           Pomiń ponowne podpisywanie aplikacji codesign
  -h, --help            Wyświetl tę pomoc

EOF
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --app)
            TARGET_APP="$2"
            shift 2
            ;;
        --bottle)
            TARGET_BOTTLE="$2"
            shift 2
            ;;
        --skip-sign)
            SKIP_SIGN=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Nieznana opcja: $1"
            usage
            ;;
    esac
done

echo "============================================================"
echo "  FIFA 16 — PATCH DLA CROSSOVER (APPLE SILICON / MACOS)"
echo "============================================================"
echo ""

# 1. Wykrywanie aplikacji CrossOver
if [ -z "$TARGET_APP" ]; then
    if [ -d "/Applications/CrossOver-FIFA.app" ]; then
        TARGET_APP="/Applications/CrossOver-FIFA.app"
    elif [ -d "/Applications/CrossOver.app" ]; then
        TARGET_APP="/Applications/CrossOver.app"
    else
        echo "❌ BŁĄD: Nie znaleziono aplikacji CrossOver w /Applications."
        echo "   Wskaż ścieżkę ręcznie za pomocą: $0 --app /ścieżka/do/CrossOver.app"
        exit 1
    fi
fi

if [ ! -d "$TARGET_APP" ]; then
    echo "❌ BŁĄD: Wskazana aplikacja nie istnieje: $TARGET_APP"
    exit 1
fi

WINE_DIR="$TARGET_APP/Contents/SharedSupport/CrossOver/lib/wine"
if [ ! -d "$WINE_DIR" ]; then
    echo "❌ BŁĄD: Nieprawidłowa struktura CrossOver (brak $WINE_DIR)."
    exit 1
fi

echo "✔ Wykryto CrossOver: $TARGET_APP"

# 2. Wgrywanie patchy do CrossOver (ntdll.so + gdiplus.dll)
echo ""
echo "1. Instalacja spatchowanych bibliotek Wine..."

NTDLL_SRC="$FIXES_DIR/x86_64-unix/ntdll.so"
NTDLL_DST="$WINE_DIR/x86_64-unix/ntdll.so"
GDIPLUS_SRC="$FIXES_DIR/x86_64-windows/gdiplus.dll"
GDIPLUS_DST="$WINE_DIR/x86_64-windows/gdiplus.dll"

if [ ! -f "$NTDLL_SRC" ] || [ ! -f "$GDIPLUS_SRC" ]; then
    echo "❌ BŁĄD: Brak plików w $FIXES_DIR."
    exit 1
fi

# Kopia zapasowa oryginalnych plików
if [ ! -f "$NTDLL_DST.orig" ]; then
    echo "   Tworzenie kopii zapasowej oryginalnego ntdll.so..."
    cp -p "$NTDLL_DST" "$NTDLL_DST.orig"
fi

if [ ! -f "$GDIPLUS_DST.orig" ]; then
    echo "   Tworzenie kopii zapasowej oryginalnego gdiplus.dll..."
    cp -p "$GDIPLUS_DST" "$GDIPLUS_DST.orig"
fi

echo "   Wgrywanie ntdll.so (obsługa CX_TOPDOWN_LIMIT)..."
cp -f "$NTDLL_SRC" "$NTDLL_DST"

echo "   Wgrywanie gdiplus.dll (poprawka font collection)..."
cp -f "$GDIPLUS_SRC" "$GDIPLUS_DST"

echo "✔ Pliki skopiowane pomyślnie."

# 3. Podpisywanie kodem (codesign)
if [ "$SKIP_SIGN" -eq 0 ]; then
    echo ""
    echo "2. Podpisywanie aplikacji kodem (codesign + uprawnienia Rosetta)..."
    
    # Podpisanie pliku ntdll.so
    codesign --force --sign - "$NTDLL_DST" 2>/dev/null || true
    
    # Wyciągnięcie i uzupełnienie entitlements
    ENT_PLIST=$(mktemp -t cx_ent).plist
    codesign -d --entitlements :- "$TARGET_APP" > "$ENT_PLIST" 2>/dev/null || true
    
    if [ ! -s "$ENT_PLIST" ]; then
        cat << 'EOF' > "$ENT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <true/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <true/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <true/>
</dict>
</plist>
EOF
    else
        # Upewnienie się, że disable-library-validation jest obecne
        if ! grep -q "disable-library-validation" "$ENT_PLIST"; then
            sed -i '' -e 's|</dict>|    <key>com.apple.security.cs.disable-library-validation</key><true/>\n</dict>|' "$ENT_PLIST"
        fi
    fi
    
    codesign --force --sign - -o runtime --entitlements "$ENT_PLIST" "$TARGET_APP" 2>/dev/null || {
        echo "⚠️ Ostrzeżenie: Nie udało się automatycznie podpisać całej aplikacji CrossOver."
        echo "   Jeśli macOS zgłosi błąd uszkodzenia aplikacji, włącz 'App Management' w Ustawieniach macOS dla Terminala."
    }
    rm -f "$ENT_PLIST"
    echo "✔ Podpisano aplikację."
fi

# 4. Konfiguracja butelki w CrossOver
BOTTLE_DIR="$HOME/Library/Application Support/CrossOver/Bottles/$TARGET_BOTTLE"
CONF_FILE="$BOTTLE_DIR/cxbottle.conf"

echo ""
echo "3. Konfiguracja butelki CrossOver ($TARGET_BOTTLE)..."

if [ -f "$CONF_FILE" ]; then
    python3 -c '
import sys, re

path = "'"$CONF_FILE"'"
with open(path, "r", encoding="utf-8", errors="ignore") as f:
    content = f.read()

# 1. Ensure [CrossOver] AntiVirusScan = never
if "[CrossOver]" in content:
    if "AntiVirusScan" not in content:
        content = content.replace("[CrossOver]", "[CrossOver]\n\"AntiVirusScan\" = \"never\"")
else:
    content += "\n[CrossOver]\n\"AntiVirusScan\" = \"never\"\n"

# 2. Ensure [EnvironmentVariables]
env_vars = {
    "CX_GRAPHICS_BACKEND": "d3dmetal",
    "WINE_SIMULATE_WRITECOPY": "1",
    "CX_TOPDOWN_LIMIT": "0x1ffffffff",
    "WINE_COREAUDIO_EXCLUDE": "Microsoft Teams Audio",
}

if "[EnvironmentVariables]" not in content:
    content += "\n[EnvironmentVariables]\n"

for k, v in env_vars.items():
    pattern = rf"^\s*\"{k}\"\s*=.*$"
    replacement = f"\"{k}\" = \"{v}\""
    if re.search(pattern, content, flags=re.MULTILINE):
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE)
    else:
        content = content.replace("[EnvironmentVariables]", f"[EnvironmentVariables]\n{replacement}")

# Ensure CX_DR_TRAP is removed / disabled for FIFA 16
content = re.sub(r"^\s*\"CX_DR_TRAP\"\s*=.*$\n?", "", content, flags=re.MULTILINE)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
'
    echo "✔ Zaktualizowano cxbottle.conf (d3dmetal, simulate_writecopy, topdown_limit=0x1ffffffff, cxavscan disabled)."
else
    echo "ℹ️ Butelka $TARGET_BOTTLE jeszcze nie istnieje lub brak cxbottle.conf."
    echo "   Ustawienia zostaną zastosowane po utworzeniu butelki."
fi

# 5. Konfiguracja trybu okienkowego w Documents
FIFA_SETUP_DIR="$HOME/Documents/FIFA 16"
FIFA_INI="$FIFA_SETUP_DIR/fifasetup.ini"
if [ -f "$FIFA_INI" ]; then
    echo ""
    echo "4. Konfiguracja fifasetup.ini..."
    if grep -q "FULLSCREEN" "$FIFA_INI"; then
        sed -i '' -e 's/FULLSCREEN = .*/FULLSCREEN = 0/' "$FIFA_INI"
    else
        echo "FULLSCREEN = 0" >> "$FIFA_INI"
    fi
    echo "✔ Ustawiono tryb okienkowy (FULLSCREEN = 0) w $FIFA_INI."
fi

echo ""
echo "============================================================"
echo "✔ INSTALACJA PATCHA DLA CROSSOVER ZAKOŃCZONA SUKCESEM!"
echo "============================================================"
echo ""
echo "UWAGA DOTYCZĄCA CRACKA DELUSIONAL DLA FIFA 16:"
echo "Jeżeli Twoja gra zawiesza się na ekranie wyboru języka / startowym,"
echo "upewnij się, że posiadasz zaktualizowaną wersję cracka: CrackFix V3"
echo "(FIFA.16.CrackFix.V3-DELUSIONAL), która zawiera poprawkę dla procesorów ARM64."
echo ""
