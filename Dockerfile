FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive
ENV SQUID_CONFIG_DIR /etc/squid
ENV SQUID_USER_CONFIG_DIR /squid
ENV SSL_BUMP_CERT_DIR /certs
ARG SQUID_VERSION=5.6-1

# apt packages
RUN apt-get update && apt-get upgrade --yes && \
      apt-get install -y \
      ca-certificates \
      software-properties-common

# Install squid from sid
RUN apt-add-repository -y \
      "deb http://http.us.debian.org/debian sid main" && \
    apt-get update && \
    apt-get -t sid install -y \
    squid-openssl=${SQUID_VERSION} \
    squid-purge=${SQUID_VERSION} \
    squidclient=${SQUID_VERSION} && \
    apt-get clean && \
    add-apt-repository --remove "deb http://http.us.debian.org/debian sid main" && \
    rm -rf /var/lib/apt && \
    rm -rf /var/lib/dpkg

COPY squid/etc/squid $SQUID_CONFIG_DIR
RUN mkdir -p /tmp/coredumps && \
    mkdir -p /tmp/squid /var/spool/squid && \
    mkdir $SSL_BUMP_CERT_DIR && \
    mkdir -p $SQUID_USER_CONFIG_DIR/acls && \
    mkdir -p $SQUID_USER_CONFIG_DIR/conf.d

RUN usermod -a -G tty proxy

COPY scripts/docker-entrypoint.sh /docker-entrypoint.sh

COPY squid/ssl_bump_certs/* $SSL_BUMP_CERT_DIR/

WORKDIR /

EXPOSE 3128
EXPOSE 3129

ENTRYPOINT ["/docker-entrypoint.sh"]
