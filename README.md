# FIFA 16 Local FUT

Tryb **FIFA 16 Ultimate Team (FUT 16)** do działania w trybie lokalnym / offline (localhost) na komputerach PC (**Windows**) oraz Mac (**macOS / CrossOver / Apple Silicon**).

Projekt oparty na architekturze emulatorów serwerów FUT (Blaze 3 Fire2, GOS Redirector, EASW oraz REST API FUT), wzbogacony o symulację rynku transferowego (AI Market).

---

## ⚠️ Wymagania dotyczące gry i cracka

Niezależnie od systemu operacyjnego potrzebujesz gry **FIFA 16**:
* **Rekomendowany crack:** **`FIFA.16.CrackFix.V3-DELUSIONAL`**  
  Pliki cracka (`fifa16.exe`, `fifa16.bin`, `DSN.dll`, `dbdata`, `origin_emu.dll`, `rune.ini`) powinny znajdować się bezpośrednio w głównym folderze z grą FIFA 16.
* **Dlaczego wersja V3?**  
  Pierwotny crack DELUSIONAL V1 (z kwietnia 2024 r.) zawierał błąd w hookach instrukcji `CPUID` uniemożliwiający uruchomienie gry na procesorach ARM64 (gra zawieszała się na ekranie wyboru języka podczas profilowania sprzętu na Apple Silicon pod emulacją Rosetta 2). Wersja **CrackFix V3** rozwiązuje ten problem oraz usuwa błędy trybu kariery.

---

## 🚀 Instalacja krok po kroku

Wybierz instrukcję dla swojego systemu operacyjnego:

### 🪟 Opcja A: System Windows

> [!NOTE]
> **Użytkownicy systemu Windows OMIJAJĄ wgrywanie patchy do CrossOvera!**  
> Wszystkie patche Wine (`ntdll.so`, `gdiplus.dll`, `CX_TOPDOWN_LIMIT`) są przeznaczone wyłącznie dla macOS / Wine. Na systemie Windows gra działa natywnie bez żadnych modyfikacji systemowych.

1. **Krok 1: Wymagania wstępne:**
   * Uruchom dwukrotnie plik [`windows/INSTALL_PREREQUISITES.cmd`](windows/INSTALL_PREREQUISITES.cmd) (lub skrót `INSTALL_PREREQUISITES.cmd` w folderze głównym).
   * Skrypt sprawdzi lub zainstaluje w profilu użytkownika Pythona 3.10+, bibliotekę `cryptography` oraz pakiety redystrybucyjne Visual C++.

2. **Krok 2: Instalacja i pierwsze uruchomienie:**
   * Uruchom dwukrotnie plik [`PLAY_LOCAL_FUT16.cmd`](PLAY_LOCAL_FUT16.cmd).
   * Skrypt automatycznie:
     1. Wykryje folder z zainstalowaną grą FIFA 16 (lub poprosi o wskazanie folderu zawierającego `fifa16.exe`).
     2. Uruchomi skaner [`find_fifa16_offsets.py`](find_fifa16_offsets.py), który przeskanuje plik `fifa16.exe`, znajdzie funkcję sieciową `ProtoSSLConnect` i wygeneruje poprawną konfigurację `EA-MITM.ini`.
     3. Wykona kopię zapasową podmienianych plików do `%LOCALAPPDATA%\FIFA16LocalFUT\install-backup\`.
     4. Wgra pliki patcha i serwera do folderu gry.
     5. Utworzy skrót na Pulpicie: **FIFA 16 Local FUT**.
     6. Uruchomi lokalny serwer w tle i włączy grę FIFA 16.

3. **Krok 3: Kolejne uruchomienia:**
   * Uruchamiaj grę bezpośrednio ze skrótu na Pulpicie **FIFA 16 Local FUT** lub plikiem [`PLAY_LOCAL_FUT16.cmd`](PLAY_LOCAL_FUT16.cmd).
   * W menu głównym gry wybierz **Ultimate Team** – gra połączy się z Twoim lokalnym serwerem offline.

---

### 🍏 Opcja B: System macOS (CrossOver / Apple Silicon M1–M4)

Na komputerach Mac gra działa w środowisku **CrossOver** (wersja 24.x lub 26.x), a serwer FUT uruchamia się natywnie w Terminalu macOS.

1. **Krok 1: Wgranie patchy do CrossOvera (Wymagane na macOS):**
   * Denuvo w FIFA 16 wymaga limitu alokacji pamięci `CX_TOPDOWN_LIMIT`, którego standardowy Wine nie posiada (bez patcha gra crashuje pod emulacją Rosetta 2).
   * Upewnij się, że CrossOver jest zainstalowany w `/Applications/CrossOver.app`.
   * W Terminalu macOS uruchom instalator:
     ```bash
     ./macos/crossover_patch/install_patch.sh
     ```
     *Skrypt bezpiecznie zbackupuje oryginały, zainstaluje spatchowane biblioteki `ntdll.so` oraz `gdiplus.dll`, a następnie automatycznie podpisze aplikację kodem za pomocą `codesign` z uprawnieniem `disable-library-validation`.*

2. **Krok 2: Przygotowanie butelki i plików gry:**
   * Otwórz CrossOver i utwórz nową butelkę (typ: **Windows 10 64-bit**, np. o nazwie `FIFA16`).
   * Skopiuj folder z grą FIFA 16 (z wklejonymi plikami cracka **CrackFix V3**) do wnętrza butelki, np. do:  
     `drive_c/Games/FIFA 16/`

3. **Krok 3: Automatyczna konfiguracja butelki:**
   * W Terminalu macOS uruchom:
     ```bash
     ./macos/SETUP_CROSSOVER_MAC.sh
     ```
   * Skrypt automatycznie:
     - Włączy silnik graficzny **D3DMetal** (DirectX 11 z Apple MetalFX).
     - Skonfiguruje `CX_TOPDOWN_LIMIT = 0x1ffffffff` oraz `WINE_SIMULATE_WRITECOPY = 1` w `cxbottle.conf`.
     - Wyłączy fałszywe błędy antywirusa CrossOver (`AntiVirusScan = never`).
     - Ustawi tryb okienkowy `FULLSCREEN = 0` w `fifasetup.ini` (zapobiega zawieszaniu przełączania ekranu w macOS Wine).
     - Doda przekierowania domen EA do pliku `etc/hosts` w butelce oraz wgra `cl.ini` do folderu gry.

4. **Krok 4: Uruchomienie serwera i gry:**
   * Kliknij dwukrotnie w plik [`START_SERVER_MAC.command`](START_SERVER_MAC.command) w głównym folderze projektu (otworzy się okno Terminala z aktywnym serwerem FUT).
   * Włącz grę FIFA 16 w CrossOverze.
   * W menu gry wybierz **Ultimate Team** — gra połączy się bezpośrednio z Twoim lokalnym serwerem.

---

### 🛠️ Szczegóły techniczne patchy CrossOver (`macos/crossover_patch/`)

Dla pełnej przejrzystości i możliwości samodzielnej kompilacji katalog `macos/crossover_patch/` zawiera:
* **`install_patch.sh`** — Samodzielny instalator patchy dla CrossOver.
* **`fixes/x86_64-unix/ntdll.so`** — Skompilowana biblioteka z obsługą `CX_TOPDOWN_LIMIT` (rozwiązuje crash Denuvo).
* **`fixes/x86_64-windows/gdiplus.dll`** — Poprawiona biblioteka GDI+ (poprawne renderowanie i zwalnianie fontów).
* **`patches/crossover-26.3-topdown-alloc-limit.patch`** — Kod źródłowy łatki dla `ntdll`.
* **`patches/crossover-26.3-gdiplus-delete-font-collection.patch`** — Kod źródłowy łatki dla GDI+.

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

* **macOS:** Kliknij dwukrotnie [`macos/ADD_COINS_MAC.command`](macos/ADD_COINS_MAC.command).
* **Windows:** Uruchom [`windows/ADD_COINS.cmd`](windows/ADD_COINS.cmd).

---

## 🔄 Reset klubu do stanu początkowego

* **macOS:** Kliknij dwukrotnie [`macos/RESET_CLUB_MAC.command`](macos/RESET_CLUB_MAC.command).
* **Windows:** Uruchom [`windows/RESET_TO_STARTER_CLUB.cmd`](windows/RESET_TO_STARTER_CLUB.cmd).

---

## 📁 Struktura plików

### 🍏 macOS (`macos/`)
Dedykowane narzędzia do gry na komputerach Mac (CrossOver / Wine):
* **`START_SERVER_MAC.command`** — Uruchamia lokalny serwer FUT w Terminalu macOS.
* **`SETUP_CROSSOVER_MAC.sh`** — Automatyczny instalator dla CrossOver.
* **`crossover_patch/`** — Gotowe patche Wine/CrossOver (`ntdll.so`, `gdiplus.dll`) i instalator `install_patch.sh`.
* **`ADD_COINS_MAC.command`** — Dodawanie monet do klubu.
* **`RESET_CLUB_MAC.command`** — Reset bazy danych klubu.

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
