FROM alpine:3.20

RUN apk add --no-cache samba-server shadow \
    && rm -rf /var/cache/apk/* \
    && mkdir -p /games /var/log/samba

COPY smb.conf /etc/samba/smb.conf
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 445

ENTRYPOINT ["/entrypoint.sh"]
