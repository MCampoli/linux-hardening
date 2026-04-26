# Hardening Linuxa – Projekt bezpieczeństwa

## 1. Skład zespołu i role

| Rola          | Osoba                   | Zakres odpowiedzialności                |
|---------------|-------------------------|-----------------------------------------|
| Lider         | Monika Campoli (163319) | Planowanie, koordynacja, raport końcowy |
| Inżynier      | Monika Campoli (163319) | Instalacja, SSH, UFW, Fail2ban, audyt   |
| Dokumentujący | Monika Campoli (163319) | Logi, screenshoty, prezentacja          |

*Projekt realizowany samodzielnie – wszystkie role pełni jedna osoba.*

## 2. Temat
Audyt i hardening bezpieczeństwa systemu Linux (Debian).

## 3. Cel projektu
Projekt ma na celu wzmocnienie bezpieczeństwa serwera Debian poprzez audyt systemu, konfigurację usług SSH, UFW i Fail2ban oraz opcjonalnie symulację prób logowania w kontrolowanym środowisku laboratoryjnym.

## 4. Narzędzia
- Debian Server – system docelowy do hardeningu
- Ubuntu Desktop / Kali Linux / Debian – maszyna testowa do symulacji ataków
- SSH – usługa zdalnego logowania
- UFW (Uncomplicated Firewall) – konfiguracja zapory sieciowej
- Fail2ban – ochrona przed nieautoryzowanymi próbami logowania
- Lynis – audyt bezpieczeństwa systemu
- Ansible – automatyzacja konfiguracji

## Sprint 1  - Pierwszy audyt bezpieczeństwa Lynis

### Cel testu
Przeprowadzenie wstępnego audytu systemu Debian 13 w celu zidentyfikowania luk i słabych punktów konfiguracji przed rozpoczęciem procesu hardeningu.

### Wykonane czynności
1. Instalacja systemu Debian 13 w VirtualBox (3 CPU, 4 GB RAM)
2. Aktualizacja systemu: `apt update && apt upgrade -y`
3. Instalacja narzędzia Lynis: `apt install lynis -y`
4. Wykonanie audytu: `lynis audit system`

### Wynik audytu

| Wskaźnik            |   Wartość  |
|---------------------|------------|
| **Hardening index** | **63/100** |
| Warnings            |      1     |
| Suggestions         |      47    |
| Tests performed     |      251   |

### Zidentyfikowane problemy

| Problem                      | Poziom ryzyka      |         Planowana naprawa            |
|------------------------------|--------------------|--------------------------------------|
| Brak firewalla (UFW)         |    Wysoki          | Instalacja i konfiguracja UFW        |
| SSH na domyślnym porcie 22   |    Średni          | Zmiana portu na 2222                 |
| Brak Fail2ban                |    Średni          | Instalacja i konfiguracja Fail2ban   |
| Brak automat. aktualizacji   |    Średni          | Konfiguracja unattended-upgrades     |
| Słabe ustawienia SSH         |    Średni          | Hardening konfiguracji SSH           |

### Wnioski

1. **System jest w stanie surowym** – wynik 63/100 wskazuje, że podstawowa konfiguracja Debiana nie jest wystarczająco zabezpieczona. Brak firewalla i domyślne ustawienia SSH to krytyczne luki.

2. **Audyt potwierdza plan projektu** – wszystkie wykryte problemy są zgodne z zaplanowanymi działaniami (UFW, SSH, Fail2ban), co oznacza, że harmonogram jest trafny.

3. **Potrzeba iteracyjnego podejścia** – projekt przyjmuje iteracyjny model hardeningu, w którym każda zmiana konfiguracji jest weryfikowana poprzez ponowny audyt systemu.

### Plan na kolejny sprint

| Lp. | Zadanie                 | Narzędzie   | Spodziewany efekt                         |
|-----|-------------------------|-------------|-------------------------------------------|
|  1  | Konfiguracja firewalla  | UFW         | Ochrona przed nieautoryzowanym ruchem     |
|  2  | Zmiana portu SSH        | sshd_config | Zmniejszenie ryzyka ataków automatycznych |
|  3  | Hardening SSH           | sshd_config | Wyłączenie zbędnych opcji                 |
|  4  | Instalacja Fail2ban     | Fail2ban    | Automatyczna blokada IP po próbach ataku  |
|  5  | Powtórny audyt          | Lynis       | Porównanie wyników                        |

### Dowody wykonania testu

- [Screenshot wyniku](results/1.Lynis-audyt.png)
- [Log audytu](results/1.lynis-raport.txt)
- [Log audytu](results/1.lynis.log)


## Sprint 2 – Hardening systemu (11 poprawek)

### Cel sprintu
Wdrożenie rzeczywistych zabezpieczeń systemu na podstawie wyników audytu ze Sprintu 1 oraz podniesienie wyniku Lynis do poziomu 80+.

### Wprowadzone poprawki – lista

| ID          | Obszar                    | Opis zmiany                                               |
|-------------|---------------------------|-----------------------------------------------------------|
| **FIX-001** | UFW (firewall)            | Instalacja i konfiguracja zapory; domyślnie blokuj ruch przychodzący, otwarty tylko SSH (2222)                                                                |
| **FIX-002** | Hardening SSH             | Zmiana portu na 2222, ograniczenie prób logowania, wyłączenie X11Forwarding i forwarding                                                                 |
| **FIX-003** | Fail2ban                  | Włączenie ochrony SSH i automatyczna blokada IP po błędnych logowaniach                                                                                  |
| **FIX-004** | Automatyczne aktualizacje | Włączenie unattended-upgrades dla aktualizacji bezpieczeństwa                                                                                        |
| **FIX-005** | Kernel hardening          | Zastosowanie sysctl: ochrona przed spoofingiem i wzmocnienie bezpieczeństwa sieci                                                                      |
| **FIX-006** | /tmp hardening            | Aktywacja sticky bit w /tmp i /var/tmp                    |
| **FIX-007** | Login banner              | Dodanie komunikatu bezpieczeństwa (/etc/issue, /etc/issue.net)                                                                                                  |
| **FIX-008** | Auditd                    | Monitorowanie zmian w plikach systemowych (np. passwd, shadow, sshd_config)                                                                                  |
| **FIX-009** | PAM (silne hasła)         | Wymuszenie minimalnej długości hasła (10 znaków)          |
| **FIX-010** | Rsyslog                   | Pełne logowanie systemowe (auth, syslog, kern)            |
| **FIX-011** | AIDE                      | Monitorowanie integralności plików systemowych            |

📌 *Szczegółowe ścieżki mitygacji (pełne komendy, testy, wyniki) znajdują się w pliku `/docs/raport-koncowy.md`.*


## Wynik końcowy (po hardeningu)

| Wskaźnik          | Wartość |
|-------------------|---------|
| Hardening index   | 82/100  |
| Warnings          | 0       |
| Suggestions       | 31      |
| Tests performed   | 262     |

---

## Porównanie Before & After

| Obszar          | Sprint 1 | Sprint 2 | Zmiana   |
|-----------------|----------|----------|----------|
| Hardening index | 63/100   | 82/100   | **+19**  |
| Warnings        | 1        | 0        | usunięty |
| Firewall        | brak     | aktywny  |    +     |
| Fail2ban        | brak     | aktywny  |    +     |
| SSH port        | 22       | 2222     | zmieniony|

---

## Wnioski końcowe

1. System został skutecznie utwardzony.
2. Wzrost bezpieczeństwa uzyskano dzięki m.in. firewall + SSH + Fail2ban.
3. System nadal posiada sugestie optymalizacyjne, ale brak krytycznych błędów.

### Dowody wykonania hardeningu

- [Audyt przed](results/1.Lynis-audyt.png)
- [Audyt po](results/2.Lynis-audyt.png)
- [Logi](results/sprint2-lynis.log)
- [Log audytu](results/2.lynis-raport.txt)
