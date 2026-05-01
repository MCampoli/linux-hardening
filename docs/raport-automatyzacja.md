# Raport automatyzacji – automatyczny audyt Lynis (Sprint 3)
 
**Autor:**          Monika Campoli  
**Nr albumu:**      163319  
**Data:**           01.05.2026  

---

## 1. Cel automatyzacji

Celem zadania było zautomatyzowanie czynności wcześniej wykonywanej ręcznie – cotygodniowego audytu bezpieczeństwa systemu Debian 13 za pomocą narzędzia Lynis. Automatyzacja miała na celu:

- Oszczędność czasu,
- Eliminację błędów ludzkich,
- Zapewnienie regularności audytów,
- Stworzenie historii wyników.

---

## 2. Wybrana czynność do automatyzacji

| Element                    | Opis                                                                 |
|----------------------------|----------------------------------------------------------------------|
| **Czynność**               | Audyt bezpieczeństwa systemu (`lynis audit system`)                  |
| **Wcześniejsze wykonanie** | Wpisanie komendy, oczekiwanie 2-3 minuty, ręczne kopiowanie wyników  |
| **Zautomatyzowanie**       | Skrypt Bash uruchamiany przez CRON, raport z datą i czasem wykonania |

---

## 3. Skrypt – `auto-audit.sh`

### Lokalizacja:
`/home/monikac/linux-hardening/src/auto-audit.sh`

### Treść skryptu:

```bash
#!/bin/bash
# auto-audit.sh – Automatyczny audyt Lynis z pomiarem czasu

LOG_DIR="/home/monikac/linux-hardening/results/auto-audit-logs"
DATE=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$LOG_DIR/lynis-auto-$DATE.log"
TIME_FILE="$LOG_DIR/lynis-auto-$DATE.time"

mkdir -p "$LOG_DIR"

START_TIME=$(date +%s)

echo "=== Automatyczny audyt Lynis z dnia $(date) ===" > "$REPORT_FILE"
echo "Uruchomienie: $(date)" >> "$REPORT_FILE"
echo "----------------------------------------" >> "$REPORT_FILE"

/usr/sbin/lynis audit system >> "$REPORT_FILE" 2>&1

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "----------------------------------------" > "$TIME_FILE"
echo "Czas wykonania audytu: $DURATION sekund" >> "$TIME_FILE"
echo "Data audytu: $(date)" >> "$TIME_FILE"

echo "Audyt zakończony. Raport: $REPORT_FILE"
echo "Czas wykonania: $DURATION sekund"
```

# Opis szczegółowy – automatyzacja audytu Lynis

## Opis działania skryptu

| Element                        | Opis                                                           |
|--------------------------------|----------------------------------------------------------------|
| `LOG_DIR`                      | Katalog przechowujący logi                                     |
| `DATE`                         | Znacznik czasu (rok, miesiąc, dzień, godzina, minuta, sekunda) |
| `mkdir -p`                     | Tworzy katalog na logi (jeśli nie istnieje)                    |
| `START_TIME`                   | Rozpoczęcie pomiaru czasu                                      |
| `echo ... >`                   | Zapis nagłówka raportu                                         |
| `/usr/sbin/lynis audit system` | **Wykonanie audytu** – najważniejsza linia                     |
| `END_TIME`                     | Zakończenie pomiaru czasu                                      |
| `DURATION`                     | Obliczenie czasu wykonania                                     |
| `TIME_FILE`                    | Zapis czasu do osobnego pliku                                  |

---

## Sprawdzenie poprawności

```bash
ls -la /usr/sbin/lynis
```

## Przykładowe uruchomienie

```bash
time /home/monikac/linux-hardening/src/auto-audit.sh
```

## Automatyzacja przez CRON

Konfiguracja CRON:

``` bash
crontab -e
``` 

dodana linia:

``` bash
59 23 * * 0 /home/monikac/linux-hardening/src/auto-audit.sh >> /home/monikac/linux-hardening/results/auto-audit-logs/cron.log 2>&1
```

## Wyjaśnienie zapisu CRON

|Pole	|Wartość    |Znaczenie                 |
|-------|-----------|--------------------------|
| 1	    | 59    	|59 minuta                 |
| 2    	| 23	    |23 godzina (11:59 PM)     |
| 3	    | *	        |każdy dzień miesiąca      |
| 4	    | *	        |każdy miesiąc             |
| 5	    | 0	        |niedziela (0 = niedziela) |

Oznacza to: Skrypt uruchamia się automatycznie w każdą niedzielę o 23:59.

## Pomiar efektu – porównanie czasu

| Metoda	    | Czas aktywnej pracy człowieka | Uwagi                                          |
|---------------|-------------------------------|------------------------------------------------|
| Ręcznie       |  ~120-180 sekund	            | Wpisanie komendy, czekanie, kopiowanie wyników |
| Auto. (CRON)	|   0 sekund	                | Skrypt działa w tle, człowiek nie traci czasu  |

### Przykładowy czas wykonania (z pliku .time)

```bash
Czas wykonania audytu: 155 sekund
Data audytu: Fri May 1 20:53:50 CEST 2026
```

### Oszczędność czasu w skali roku

| Okres	                | Oszczędność   |
|-----------------------|---------------|
| Tygodniowo	        | ~2-3 minuty   |
| Rocznie (52 tygodnie) | ~2-3 godziny  |

## Podsumowanie

Zadanie Sprint #3 – automatyzacja audytu Lynis – zostało wykonane w pełni:

- Wybrano czynność (audyt Lynis)
- Przygotowano skrypt auto-audit.sh
- Skrypt uruchamiany przez CRON co tydzień
- Pomiar czasu wykonania (155 sekund)
- Porównanie z czasem ręcznym (0 vs 120-180 sekund)
- Dokumentacja w repozytorium.