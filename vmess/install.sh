#!/bin/bash

sudo apt install jq -y

echo "[VMESS][Step 1/4] Downloading EX-AutoSC..."

curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vmess/create.sh --output /usr/local/sbin/vmess-create-account
curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vmess/renew.sh --output /usr/local/sbin/vmess-renew-account
curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vmess/delete.sh --output /usr/local/sbin/vmess-delete-account

echo "[VMESS][Step 2/4] EX-AutoSC has been successfully downloaded"

sleep 1

echo "[VMESS][Step 3/4] Applying permission..."

chmod +x /usr/local/sbin/vmess-create-account
chmod +x /usr/local/sbin/vmess-renew-account
chmod +x /usr/local/sbin/vmess-delete-account

echo "[VMESS][Step 4/4] Permission has been successfully applied"