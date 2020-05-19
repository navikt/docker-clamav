FROM alpine:edge

ENV CLAM_VERSION=0.102.3-r0

RUN apk add --no-cache clamav=$CLAM_VERSION clamav-libunrar=$CLAM_VERSION

# Add certificates
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY *.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates

# Add clamav user
RUN adduser -S -G clamav -u 1000 clamav_user -h /store && \
    mkdir -p /store && \
    mkdir /usr/local/share/clamav && \
    chown -R clamav_user:clamav /store /usr/local/share/clamav /etc/clamav

# Configure Clam AV...
COPY --chown=clamav_user:clamav ./*.conf /etc/clamav/
COPY --chown=clamav_user:clamav eicar.com /
COPY --chown=clamav_user:clamav ./readyness.sh /

# permissions
RUN mkdir /var/run/clamav && \
    chown clamav_user:clamav /var/run/clamav && \
    chmod 750 /var/run/clamav

USER 1000

# initial update of av databases
RUN freshclam

COPY --chown=clamav_user:clamav docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 3310
