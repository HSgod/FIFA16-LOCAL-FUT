#!/bin/bash
cd "$(dirname "$0")"

echo "============================================================"
echo " FIFA 16 LOCAL FUT — RESET KLUBU DO POCZATKU"
echo "============================================================"
echo "UWAGA: To usunie lokalny zapis klubu FUT w SQLite."
echo ""
read -p "Wpisz RESET aby potwierdzic: " CONFIRM

if [ "$CONFIRM" = "RESET" ]; then
    DB_PATH="$HOME/AppData/Local/FIFA16LocalFUT/fut16-local.sqlite3"
    rm -f "$DB_PATH" "$DB_PATH-wal" "$DB_PATH-shm"
    echo ""
    echo "Klub zresetowany pomyslnie!"
    echo "Przy kolejnym uruchomieniu serwer wygeneruje nowy, poczatkowy sklad brazowy."
else
    echo "Anulowano."
fi
echo ""
read -p "Nacisnij Enter, aby zamknac..."
