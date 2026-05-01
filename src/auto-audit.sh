#!/bin/bash
# auto-audit.sh – Automatyczny audyt Lynis

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