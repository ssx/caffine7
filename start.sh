#!/bin/bash

# php5-fpm
/bin/touch /var/log/php7.0-fpm.log

# start all the services
/usr/local/bin/supervisord -n
