#!/bin/bash

#source docker-entrypoint.sh mysqld

bash /usr/local/bin/docker-entrypoint.sh mysqld --help

rm -- /var/log/mysql/* 2>/dev/null || true

_term() {
  echo "Stopping mysql server"
  MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqladmin shutdown -uroot
}

trap _term SIGTERM

echo "Starting mysql server";
bash /usr/local/bin/docker-entrypoint.sh mysqld &

child=$!
wait "$child"

shopt -s extglob
mysqlbinlog --skip-annotate-row-events \
            --base64-output=never \
            --short-form \
            /var/log/mysql/mysql-bin.+([0-9]) \
            > /volumes/incremental-logs/$(date +%Y-%m-%d_%H-%M-%S).sql
