FROM alpine:latest

RUN apk add curl tar unzip

# Copy entrypoint.sh and make it excutable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]