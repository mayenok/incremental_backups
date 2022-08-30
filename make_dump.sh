docker exec -i incremental_backups bash -c \
 'mysqldump -p$MYSQL_ROOT_PASSWORD --skip-comments --flush-logs --delete-master-logs --single-transaction --all-databases | gzip' \
 > ./$(date +%d-%m-%Y_%H-%M-%S).gz
