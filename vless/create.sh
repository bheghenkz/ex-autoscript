#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2
IPLIMIT="5"
QUOTA="0"

IP=$(curl -s ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)


if [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
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
echo "${d}" >/etc/vless/${USERNAME}
fi
echo "${IPLIMIT}" >/etc/vless/${USERNAME}IP
# shellcheck disable=SC2002
TLS="443"
# shellcheck disable=SC2002
NTLS="80"
UUID=$(cat /proc/sys/kernel/random/uuid)
VLESS_LINK_TLS="vless://${UUID}@${DOMAIN}:${TLS}?path=/vless&security=tls&encryption=none&type=ws#${USERNAME}"
VLESS_LINK_NTLS="vless://${UUID}@${DOMAIN}:${NTLS}?path=/vless&encryption=none&type=ws#${USERNAME}"
VLESS_LINK_GRPC="vless://${UUID}@${DOMAIN}:${TLS}?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=bug.com#${USERNAME}"

# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vless$/a\#vl '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vlessgrpc$/a\#vlg '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json

systemctl restart xray > /dev/null 2>&1

cat >/var/www/html/vless-$USERNAME.txt <<-END

=========================
  SmileVPN TUNNELING 
=========================
# Format Vless WS TLS

- name: $USERNAME
  server: ${DOMAIN}
  port: 443
  type: vless
  uuid: ${UUID}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vless
    headers:
  Host: ${DOMAIN}

# Format Vless WS Non TLS

- name: $USERNAME
  server: ${DOMAIN}
  port: 80
  type: vless
  uuid: ${UUID}
  cipher: auto
  tls: false
  skip-cert-verify: false
  servername: ${DOMAIN}
  network: ws
  ws-opts:
    path: /vless
    headers:
      Host: ${DOMAIN}
  udp: true

# Format Vless gRPC (SNI)

- name: $USERNAME
  server: ${DOMAIN}
  port: 443
  type: vless
  uuid: ${UUID}
  cipher: auto
  tls: true
  skip-cert-verify: true
  servername: ${DOMAIN}
  network: grpc
  grpc-opts:
  grpc-mode: gun
    grpc-service-name: vless-grpc

=========================
Link Akun Vless 
=========================
Link TLS      : 
${VLESS_LINK_TLS}
=========================
Link none TLS : 
${VLESS_LINK_NTLS}
=========================
Link GRPC     : 
${VMESS_LINK_GRPC}
=========================

END

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "        Vless Account" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Remarks        : ${USERNAME}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Domain         : ${DOMAIN}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "ISP            : ${ISP}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "CITY           : ${CITY}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Wildcard       : (bug.com).${DOMAIN}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "LImit Quota    : ${IPLIMIT} GB" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Limit Ip       : ${IPLIMIT} IP" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Port TLS       : ${TLS}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Port none TLS  : ${NTLS}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "id             : ${UUID}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Encryption     : none" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Network        : ws" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Path           : /vless/multipath" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Dynamic        : https://bugmu.com/path" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Path           : vless-grpc" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Link TLS       : ${VLESS_LINK_TLS}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Link none TLS  : ${VLESS_LINK_NTLS}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Link gRPC      : ${VLESS_LINK_GRPC}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "OpenClash      : https://${DOMAIN}:81/vless-$USERNAME.txt" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "Expired On     : ${EXPIRED_AT}" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/vless/akun/log-create-${USERNAME}.log
