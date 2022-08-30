docker exec -i incremental_backups bash -c 'shopt -s extglob;mysqlbinlog /var/log/mysql/mysql-bin.+([0-9])' > ./$(date +%Y-%m-%d_%H-%M-%S).sql
