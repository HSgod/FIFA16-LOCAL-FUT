# FIFA 16 Local FUT — Offline Ultimate Team Restoration

Kompletne środowisko przywracające tryb **FIFA 16 Ultimate Team (FUT 16)** do działania w trybie lokalnym / offline (localhost) na komputerze PC.

Projekt oparty na architekturze emulatorów serwerów FUT (Blaze 3 Fire2, GOS Redirector, EASW oraz REST API FUT), wzbogacony o bazę danych ponad 23 000 kart z sezonu FIFA 16 i  symulację rynku transferowego (AI Market).

---

## 🚀 Szybki start (Instalacja krok po kroku)

1. **Wymagania wstępne:**
   * Uruchom plik **`INSTALL_PREREQUISITES.cmd`**.
   * Skrypt sprawdzi lub zainstaluje Pythona 3.10+, bibliotekę `cryptography` oraz biblioteki Visual C++.

2. **Instalacja i pierwsze uruchomienie (Windows):**
   * Uruchom **`PLAY_LOCAL_FUT16.cmd`**.
   * Skrypt automatycznie:
     1. Wykryje folder z zainstalowaną grą FIFA 16 (lub poprosi o wskazanie folderu zawierającego `fifa16.exe`).
     2. Uruchomi skaner **`find_fifa16_offsets.py`**, który przeskanuje Twój plik `fifa16.exe`, znajdzie funkcję sieciową `ProtoSSLConnect` i wygeneruje poprawną konfigurację `EA-MITM.ini`.
     3. Wykona kopię zapasową podmienianych plików do `%LOCALAPPDATA%\FIFA16LocalFUT\install-backup\`.
     4. Wgra pliki patcha i serwera do folderu gry.
     5. Utworzy skrót na Pulpicie: **FIFA 16 Local FUT**.
     6. Uruchomi lokalny serwer i włączy grę FIFA 16.

3. **Uruchomienie na macOS (CrossOver / Wine):**
   * Ponieważ Wine na macOS dzieli stos sieciowy (`localhost / 127.0.0.1`) bezpośrednio z macOS, serwer FUT uruchamia się natywnie w macOS Terminalu bez obciążania Wine i bez problemów z oknami CMD:
     1. Uruchom skrypt konfiguracyjny (wykryje butelkę CrossOver i wgra biblioteki):
        `./SETUP_CROSSOVER_MAC.sh`
     2. Uruchom serwer FUT na macOS, klikając dwukrotnie:
        **`START_SERVER_MAC.command`**
     3. Otwórz CrossOver i uruchom grę FIFA 16 jak zwykle.
     4. W menu gry wejdź w **Ultimate Team** – gra połączy się z lokalnym serwerem.
     5. Aby dodać monety na macOS: kliknij dwukrotnie **`ADD_COINS_MAC.command`**.
     6. Aby zresetować klub na macOS: kliknij dwukrotnie **`RESET_CLUB_MAC.command`**.

4. **Kolejne uruchomienia:**
   * **Windows:** Uruchamiaj bezpośrednio ze skrótu na Pulpicie **FIFA 16 Local FUT** lub `PLAY_LOCAL_FUT16.cmd`.
   * **macOS:** Kliknij dwukrotnie **`START_SERVER_MAC.command`**, a następnie włącz FIFA 16 w CrossOver.

---

## ⚽ Co zawiera i co działa w FIFA 16 Local FUT?

* **Lokalny klub FUT:** Tworzenie klubu, wybór nazwy, skrótu, herbów, strojów i stadionu.
* **Baza kart FIFA 16:** Ponad 23 000 zawodników z oryginalnymi ocenami, statystykami karty (tempo, strzały, podania, drybling, obrona, fizyczność), klubami i ligami z sezonu 2015/2016 (w tym karty brązowe, srebrne, złote, TOTW, TOTY, TOTS, Hero, MOTM).
* **Sklep i paczki (Store & Packs):** Otwieranie paczek brązowych, srebrnych, złotych, Jumbo, Premium i paczek promocyjnych z animacjami otwierania.
* **Rynek transferowy (AI Transfer Market):** Pełny rynek transferowy symulowany przez silnik offline – możliwość wyszukiwania kart, licytacji, opcji "Kup teraz", a także wirtualni kupcy AI, którzy skupują wystawione przez Ciebie karty w rozsądnych cenach.
* **Zarządzanie składem:** Tworzenie wielu składów, zgranie (chemistry), pozycje, rezerwowi, zmiana formacji, kontrakty i kondycja.
* **Sezony jednego gracza i turnieje offline:** Rozgrywanie meczów przeciwko sztucznej inteligencji, nagrody monetowe za mecze, awanse i spadki w ligach.
* **Tryb FUT Draft (Single Player Draft):** Budowanie składu draftu (wybór formacji, kapitana, 23 zawodników i menedżera) oraz walka o nagrody w drabince turniejowej.
* **Zapis stanu gry:** Stan klubu, karty, lista transferowa i monety są bezpiecznie zapisywane lokalnie w bazie SQLite:
  `%LOCALAPPDATA%\FIFA16LocalFUT\fut16-local.sqlite3`

---

## 💰 Dodawanie monet (Kredyty FUT)

Chcesz przetestować drogie paczki lub najlepsze karty?
* **macOS:** Kliknij dwukrotnie [`macos/ADD_COINS_MAC.command`].
* **Windows:** Uruchom [`windows/ADD_COINS.cmd`].

---

## 🔄 Reset klubu do stanu początkowego

Jeśli chcesz zacząć zabawę od zera z podstawowym składem startowym:
* **macOS:** Kliknij dwukrotnie [`macos/RESET_CLUB_MAC.command`].
* **Windows:** Uruchom [`windows/RESET_TO_STARTER_CLUB.cmd`].

---

## 📁 Struktura plików

### 🍏 macOS (`macos/`)
Dedykowane narzędzia do gry na komputerach Mac (CrossOver / Wine):
* **`START_SERVER_MAC.command`** — Uruchamia lokalny serwer FUT w Terminalu macOS (wystarczy dwuklik).
* **`SETUP_CROSSOVER_MAC.sh`** — Automatyczny instalator dla CrossOver (ustawia `cl.ini` oraz `etc/hosts` w butelce).
* **`ADD_COINS_MAC.command`** — Dodawanie monet do klubu.
* **`RESET_CLUB_MAC.command`** — Reset bazy danych klubu.
* **`README_MACOS.md`** — Instrukcja dla macOS.

### 🪟 Windows (`windows/`)
Dedykowane narzędzia dla natywnego systemu Windows (bez uprawnień administratora):
* **`INSTALL_PREREQUISITES.cmd`** — Instalator Pythona i biblioteki cryptography w profilu użytkownika.
* **`PLAY_LOCAL_FUT16.cmd`** — Główny instalator i launcher gry na Windowsie.
* **`START_LOCAL_FUT16.cmd`** — Samodzielny start lokalnego serwera FUT.
* **`STOP_LOCAL_FUT16.cmd`** — Bezpieczne zatrzymanie serwera działającego w tle.
* **`ADD_COINS.cmd`** — Dodawanie monet.
* **`RESET_TO_STARTER_CLUB.cmd`** — Reset klubu.
* **`LOCAL_FUT_STATUS.cmd`** — Status portów i serwera.
* **`PORT_DIAGNOSTICS.cmd`** — Diagnostyka blokowania portów.
* **`RESTORE_BACKUP.cmd`** — Przywracanie oryginalnych plików z backupu.
* **`README_WINDOWS.md`** — Instrukcja dla Windows.

### 📦 Wspólne (Core)
* **`START_SERVER_MAC.command`** — Szybki skrót startowy serwera w folderze głównym.
* **`PLAY_LOCAL_FUT16.cmd`** — Szybki skrót instalatora Windows w folderze głównym.
* **`payload/`** — Serwer FUT w Pythonie (`server.py`), bazy kart (`players.json`), certyfikaty SSL (`tls/`), pakiety, grafiki i trofea.
* **`add_coins.py`** — Uniwersalny skrypt SQLite do edycji monet.
* **`find_fifa16_offsets.py`** — Narzędzie do analizy nagłówków PE pliku wykonywalnego gry.