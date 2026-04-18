# Hardening Linuxa – Projekt bezpieczeństwa

## 1. Temat
Wzmocnienie bezpieczeństwa systemu Linux i praktyczna nauka obrony przed atakami w sieci wirtualnej.

## 2. Cel projektu
Projekt ma na celu wzmocnienie bezpieczeństwa serwera Debian poprzez audyt systemu, konfigurację usług SSH, UFW i Fail2ban oraz symulację prób logowania w kontrolowanym środowisku laboratoryjnym.

## 3. Narzędzia
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
| SSH na domyślnym porcie 22   |    Wysoki          | Zmiana portu na 2222                 |
| Brak Fail2ban                |    Średni          | Instalacja i konfiguracja Fail2ban   |
| Brak automat. aktualizacji   |    Średni          | Konfiguracja unattended-upgrades     |
| Słabe ustawienia SSH         |    Średni          | Hardening konfiguracji SSH           |

### Wnioski

1. **System jest w stanie surowym** – wynik 63/100 wskazuje, że podstawowa konfiguracja Debiana nie jest wystarczająco zabezpieczona. Brak firewalla i domyślne ustawienia SSH to krytyczne luki.

2. **Audyt potwierdza plan projektu** – wszystkie wykryte problemy są zgodne z zaplanowanymi działaniami (UFW, SSH, Fail2ban), co oznacza, że harmonogram jest trafny.

3. **Potrzeba iteracyjnego podejścia** – po każdej zmianie konfiguracji należy powtarzać audyt, aby zmierzyć poprawę indeksu hardeningu.

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

