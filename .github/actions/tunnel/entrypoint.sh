#!/bin/sh

ARGO_TUNNEL_NAME=$1
XTLS_VLESS_UUID=$2
XRAY_GRPC_SERVICENAME=$3

cat > "/root/xray-config.json" <<-EOF
{
  "inbounds": [
    {
      "protocol": "vless",
      "listen": "0.0.0.0",
      "port": 443,
      "settings": {
        "clients": [
          {
            "uuid": "$XTLS_VLESS_UUID",
            "flow": "xtls-rprx-direct"
          }
        ]
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
        }
        "grpcSettings": {
          "serviceName": "$XRAY_GRPC_SERVICENAME"
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [ "http", "tls"]
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

cloudflared tunnel run --url localhost:443 $ARGO_TUNNEL_NAME &
xray run -config /xray-config.json &