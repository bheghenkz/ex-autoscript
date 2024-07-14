#!/bin/bash

USERNAME=$1
PASSWORD=$2
EXPIRED_AT=$3
IPLIMIT="5"

IP=$(curl -s ipv4.icanhazip.com)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
DOMAIN=$(cat /etc/xray/domain)

if [[ $IPLIMIT -gt 0 ]]; then
mkdir -p /etc/xray/sshx
echo -e "$IPLIMIT" > /etc/xray/sshx/${USERNAME}IP
else
echo > /dev/null
fi

useradd -e "${EXPIRED_AT}" -s /bin/false -M "${USERNAME}" &> /dev/null
echo -e "${PASSWORD}\n${PASSWORD}\n" | passwd "${USERNAME}" &> /dev/null
echo -e "### ${USERNAME} ${EXPIRED_AT} ${PASSWORD}" >> /etc/xray/ssh

cat > /var/www/html/ssh-$USERNAME.txt <<-END
=========================
   SmileVpn Tunneling 
=========================

Format SSH OVPN Account
=========================
Username         : $USERNAME
Password         : $PASSWORD
=========================
ISP              : $ISP
CITY             : $CITY
IP               : $IP
Host             : $DOMAIN
Port OpenSSH     : 443, 80, 22
Port Dropbear    : 443, 109
Port Dropbear WS : 443, 109
Port SSH UDP     : 1-65535
Port SSH WS      : 80, 8080, 8081-9999
Port SSH SSL WS  : 443
Port SSL/TLS     : 400-900
Port OVPN WS SSL : 443
Port OVPN SSL    : 443
Port OVPN TCP    : 1194
Port OVPN UDP    : 2200
BadVPN UDP       : 7100, 7300, 7300
=================================
Payload WSS: GET wss://BUG.COM/ HTTP/1.1[crlf]Host: $DOMAIN[crlf]Upgrade: websocket[crlf][crlf] 
=================================
Payload Enchanced: PATCH / HTTP/1.1[crlf]Host: [host][crlf]Host: bug.com[crlf]Upgrade: websocket[crlf]HTTP/ 3600[crlf]Sec-WebSocket-Extensions: superspeed[crlf]
=================================
SSH TLS/SNI : $DOMAIN:443@$USERNAME:$PASSWORD
SSH Non TLS : $DOMAIN:80@$USERNAME:$PASSWORD
=================================
OVPN Download : https://$DOMAIN:81/
=================================
Berakhir Pada    : $EXPIRED_AT
=================================

END

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "            SSH Account"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Username         : ${USERNAME}"
echo "Password         : ${PASSWORD}"
echo "Expired On       : ${EXPIRED_AT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "ISP              : ${ISP}"
echo "CITY             : ${CITY}"
echo "IP               : ${IP}"
echo "Host             : ${DOMAIN}"
echo "Port OpenSSH     : 443, 80, 22"
echo "Port SSH UDP     : 1-65535"
echo "Port Dropbear    : 443, 109"
echo "Port SSH WS      : 80, 8080, 8081-9999"
echo "Port SSH SSL WS  : 443"
echo "Port SSL/TLS     : 400-900"
echo "Port OVPN WS SSL : 443"
echo "Port OVPN SSL    : 443"
echo "Port OVPN TCP    : 443, 1194"
echo "Port OVPN UDP    : 2200"
echo "BadVPN UDP       : 7100, 7300, 7300"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "OVPN Download    : https://$DOMAIN:81/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Http Custom Udp  : ${DOMAIN}:1-65535@${USERNAME}:${PASSWORD}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Save Link Account: https://$DOMAIN:81/ssh-$USERNAME.txt"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Payload WSS"
echo "GET wss://isi_bug_disini HTTP/1.1[crlf]Host: ${DOMAIN}[crlf]Upgrade: websocket[crlf][crlf]"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Payload WS"
echo "GET / HTTP/1.1[crlf]Host: ${DOMAIN}[crlf]Upgrade: websocket[crlf][crlf]"
