#!/bin/bash

#source docker-entrypoint.sh mysqld

bash /usr/local/bin/docker-entrypoint.sh mysqld --help

#rm -- /var/log/mysql/* || true

_term() {
  echo "Stopping mysql server"
  MYSQL_PWD=$MARIADB_ROOT_PASSWORD mysqladmin shutdown -uroot --socket="${SOCKET}"
}

trap _term SIGTERM

echo "Starting mysql server";
bash /usr/local/bin/docker-entrypoint.sh mysqld &

child=$!
wait "$child"

shopt -s extglob
mysqlbinlog /var/log/mysql/mysql-bin.+([0-9]) > /Volumes/incremental/$(date +%Y-%m-%d_%H-%M-%S)-inc.sql
