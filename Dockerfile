
FROM alpine:3.21 AS builder

ARG PGBOUNCER_VERSION=xxx

RUN set -ex \
      && PGBOUNCER_VERSION_UNDERSCORE=`echo "${PGBOUNCER_VERSION}" | tr '.' '_'` \
      && apk update \
      && apk add --no-cache \
           autoconf \
           automake \
           build-base \
           c-ares-dev \
           wget \
           libevent-dev \
           pkgconf \
           openssl-dev \
      && mkdir -p /pgbouncer \
      && cd /pgbouncer \
      && wget https://github.com/pgbouncer/pgbouncer/releases/download/pgbouncer_${PGBOUNCER_VERSION_UNDERSCORE}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
      && tar zxvf pgbouncer-${PGBOUNCER_VERSION}.tar.gz \
      && cd pgbouncer-${PGBOUNCER_VERSION} \
      && ./configure \
      && make \
      && mv pgbouncer /pgbouncer/ \
      && cd /pgbouncer \
      && ./pgbouncer --version

# --------------


FROM alpine:3.21

COPY --from=builder /pgbouncer/pgbouncer /usr/bin/

RUN set -ex \
      && apk add --no-cache $(scanelf --needed --nobanner /usr/bin/pgbouncer | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | sort -u) \
      && pgbouncer --version

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

