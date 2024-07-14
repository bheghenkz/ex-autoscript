#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2

sed -i "/^#! ${USERNAME} ${EXPIRED_AT}/,/^},{/d" /etc/xray/config.json

rm -rf /etc/trojan/$USERNAME
rm -rf /etc/kyt/limit/trojan/ip/$USERNAME
rm -rf /etc/limit/trojan/$USERNAME
rm -rf /var/www/html/trojan-$USERNAME.txt

systemctl restart xray > /dev/null 2>&1
