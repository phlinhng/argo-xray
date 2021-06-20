#!/bin/sh

XRAY_VLESS_UUID=$1
XRAY_VLESS_WSPATH=$2
ARGO_TUNNEL_HOSTNAME=$3

cat > "./etc/xray/01_inbounds.json" <<-EOF
{
  "inbounds": [
    {
      "protocol": "vless",
      "listen": "0.0.0.0",
      "port": 2083,
      "settings": {
        "clients": [
          {
            "id": "$XRAY_VLESS_UUID"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": "parkingpage.namecheap.com:80"
          },
          {
            "path": "$XRAY_VLESS_WSPATH",
            "dest": "localhost:30800"
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "serverName": "$ARGO_TUNNEL_HOSTNAME",
          "alpn": ["http/1.1"],
          "minVersion": "1.2",
          "maxVersion": "1.3",
          "certificates": [
            {
              "certificateFile": "./ssl/xray.crt",
              "keyFile": "./ssl/xray.key"
            }
          ]
        }
      }
    },
    {
      "protocol": "vless",
      "listen": "0.0.0.0",
      "port": 30800,
      "settings": {
        "clients": [
          {
            "id": "$XRAY_VLESS_UUID"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none"
        },
      "wsSettings": {
          "path": "$XRAY_VLESS_WSPATH"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ]
}
EOF

exit