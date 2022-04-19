# build v2ray-plugin
FROM golang:1.16-alpine AS v2ray

# ENV GOPROXY="https://proxy.golang.com.cn,direct"
RUN apk add --no-cache --virtual .go-deps\
    git \
    bash \
    && go get github.com/shadowsocks/v2ray-plugin\
    && apk del .go-deps

# use apline instead of alpine:3.9 will cause configure failure
FROM alpine:3.9 AS builder

LABEL maintainer="kev <noreply@datageek.info>, Sah <contact@leesah.name>"

ENV SERVER_ADDR 0.0.0.0
ENV SERVER_PORT 8388
ENV PASSWORD=
ENV METHOD      aes-256-gcm
ENV TIMEOUT     300
ENV DNS_ADDRS    8.8.8.8,8.8.4.4
ENV TZ UTC
ENV ARGS=

WORKDIR ss-libev

RUN set -ex \
 # Build environment setup
 && apk add --no-cache --virtual .build-deps \
      autoconf \
      automake \
      build-base \
      c-ares-dev \
      libcap \
      libev-dev \
      libtool \
      libsodium-dev \
      linux-headers \
      mbedtls-dev \
      pcre-dev \
      git\
 # git clone
 && git clone --recursive https://github.com/shadowsocks/shadowsocks-libev.git \
 && cd shadowsocks-libev \
 # Build & install
 && ./autogen.sh \
 && ./configure --prefix=/usr --disable-documentation \
 && make install \
 && ls /usr/bin/ss-* | xargs -n1 setcap cap_net_bind_service+ep \
 && apk del .build-deps \
 # Runtime dependencies setup
 && apk add --no-cache \
      ca-certificates \
      rng-tools \
      tzdata \
      $(scanelf --needed --nobanner /usr/bin/ss-* \
      | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
      | sort -u) \
 && mkdir plugins \
 && rm -rf /ss-libev/shadowsocks-libev
USER nobody
ADD server-config.json .
COPY --from=v2ray /go/bin/v2ray-plugin ./plugins/

# or use command-line instead of config-file
# CMD ss-server -s $SERVER_ADDR -p $SERVER_PORT -m $METHOD --plugin /ss-libev/plugins/v2ray-plugin --plugin-opts "server"
CMD ss-server -c /ss-libev/server-config.json
