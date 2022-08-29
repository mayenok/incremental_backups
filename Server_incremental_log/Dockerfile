FROM mariadb:10.5.13
COPY enable-binary-log.cnf /etc/mysql/conf.d
#RUN chmod -R 777 /var/log/mysql
COPY entrypoint.sh /usr/local/bin/
VOLUME /Volumes/incremental/
ENTRYPOINT ["entrypoint.sh"]
CMD [""]

