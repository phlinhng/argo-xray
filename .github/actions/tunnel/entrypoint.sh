#!/bin/sh

ARGO_TUNNEL_NAME=$1
ARGO_TUNNEL_TOKEN=$2
XRAY_VLESS_UUID=$3
XRAY_TLS_CERT=$4
XRAY_TLS_KEY=$5
XRAY_GRPC_SERVICENAME=$6
XRAY_VERSION=$7

# Install Argo Tunnel Client
curl -fsSL cloudflared-stable-linux-386.tgz -o cloudflared-stable-linux-386.tgz
tar -xf cloudflared-stable-linux-386.tgz
mv cloudflared /usr/bin/cloudflared && chmod +x /usr/bin/cloudflared

# Copy Argo TLS Token
mkdir -p /root/.cloudflared
echo $ARGO_TUNNEL_TOKEN > /root/.cloudflared/cert.pem

# Install Xray-core
curl -fsSL https://github.com/XTLS/xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip -o Xray-linux-64.zip
unzip -qq -o Xray-linux-64.zip
mv xray /usr/bin/xray && chmod +x /usr/bin/xray
mv geo*.dat /usr/bin

# Copy TLS cert and key
echo $XRAY_TLS_CERT > /etc/xray.crt && chmod 644 /etc/xray.crt
echo $XRAY_TLS_KEY > /etc/xray.key && chmod 644 /etc/xray.key

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

/usr/bin/cloudflared tunnel run --url localhost:443 $ARGO_TUNNEL_NAME
#xray run -config /xray-config.json