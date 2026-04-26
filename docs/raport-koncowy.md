# Raport końcowy – Audyt i hardening systemu Debian 13

**Autor:**          Monika Campoli  
**Nr albumu:**      163319  
**Data:**           26.04.2026  
**Repozytorium:**   https://github.com/MCampoli/linux-hardening

---

## 1. Cel i zakres raportu

Raport przedstawia proces audytu bezpieczeństwa systemu Debian 13 oraz wdrożenie 11 poprawek (hardening), które doprowadziły do podniesienia wyniku Lynis z **63/100** do **82/100** oraz wyeliminowania wszystkich warningów.

---

## 2. Wyniki audytu – porównanie Before & After

| Wskaźnik              | Sprint 1 (przed) | Sprint 2 (po) | Zmiana     |
|-----------------------|------------------|---------------|------------|
| **Hardening index**   | 63/100           | **82/100**    | **+19**    |
| **Warnings**          | 1                | **0**         | usunięty   |
| **Suggestions**       | 47               | 31            | −16        |
| **Tests performed**   | 251              | 262           | +11        |

### Szczegółowe wyniki

#### Sprint 1 – audyt początkowy (63/100)

- Brak firewalla (UFW)
- SSH na domyślnym porcie 22
- Brak Fail2ban
- Brak automatycznych aktualizacji
- Brak auditd, AIDE, rsyslog
- Brak polityki silnych haseł (PAM)

#### Sprint 2 – audyt końcowy (82/100)

- Firewall UFW aktywny (deny incoming, allow 2222/tcp)
- SSH na porcie 2222, MaxAuthTries 3, X11Forwarding no
- Fail2ban aktywny (jail sshd)
- Automatyczne aktualizacje włączone
- Auditd, AIDE, rsyslog wdrożone
- PAM wymaga min. 10 znaków hasła
- Login banner dodany
- Kernel hardening (sysctl) wdrożony

---

## 3. Pełne ścieżki mitygacji (11 FIX)

### 🔧 FIX-001 – UFW (firewall)

**Identyfikator**            FIX-002 
**Opis zmiany**              Instalacja i konfiguracja firewalla UFW; domyślnie blokuj przychodzące, zezwól na SSH 
**Test**                     `ufw status verbose` 
**Wynik**                     Status: active, default deny incoming, allow 2222/tcp
**Pełna ścieżka mitygacji**  `apt update` → `apt install ufw -y` → `ufw default deny incoming` → `ufw default allow outgoing` → `ufw allow 2222/tcp` → `ufw enable` → `ufw status verbose` |

---

### 🔧 FIX-002 – Hardening SSH

**Identyfikator**            FIX-002 
**Opis zmiany**              Zmiana portu SSH na 2222, MaxAuthTries 3, wyłączenie X11Forwarding, AllowAgentForwarding, TCPKeepAlive, LogLevel VERBOSE
**Test**                     `sshd -T \| grep -E "port|maxauthtries|x11forwarding|allowagentforwarding|tcpkeepalive|loglevel"`
**Wynik**                    port 2222, maxauthtries 3, x11forwarding no, allowagentforwarding no, tcpkeepalive no, loglevel VERBOSE 
**Pełna ścieżka mitygacji**  `nano /etc/ssh/sshd_config` → ustawienia: `Port 2222`, `MaxAuthTries 3`, `X11Forwarding no`, `AllowAgentForwarding no`, `TCPKeepAlive no`, `LogLevel VERBOSE` → zapis (Ctrl+O, Enter, Ctrl+X) → `systemctl restart ssh` → `ufw allow 2222/tcp` → `ufw reload` → usunięcie portu 22: `ufw delete allow 22/tcp`

---

### 🔧 FIX-003 – Fail2ban (ochrona przed brute force)

**Identyfikator**               FIX-003
**Opis zmiany**                 Automatyczne blokowanie adresów IP po nieudanych próbach logowania SSH 
**Test**                        `fail2ban-client status` oraz `fail2ban-client status sshd` 
**Wynik**                       `Jail list: sshd`, `Currently banned: 0` 
**Pełna ścieżka mitygacji**     `apt install fail2ban -y` → `systemctl enable fail2ban` → `systemctl start fail2ban` → `cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local` → `systemctl restart fail2ban` → `fail2ban-client status` 

---

### 🔧 FIX-004 – Automatyczne aktualizacje (unattended upgrades)

**Identyfikator**               FIX-004 
**Opis zmiany**                 System automatycznie instaluje poprawki bezpieczeństwa 
**Test**                        `systemctl status unattended-upgrades` 
**Wynik**                       active (running) 
**Pełna ścieżka mitygacji**     `apt install unattended-upgrades -y` → `dpkg-reconfigure unattended-upgrades` (wybierz YES) → `systemctl enable unattended-upgrades` → `systemctl start unattended-upgrades` 

---

### 🔧 FIX-005 – Kernel hardening (sysctl)

**Identyfikator**               FIX-005 
**Opis zmiany**                 Ochrona przed spoofingiem, logowanie martian packets, ukrycie pamięci kernela, blokada niebezpiecznych funkcji jądra 
**Test**                        `sysctl net.ipv4.conf.all.rp_filter` oraz `sysctl kernel.kptr_restrict` 
**Wynik**                       wszystkie parametry zgodne z profilem Lynis 
**Pełna ścieżka mitygacji**     `nano /etc/sysctl.conf` → dopisanie: `net.ipv4.conf.all.rp_filter = 1`, `net.ipv4.conf.default.rp_filter = 1`, `net.ipv4.conf.all.log_martians = 1`, `net.ipv4.conf.default.log_martians = 1`, `kernel.dmesg_restrict = 1`, `kernel.kptr_restrict = 2`, `kernel.modules_disabled = 1`, `kernel.unprivileged_bpf_disabled = 1`, `kernel.yama.ptrace_scope = 2`, `kernel.sysrq = 0` → zapis → `sysctl -p` 

---

### 🔧 FIX-006 – /tmp i /var/tmp (sticky bit)
**Identyfikator**               FIX-006 
**Opis zmiany**                 Tylko właściciel pliku może go usunąć z katalogów tymczasowych 
**Test**                        `ls -ld /tmp /var/tmp` 
**Wynik**                       drwxrwxrwt 
**Pełna ścieżka mitygacji**     `chmod 1777 /tmp` → `chmod 1777 /var/tmp` → `ls -ld /tmp /var/tmp` 

---

### 🔧 FIX-007 – Login banner (ostrzeżenie prawne)

**Identyfikator**               FIX-007 
**Opis zmiany**                 Wyświetlanie ostrzeżenia przed logowaniem (banner) 
**Test**                        `cat /etc/issue` oraz `cat /etc/issue.net` 
**Wynik**                       `Authorized access only. All actions are monitored.` 
**Pełna ścieżka mitygacji**     `echo "Authorized access only. All actions are monitored." > /etc/issue` → `echo "Authorized access only. All actions are monitored." > /etc/issue.net` 

---

### 🔧 FIX-008 – Auditd (monitorowanie zdarzeń)

**Identyfikator**               FIX-008 
**Opis zmiany**                 Rejestrowanie zmian w krytycznych plikach systemowych (passwd, shadow, sshd_config) 
**Test**                        `auditctl -l` 
**Wynik**                       reguły aktywne dla /etc/passwd, /etc/shadow, /etc/ssh/sshd_config 
**Pełna ścieżka mitygacji**     `apt install auditd -y` → `systemctl enable auditd` → `systemctl start auditd` → `nano /etc/audit/rules.d/audit.rules` → dodanie: `-w /etc/passwd -p wa -k identity`, `-w /etc/shadow -p wa -k identity`, `-w /etc/ssh/sshd_config -p wa -k ssh` → `systemctl restart auditd` → `auditctl -l` 

---

### 🔧 FIX-009 – PAM (silne hasła)

**Identyfikator**               FIX-009 
**Opis zmiany**                 Wymuszenie minimalnej długości hasła (10 znaków) oraz ograniczenie prób 
**Test**                        `grep pam_pwquality /etc/pam.d/common-password` 
**Wynik**                       `password requisite pam_pwquality.so retry=3 minlen=10` 
**Pełna ścieżka mitygacji**     `apt install libpam-pwquality -y` → `nano /etc/pam.d/common-password` → znalezienie linii z `pam_pwquality.so` → zmiana na: `password requisite pam_pwquality.so retry=3 minlen=10` → zapis 

---

### 🔧 FIX-010 – Rsyslog (logowanie systemowe)

**Identyfikator**               FIX-010 
**Opis zmiany**                 Pełne logowanie systemowe (auth, syslog, kern) 
**Test**                        `systemctl status rsyslog` 
**Wynik**                       active (running)
**Pełna ścieżka mitygacji**     `apt install rsyslog -y` → `systemctl enable rsyslog` → `systemctl start rsyslog` → `systemctl status rsyslog` 

---

### 🔧 FIX-011 – AIDE (integralność plików)

**Identyfikator**               FIX-011 
**Opis zmiany**                 Wykrywanie nieautoryzowanych zmian w plikach systemowych 
**Test**                        `aide -c /etc/aide/aide.conf --check` 
**Wynik**                       Database initialized, brak krytycznych zmian 
**Pełna ścieżka mitygacji**     `apt install aide -y` → `aideinit` → `mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db` → `aide -c /etc/aide/aide.conf --check` 


---

## 4. Podsumowanie końcowe

| Obszar                  | Sprint 1 | Sprint 2           |
|-------------------------|----------|--------------------|
| Firewall                | brak     | UFW active         |
| SSH port                | 22       | 2222               |
| Fail2ban                | brak     | aktywny            |
| Auto‑updates            | brak     | włączone           |
| Auditd / AIDE / Rsyslog | brak     | wszystkie wdrożone |
| Kernel hardening        | brak     | 18/18 OK           |
| PAM                     | brak     | minlen=10          |
| Login banner            | brak     | dodany             |

**Cel projektu osiągnięty** – wynik 82/100, brak warningów, system znacząco bezpieczniejszy.

---

## 5. Dowody

- [Audyt początkowy (screenshot)](../results/1.Lynis-audyt.png)
- [Log audytu początkowego](../results/1.lynis.log)
- [Raport audytu początkowego](../1.lynis-raport.txt)
- [Audyt końcowy (screenshot)](../results/2.Lynis-audyt.png)
- [Log audytu końcowego](../results/sprint2-lynis.log)
- [Raport audytu końcowego](../2.lynis-raport.txt)
- [Status UFW](../results/ufw-status.png)
- [Status final UFW](../results/ufw-ssh-final.png)
- [Status Fail2ban](../results/fail2ban-sshd.png)

---

## 6. Link do repozytorium

[https://github.com/MCampoli/linux-hardening](https://github.com/MCampoli/linux-hardening)