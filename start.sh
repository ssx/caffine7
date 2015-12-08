#!/bin/bash

# make sure the logfile exists before we try to tail it
/bin/touch /var/log/php7.0-fpm.log

# start all the services
/usr/local/bin/supervisord -n
