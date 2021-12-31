#!/bin/bash
set -e

generate_certs() {
    local generate_cert=0
    # First check $SSL_BUMP_CERT_DIR which is expected to contain
    # exactly one .crt file and exactly one .key file.
    for ext in .crt .key; do
      if ! test -f $SSL_BUMP_CERT_DIR/*$ext; then
          generate_cert=1
      fi
    done
    if [ $generate_cert -eq 1 ]; then
      echo "Generating self-signed certificate for SSL bumping"
      openssl req -x509 -newkey rsa:4096 \
              -keyout /etc/ssl/certs/selfsigned.key \
              -out /etc/ssl/certs/selfsigned.crt \
              -subj "/C=CA/ST=BC/L=Vancouver/O=Squid/OU=Squid/CN=example.com" \
              -days 1000 -nodes
    else
      echo "Using $(ls $SSL_BUMP_CERT_DIR/*.crt) for SSL bumping"
      cp $SSL_BUMP_CERT_DIR/*.crt /etc/ssl/certs/selfsigned.crt
      cp $SSL_BUMP_CERT_DIR/*.key /etc/ssl/certs/selfsigned.key
    fi
    chmod 644 /etc/ssl/certs/selfsigned.key /etc/ssl/certs/selfsigned.crt
}

update_squid_configs() {
    if [ "$(ls -A $SQUID_USER_CONFIG_DIR/conf.d/*.conf 2>/dev/null)" ]; then
        for f in $(ls $SQUID_USER_CONFIG_DIR/conf.d/*.conf); do
            cp $f $SQUID_CONFIG_DIR/conf.d/
        done
    fi
    if [ "$(ls -A $SQUID_USER_CONFIG_DIR/acls/.txt 2>/dev/null)" ]; then
        for f in $(ls $SQUID_USER_CONFIG_DIR/acls/*.txt); do
            cp $f $SQUID_CONFIG_DIR/acls/
        done
    fi
}

generate_certs
update_squid_configs
/usr/lib/squid/security_file_certgen -c -s /tmp/squid/ssl_db -M 512MB
chown -R proxy:proxy /tmp/squid/ssl_db

if [ "$1" != '--' ]; then
  /usr/sbin/squid -NYCd 1
else
  shift
  exec $@
fi
