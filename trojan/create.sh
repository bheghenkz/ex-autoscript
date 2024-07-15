#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2
IPLIMIT="5"
QUOTA="0"

IP=$(curl -s ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)


if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
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
echo "${d}" >/etc/trojan/${USERNAME}
fi
echo "${IPLIMIT}" >/etc/trojan/${USERNAME}IP
#ISP=$(cat /etc/xray/isp)
#CITY=$(cat /etc/xray/city)
# shellcheck disable=SC2002
TLS="443"
# shellcheck disable=SC2002
NTLS="80"
UUID=$(cat /proc/sys/kernel/random/uuid)
TROJAN_LINK_TLS="trojan://${UUID}@isi_bug_disini:${TLS}?path=%2Ftrojan-ws&security=tls&host=${DOMAIN}&type=ws&sni=${DOMAIN}#${USERNAME}"
TROJAN_LINK_GRPC="trojan://${UUID}@${DOMAIN}:${TLS}?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=bug.com#${USERNAME}"
TROJAN_LINK_NTLS="trojan://${UUID}@isi_bug_disini:${NTLS}?path=%2Ftrojan-ws&security=none&host=${DOMAIN}&type=ws#${USERNAME}"

# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#trojanws$/a\#tr '"$USERNAME $EXPIRED_AT"'\
},{"password": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#trojangrpc$/a\#trg '"$USERNAME $EXPIRED_AT"'\
},{"password": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json


systemctl restart xray > /dev/null 2>&1

cat >/var/www/html/trojan-$USERNAME.txt <<-END
=========================
   SmileVPN Tunneling 
=========================

# Format Trojan GO/WS

- name: $USERNAME
  server: ${DOMAIN}
  port: 443
  type: trojan
  password: ${UUID}
  network: ws
  sni: ${DOMAIN}
  skip-cert-verify: true
  udp: true
  ws-opts:
    path: /trojan-ws
    headers:
  Host: ${DOMAIN}

# Format Trojan gRPC

- name: $USERNAME
  type: trojan
  server: ${DOMAIN}
  port: 443
  password: ${UUID}
  udp: true
  sni: ${DOMAIN}
  skip-cert-verify: true
  network: grpc
  grpc-opts:
    grpc-service-name: trojan-grpc

END

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "           TROJAN ACCOUNT" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Remarks       : ${USERNAME}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "ISP           : ${ISP}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "CITY          : ${CITY}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Host/IP       : ${DOMAIN}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "User Quota    : ${QUOTA}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "User Ip       : ${IPLIMIT} IP" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Wildcard      : (bug.com).${DOMAIN}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Port TLS      : ${TLS}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Port none TLS : ${NTLS}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Port gRPC     : ${TLS}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Key           : ${UUID}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Path          : /trojan-ws/multipath" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Dynamic       : https://bugmu.com/path" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "ServiceName   : trojan-grpc" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "OpenClash     : https://${DOMAIN}:81/trojan-$USERNAME.txt" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log 
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Link TLS      : ${TROJAN_LINK_TLS}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Link none TLS : ${TROJAN_LINK_NTLS}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Link gRPC     : ${TROJAN_LINK_GRPC}" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "Expired At    : ${EXPIRED_AT} " | tee -a /etc/trojan/akun/log-create-${USERNAME}.log
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a /etc/trojan/akun/log-create-${USERNAME}.log