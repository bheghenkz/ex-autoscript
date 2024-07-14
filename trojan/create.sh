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
sed -i '/#trojanws$/a\#! '"$USERNAME $EXPIRED_AT"'\
},{"password": "'""${UUID}""'","email": "'""${USERNAME}""'"' /etc/xray/config.json
# shellcheck disable=SC2027
# shellcheck disable=SC2086
# shellcheck disable=SC1004
sed -i '/#trojangrpc$/a\#! '"$USERNAME $EXPIRED_AT"'\
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

if [ ! -e /etc/trojan ]; then
  mkdir -p /etc/trojan
fi

if [[ $IPLIMIT -gt 0 ]]; then
mkdir -p /etc/kyt/limit/trojan/ip
echo -e "$IPLIMIT" > /etc/kyt/limit/trojan/ip/$USERNAME
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
      echo "${d}" >/etc/trojan/${USERNAME}
    fi

if [ ! -e /etc/trojan/${USERNAME} ]; then
    Quota1="Unlimited"
else
    baca1=$(cat /etc/trojan/${USERNAME})
    Quota1=$(con ${baca1})
fi

if [ ! -e /etc/kyt/limit/trojan/ip/$USERNAME ]; then
    iplimit="Unlimited"
else
    iplimit=$(cat /etc/kyt/limit/trojan/ip/$USERNAME)
fi


echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "           TROJAN ACCOUNT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Remarks       : ${USERNAME}"
echo "ISP           : ${ISP}"
echo "CITY          : ${CITY}"
echo "Host/IP       : ${DOMAIN}"
echo "User Quota    : ${Quota1}"
echo "User Ip       : ${IPLIMIT} IP"
echo "Wildcard      : (bug.com).${DOMAIN}"
echo "Port TLS      : ${TLS}"
echo "Port none TLS : ${NTLS}"
echo "Port gRPC     : ${TLS}"
echo "Key           : ${UUID}"
echo "Path          : /trojan-ws/multipath"
echo "Dynamic       : https://bugmu.com/path"
echo "ServiceName   : trojan-grpc"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OpenClash     : https://${DOMAIN}:81/trojan-$USERNAME.txt" 
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link TLS      : ${TROJAN_LINK_TLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link none TLS : ${TROJAN_LINK_NTLS}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Link gRPC     : ${TROJAN_LINK_GRPC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Expired At    : ${EXPIRED_AT} "
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"