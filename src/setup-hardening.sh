#!/bin/bash
# Sprint 2 – Automatyzacja hardeningu Debian

echo "=== UFW ==="
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw enable

echo "=== SSH Hardening ==="
sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config
systemctl restart ssh

echo "=== Fail2ban ==="
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

echo "=== Auditd / AIDE ==="
apt install auditd aide -y
aideinit

echo "=== Kernel sysctl ==="
cat << EOF >> /etc/sysctl.conf
net.ipv4.conf.all.rp_filter = 1
kernel.kptr_restrict = 2
kernel.dmesg_restrict = 1
EOF
sysctl -p

echo "Hardening completed."