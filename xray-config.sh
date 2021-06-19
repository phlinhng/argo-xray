#!/bin/sh

XRAY_VLESS_UUID=$1
XRAY_GRPC_SERVICENAME=$2

cat > "/xray-config.json" <<-EOF
{
  "inbounds": [
    {
      "protocol": "vless",
      "listen": "0.0.0.0",
      "port": 443,
      "settings": {
        "clients": [
          {
            "id": "$XRAY_VLESS_UUID"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "tls",
        "tlsSettings": {
          "alpn": ["http/2"],
          "certificates": [
            {
              "certificateFile": "/etc/xray.crt",
              "keyFile": "/etc/xray.key"
            }
          ]
        },
        "grpcSettings": {
          "serviceName": "$XRAY_GRPC_SERVICENAME"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": ["http", "tls"]
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "IPIfNonMatch",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      },
      {
      "type": "field",
      "protocol": [
        "bittorrent"
      ],
      "outboundTag": "blocked"
      }
    ]
  }
}
EOF