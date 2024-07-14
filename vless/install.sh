#!/bin/bash

echo "[VLESS][Step 1/4] Downloading EX-AutoSC..."

curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vless/create.sh --output /usr/local/sbin/vless-create-account
curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vless/renew.sh --output /usr/local/sbin/vless-renew-account
curl -sS https://raw.githubusercontent.com/bheghenkz/EX-AutoSC/main/vless/delete.sh --output /usr/local/sbin/vless-delete-account

echo "[VLESS][Step 2/4] EX-AutoSC has been successfully downloaded"

sleep 1

echo "[VLESS][Step 3/4] Applying permission..."

chmod +x /usr/local/sbin/vless-create-account
chmod +x /usr/local/sbin/vless-renew-account
chmod +x /usr/local/sbin/vless-delete-account

echo "[VLESS][Step 4/4] Permission has been successfully applied"
