#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2

sed -i "/^#& ${USERNAME} ${EXPIRED_AT}/,/^},{/d" /etc/xray/config.json

rm -rf /etc/vless/$USERNAME
rm -rf /etc/kyt/limit/vless/ip/$USERNAME
rm -rf /etc/limit/vless/$USERNAME
rm -rf /var/www/html/vless-$USERNAME.txt

systemctl restart xray > /dev/null 2>&1
