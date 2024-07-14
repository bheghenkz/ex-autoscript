#!/bin/bash

USERNAME=$1
EXPIRED_AT=$2
IPLIMIT="3"
Quota="0GB"

IP=$(curl -s ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)

function con(){
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes} B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 )) KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575)/1048576 )) MB"
    else
        echo "$(( (bytes + 1073741823)/1073741824 )) GB"
    fi
}

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
sed -i '/#vless$/a\#& '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vlessgrpc$/a\#& '"${USERNAME} ${EXPIRED_AT}"'\
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

if [ ! -e /etc/vless ]; then
  mkdir -p /etc/vless
fi

if [[ $IPLIMIT -gt 0 ]]; then
mkdir -p /etc/kyt/limit/vless/ip
echo -e "$IPLIMIT" > /etc/kyt/limit/vless/ip/$USERNAME
else
echo > /dev/null
fi

if [ -z ${Quota} ]; then
  Quota="0MB"
fi

# Menghapus semua karakter kecuali angka, MB, dan GB
sanitized_input=$(echo "${Quota}" | sed -E 's/[^0-9MBmbGBgb]*//g')

if [[ $sanitized_input =~ [Mm][Bb]$ ]]; then
  c=$(echo "${sanitized_input}" | sed 's/[Mm][Bb]$//')
  if [[ $c -eq 0 ]]; then
    echo > /dev/null 2>&1
  fi
  d=$((${c} * 1024 * 1024))
elif [[ $sanitized_input =~ [Gg][Bb]$ ]]; then
  c=$(echo "${sanitized_input}" | sed 's/[Gg][Bb]$//')
  if [[ $c -eq 0 ]]; then
    echo > /dev/null 2>&1
  fi
  d=$((${c} * 1024 * 1024 * 1024))
else
  echo "Input tidak valid. Harap masukkan nilai dengan satuan MB atau GB (contoh: 20MB, 2GB)"
  exit 1
fi

if [[ ${c} != "0" ]]; then
  echo "${d}" >/etc/vless/${USERNAME}
fi

if [ ! -e /etc/vless/${USERNAME} ]; then
    Quota1="Unlimited"
else
    baca1=$(cat /etc/vless/${USERNAME})
    Quota1=$(con ${baca1})
fi

if [ ! -e /etc/kyt/limit/vmess/ip/$USERNAME ]; then
    iplimit="Unlimited"
else
    iplimit=$(cat /etc/kyt/limit/vmess/ip/$USERNAME)
fi


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        Vless Account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Remarks        : ${USERNAME}"
echo "Domain         : ${DOMAIN}"
echo "ISP            : ${ISP}"
echo "CITY           : ${CITY}"
echo "Wildcard       : (bug.com).${DOMAIN}"
echo "User Quota     : ${IPLIMIT}"
echo "User Ip        : ${IPLIMIT} IP"
echo "Port TLS       : ${TLS}"
echo "Port none TLS  : ${NTLS}"
echo "id             : ${UUID}"
echo "Encryption     : none"
echo "Network        : ws"
echo "Path           : /vless/multipath"
echo "Dynamic        : https://bugmu.com/path"
echo "Path           : vless-grpc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link TLS       : ${VLESS_LINK_TLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link none TLS  : ${VLESS_LINK_NTLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link gRPC      : ${VLESS_LINK_GRPC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OpenClash      : https://${DOMAIN}:81/vless-$USERNAME.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Expired On     : ${EXPIRED_AT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
