FROM pgduckdb/pgduckdb:17-main

USER root

# Install OpenSSL and useful extensions then
# Allow the postgres user to execute certain commands as root without a password
RUN apt-get -qqy --fix-missing update && \
    apt-get -qqy --fix-missing install postgresql-common && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get -qqy --fix-missing install openssl postgresql-17-age postgresql-17-h3 postgresql-17-postgis-3 postgresql-17-pgvector postgresql-17-timescaledb postgresql-plpython3-17 sudo && \
    apt-get -qqy dist-upgrade && \
    rm -rf /var/lib/apt/lists/* && \
    echo "postgres ALL=(root) NOPASSWD: /usr/bin/mkdir, /bin/chown, /usr/bin/openssl" > /etc/sudoers.d/postgres

# Add init scripts while setting permissions
COPY --chmod=755 init-ssl.sh /docker-entrypoint-initdb.d/init-ssl.sh
COPY --chmod=755 wrapper.sh /usr/local/bin/wrapper.sh

ENTRYPOINT ["wrapper.sh"]
CMD ["postgres", "-p", "5432", "-c", "listen_addresses=*"]
