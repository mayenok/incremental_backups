FROM mariadb:10.5.13
COPY enable-binary-log.cnf /etc/mysql/conf.d
COPY entrypoint.sh /usr/local/bin/
VOLUME /incremental-logs/
ENTRYPOINT ["entrypoint.sh"]
