#!/bin/bash
/usr/bin/mysqld_safe &
sleep 10s

# php5-fpm
/bin/touch /var/log/php5-fpm.log

mysqladmin -u root password vagrant
mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"
mysql -uroot -pvagrant -e "CREATE DATABASE vagrant; GRANT ALL PRIVILEGES ON vagrant.* TO 'vagrant'@'localhost' IDENTIFIED BY 'vagrant'; FLUSH PRIVILEGES;"
killall mysqld

# start all the services
/usr/local/bin/supervisord -n
