# Sprint 2 – Szczegółowy opis poprawek (hardening systemu)

## 🔧 FIX-001 – UFW (firewall) – SZCZEGÓŁOWO

---

### 📌 Cel
Zabezpieczenie serwera przed nieautoryzowanym dostępem z sieci poprzez kontrolę ruchu przychodzącego.

### 📌 Problem przed zmianą
System nie posiadał aktywnej zapory sieciowej. Oznaczało to, że wszystkie porty były otwarte dla ruchu przychodzącego. Serwer był widoczny w sieci i podatny na:
- Skanowanie portów
- Próby nieautoryzowanego logowania
- Ataki na dowolne usługi sieciowe

Lynis w audycie początkowym zgłaszał brak firewalla jako **poważny problem** (warning).

### 📌 Co zostało zmienione
1. **Instalacja pakietu UFW** – narzędzia do zarządzania zaporą sieciową
2. **Ustawienie domyślnej polityki dla ruchu przychodzącego** – `deny incoming` (blokuj wszystkie nowe połączenia od zewnątrz)
3. **Ustawienie domyślnej polityki dla ruchu wychodzącego** – `allow outgoing` (system może swobodnie wysyłać dane, np. aktualizacje)
4. **Dodanie reguły zezwalającej na SSH** – `allow 2222/tcp` (tylko ten port jest otwarty dla połączeń przychodzących)
5. **Aktywacja firewalla** – `ufw enable`
6. **Weryfikacja statusu** – `ufw status verbose`

### 📌 Test weryfikacyjny
```bash
ufw status verbose
```

### 📌 Wynik testu
```
Status: active
Default: deny (incoming), allow (outgoing)
2222/tcp                   ALLOW IN    Anywhere
```

Dodatkowo wykonano test z zewnątrz (PowerShell):
```powershell
Test-NetConnection 192.168.0.70 -Port 80
```
Wynik: `TcpTestSucceeded : False` – port 80 zablokowany zgodnie z polityką.

### 📌 Wpływ na wynik Lynis
- Lynis przestał zgłaszać brak firewalla (warning usunięty)
- System zyskał punktację w kategorii `Firewall [V]`
- Przyczyniło się do wzrostu **Hardening index** z 63 → 82

### 📌 Pełna ścieżka mitygacji (kolejność działań)
```bash
apt update
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw enable
ufw status verbose
```

### 📌 Uwaga
FIX-001 **nie zmienia konfiguracji SSH** – tylko otwiera port w firewallu. Bez FIX-002 (SSH na porcie 2222) połączenie i tak by nie działało.

---

## 🔧 FIX-002 – Hardening SSH – SZCZEGÓŁOWO

---

### 📌 Cel
Zabezpieczenie usługi SSH przed atakami brute-force, nieautoryzowanym dostępem i niepotrzebnymi funkcjami zwiększającymi powierzchnię ataku.

### 📌 Problem przed zmianą
Konfiguracja SSH była w stanie domyślnym, co oznaczało następujące luki:

| Problem                       | Ryzyko                                                     |
|-------------------------------|------------------------------------------------------------|
| Port 22 (domyślny)            | Łatwy do wykrycia przez automatyczne skanery               |
| Brak limitu prób logowania    | Atakujący może próbować haseł bez ograniczeń (brute‑force) |
| X11Forwarding włączone        | Ryzyko przejęcia sesji graficznych                         |
| AllowAgentForwarding włączone | Ryzyko kradzieży kluczy SSH                                |
| TCPKeepAlive włączone         | Utrzymywanie nieaktywnych sesji                            |
| LogLevel INFO                 | Niedostateczne logowanie zdarzeń                           |

Lynis w audycie początkowym zgłaszał **kilkanaście sugestii** dotyczących SSH (kod SSH-7408).

### 📌 Co zostało zmienione
W pliku `/etc/ssh/sshd_config` zmodyfikowano następujące parametry:

| Parametr               | Przed | Po           | Uzasadnienie                                      |
|------------------------|-------|--------------|---------------------------------------------------|
| `Port`                 | 22    | **2222**     | Ukrycie usługi przed automatycznymi atakami       |
| `MaxAuthTries`         | 6     | **3**        | Ograniczenie prób logowania (brute‑force)         |
| `ClientAliveInterval`  | brak  | **300**      | Sprawdzanie aktywności klienta co 5 min           |
| `ClientAliveCountMax`  | brak  | **2**        | Rozłączenie po 2 braku odpowiedzi                 |
| `LogLevel`             | INFO  | **VERBOSE**  | Szczegółowe logi bezpieczeństwa                   |
| `X11Forwarding`        | yes   | **no**       | Wyłączenie zdalnego GUI (niepotrzebne na serwerze)|
| `AllowAgentForwarding` | yes   | **no**       | Ochrona przed kradzieżą kluczy SSH                |
| `TCPKeepAlive`         | yes   | **no**       | Lepsza kontrola nad nieaktywnymi sesjami          |

### 📌 Test weryfikacyjny
```bash
sshd -T | grep -E "port|maxauthtries|x11forwarding"
```

### 📌 Wynik testu
```
port 2222
maxauthtries 3
x11forwarding no
allowagentforwarding no
tcpkeepalive no
loglevel VERBOSE
```

Dodatkowo wykonano test połączenia:
```bash
ssh -p 2222 uzytkownik@192.168.0.70
```
Połączenie działa poprawnie.

### 📌 Wpływ na wynik Lynis
- Wszystkie sugestie dotyczące SSH (SSH-7408) zostały rozwiązane
- Lynis przestał zgłaszać problemy z konfiguracją SSH
- System zyskał ochronę przed atakami brute‑force
- Przyczyniło się do wzrostu **Hardening index** z 63 → 82

### 📌 Pełna ścieżka mitygacji (kolejność działań)

```bash
nano /etc/ssh/sshd_config
# Wprowadzenie zmian:
# Port 2222
# MaxAuthTries 3
# ClientAliveInterval 300
# ClientAliveCountMax 2
# LogLevel VERBOSE
# X11Forwarding no
# AllowAgentForwarding no
# TCPKeepAlive no
systemctl restart ssh
```

### 📌 Uwaga
FIX-002 **nie otwiera portu w firewallu** – tylko ustawia SSH na porcie 2222. Bez FIX-001 (UFW) połączenie byłoby blokowane przez zaporę.

---

## ✅ Podsumowanie współpracy FIX-001 i FIX-002

| Poprawka          | Co robi                       | Bez drugiej poprawki                |
|-------------------|-------------------------------|-------------------------------------|
| **FIX-001 (UFW)** | Otwiera port 2222 w firewallu | Port zamknięty → brak połączenia    |
| **FIX-002 (SSH)** | Ustawia SSH na porcie 2222    | SSH na porcie 22 → firewall blokuje |

**Razem:** SSH działa bezpiecznie na porcie 2222, firewall chroni resztę systemu.

---

## ✅ Wpływ na końcowy wynik Lynis

| Obszar              | Przed (Sprint 1) | Po (Sprint 2) |
|---------------------|------------------|---------------|
| Firewall            | brak (inactive)  | active        |
| Port SSH            | 22               | 2222          |
| MaxAuthTries        | brak limitu      | 3             | 
| X11Forwarding       | yes              | no            |
| Warningi SSH        | wiele            | brak          |
| **Hardening index** | **63/100**       | **82/100**    |

