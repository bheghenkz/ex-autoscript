#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2

sed -i "/^### ${USERNAME} ${EXPIRED_AT}/,/^},{/d" /etc/xray/config.json
rm -rf /etc/vmess/$USERNAME
rm -rf /etc/kyt/limit/vmess/ip/$USERNAME
rm -rf /etc/limit/vmess/$USERNAME
rm -rf /var/www/html/vmess-$USERNAME.txt

systemctl restart xray > /dev/null 2>&1