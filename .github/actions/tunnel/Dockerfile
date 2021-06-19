FROM alpine:latest

RUN apk add curl

# Install Argo Tunnel Client
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/download/${ARGO_VERSION}/cloudflared-linux-amd64 -o /usr/bin/cloudflared
RUN chmod +x /usr/bin/cloudflared

# Copy Argo TLS Token
RUN mkdir -p /root/.cloudflared
RUN echo $ARGO_TLS_TOKEN > /root/.cloudflared/cert.pem

# Install Xray-core
RUN curl -fsSL https://github.com/XTLS/xray-core/releases/download/v${XRAY_VERSION}/Xray-linux-64.zip -o Xray-linux-64.zip
RUN unzip -qq Xray-linux-64.zip
RUN mv xray /usr/bin/xray && chmod /usr/bin/xray
RUN mv geo*.dat /usr/bin

# Copy TLS cert and key
RUN echo $XRAY_TLS_CERT > /etc/xray.crt
RUN echo $XRAY_TLS_KEY > /etc/xray.key

# Copy entrypoint.sh and make it excutable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["$ARGO_TUNNEL_NAME", "$XRAY_VLESS_UUID", "$XRAY_GRPC_SERVICENAME"]