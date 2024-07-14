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


# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vmess$/a\### '"${USERNAME} ${EXPIRED_AT}"'\
},{"id": "'""${UUID}""'","alterId": '"0"',"email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#vmessgrpc$/a\### '"${USERNAME} ${EXPIRED_AT}"'\
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

if [ ! -e /etc/vmess ]; then
  mkdir -p /etc/vmess
fi

if [[ $IPLIMIT -gt 0 ]]; then
mkdir -p /etc/kyt/limit/vmess/ip
echo -e "$IPLIMIT" > /etc/kyt/limit/vmess/ip/$USERNAME
else
echo > /dev/null
fi

if [ -z ${Quota} ]; then
  Quota="0MB"
fi


# Menghapus semua karakter kecuali angka, MB, dan GB
sanitized_input=$(echo "${Quota}" | sed -E 's/[^0-9MBmbGBgb]*//g')

# Mendeteksi apakah input berisi MB atau GB

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
      echo "${d}" >/etc/vmess/${USERNAME}
    fi

if [ ! -e /etc/vmess/${USERNAME} ]; then
    Quota1="Unlimited"
else
    baca1=$(cat /etc/vmess/${USERNAME})
    Quota1=$(con ${baca1})
fi

if [ ! -e /etc/kyt/limit/vmess/ip/$USERNAME ]; then
    iplimit="Unlimited"
else
    iplimit=$(cat /etc/kyt/limit/vmess/ip/$USERNAME)
fi


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "        Vmess Account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Remarks        : ${USERNAME}"
echo "ISP            : ${ISP}"
echo "CITY           : ${CITY}"
echo "DOMAIN         : ${DOMAIN}"
echo "Wildcard       : (bug.com).${DOMAIN}"
echo "User Quota     : ${Quota1}"
echo "User Ip        : ${IPLIMIT} IP"
echo "Port TLS       : ${TLS}"
echo "Port none TLS  : ${NTLS}"
echo "Port gRPC      : ${TLS}"
echo "id             : ${UUID}"
echo "alterId        : 0"
echo "Security       : auto"
echo "Network        : ws"
echo "Path           : /vmess/multipath"
echo "Dynamic        : https://bugmu.com/path"
echo "ServiceName    : vmess-grpc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link TLS       : ${VMESS_LINK_TLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link none TLS  : ${VMESS_LINK_NTLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link gRPC      : ${VMESS_LINK_GRPC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OpenClash : https://${DOMAIN}:81/vmess-$USERNAME.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Expired On     : ${EXPIRED_AT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
