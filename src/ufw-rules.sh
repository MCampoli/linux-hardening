#!/bin/bash
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp
ufw enable
ufw status verbose