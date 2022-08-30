#!/bin/bash

bash /usr/local/bin/docker-entrypoint.sh mysqld --help

rm -- /var/log/mysql/* 2>/dev/null || true

shopt -s extglob

_term() {
  echo "Saving SQL logs"
  mysqlbinlog --skip-annotate-row-events \
              --base64-output=never \
              --short-form \
              /var/log/mysql/mysql-bin.+([0-9]) \
              > /volumes/incremental-logs/"$(date +%Y-%m-%d_%H-%M-%S)".sql

  echo "Adding log entries into a database"
  for entry in "/volumes/incremental-logs"/*
  do
   filename=$(basename "$entry")
   mysql -p"$MYSQL_ROOT_PASSWORD" -e "use test_db;insert ignore into executed_incremental_logs (log) values ('$filename');"
  done

  echo "Stopping mysql server"
  MYSQL_PWD="$MYSQL_ROOT_PASSWORD" mysqladmin shutdown -uroot
}

trap _term SIGTERM

echo "Starting mysql server";
bash /usr/local/bin/docker-entrypoint.sh mysqld &

child=$!
wait "$child"
