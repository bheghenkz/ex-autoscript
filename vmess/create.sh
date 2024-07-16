#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2
IPLIMIT="5"
QUOTA="0"

IP=$(curl -s ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)


if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
if [ ! -e /etc/vmess/akun ]; then
mkdir -p /etc/vmess/akun
fi
if [ ${IPLIMIT} = '0' ]; then
IPLIMIT="9999"
fi
if [ ${QUOTA} = '0' ]; then
QUOTA="9999"
fi
c=$(echo "${QUOTA}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${USERNAME}
fi
echo "${IPLIMIT}" >/etc/vmess/${USERNAME}IP
# shellcheck disable=SC2002
TLS="443"
# shellcheck disable=SC2002
NTLS="80"
UUID=$(cat /proc/sys/kernel/random/uuid)
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vmess$/a\#vm '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","alterId": '"0"',"email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vmessgrpc$/a\#vmg '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","alterId": '"0"',"email": "'""${USERNAME}""'"' /etc/xray/config.json




JSON_TLS=$(jq -n \
    --arg username "${USERNAME}" \
    --arg domain "${DOMAIN}" \
    --arg uuid "${UUID}" \
    '{v: "2", ps: $username, add: $domain, port: "443", id: $uuid, aid: "0", net: "ws", path: "/vmess", type: "none", host: "", tls: "tls"}')
JSON_NTLS=$(jq -n \
    --arg username "${USERNAME}" \
    --arg domain "${DOMAIN}" \
    --arg uuid "${UUID}" \
    '{v: "2", ps: $username, add: $domain, port: "80", id: $uuid, aid: "0", net: "ws", path: "/vmess", type: "none", host: "", tls: "tls"}')
JSON_GRPC=$(jq -n \
    --arg username "${USERNAME}" \
    --arg domain "${DOMAIN}" \
    --arg uuid "${UUID}" \
    '{v: "2", ps: $username, add: $domain, port: "443", id: $uuid, aid: "0", net: "grpc", path: "vmess-grpc", type: "none", host: "", tls: "tls"}')
VMESS_LINK_TLS="vmess://$(echo ${JSON_TLS} | base64 -w 0)"
VMESS_LINK_NTLS="vmess://$(echo ${JSON_NTLS} | base64 -w 0)"
VMESS_LINK_GRPC="vmess://$(echo ${JSON_GRPC} | base64 -w 0)"

systemctl restart xray > /dev/null 2>&1

service cron restart > /dev/null 2>&1


cat >/var/www/html/vmess-$USERNAME.txt <<-END

=========================
  SmileVPN TUNNELING 
=========================
# Format Vmess WS TLS

- name: $USERNAME
  type: vmess
  server: ${DOMAIN}
  port: 443
  uuid: ${UUID}
  alterId: 0
  cipher: auto
  udp: true
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vmess
    headers:
  Host: ${DOMAIN}

# Format Vmess WS Non TLS

- name: $USERNAME
  type: vmess
  server: ${DOMAIN}
  port: 80
  uuid: ${UUID}
  alterId: 0
  cipher: auto
  udp: true
  tls: false
  skip-cert-verify: false
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vmess
    headers:
  Host: ${DOMAIN}

# Format Vmess gRPC

- name: Vmess-$user-gRPC (SNI)
  server: ${DOMAIN}
  port: 443
  type: vmess
  uuid: ${UUID}
  alterId: 0
  cipher: auto
  network: grpc
  tls: true
  servername: ${DOMAIN}
  skip-cert-verify: true
  grpc-opts:
    grpc-service-name: vmess-grpc

=========================
 Link Akun Vmess                   
=========================
Link TLS         : 
${VMESS_LINK_TLS}
=========================
Link none TLS    : 
${VMESS_LINK_NTLS}
=========================
Link GRPC        : 
${VMESS_LINK_GRPC}
=========================

END

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "        Vmess Account" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Remarks        : ${USERNAME}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "ISP            : ${ISP}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "CITY           : ${CITY}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "DOMAIN         : ${DOMAIN}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Wildcard       : (bug.com).${DOMAIN}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "User Quota     : ${QUOTA} GB" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "User Ip        : ${IPLIMIT} IP" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Port TLS       : ${TLS}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Port none TLS  : ${NTLS}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Port gRPC      : ${TLS}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "id             : ${UUID}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "alterId        : 0" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Security       : auto" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Network        : ws" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Path           : /vmess/multipath" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Dynamic        : https://bugmu.com/path" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "ServiceName    : vmess-grpc" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Link TLS       : ${VMESS_LINK_TLS}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Link none TLS  : ${VMESS_LINK_NTLS}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Link gRPC      : ${VMESS_LINK_GRPC}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "OpenClash : https://${DOMAIN}:81/vmess-$USERNAME.txt" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "Expired On     : ${EXPIRED_AT}" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vmess/akun/log-create-${USERNAME}.log
