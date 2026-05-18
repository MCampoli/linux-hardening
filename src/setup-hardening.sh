#!/bin/bash
#Automatyzacja hardeningu Debian
# Uruchom jako root!

# Sprawdzenie uprawnień
if [ "$EUID" -ne 0 ]; then 
    echo "Uruchom jako root (sudo ./skrypt.sh)"
    exit 1
fi

# Backup plików konfiguracyjnych
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup 2>/dev/null
cp /etc/sysctl.conf /etc/sysctl.conf.backup 2>/dev/null

echo "=== UFW ==="
apt update
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw enable

echo "=== SSH Hardening ==="
sed -i 's/^#\?Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/^#\?MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
systemctl restart ssh

echo "=== Fail2ban ==="
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

echo "=== Auditd / AIDE ==="
apt install auditd aide -y
aideinit -f

echo "=== Kernel sysctl ==="
cat << EOF >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter = 1
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
EOF
sysctl -p

echo "=== Hardening completed! ==="
echo "SSH działa na porcie 2222"
echo "UFW aktywny, Fail2ban uruchomiony"
echo "AIDE baza danych zainicjalizowana"ho "=== UFW ==="
