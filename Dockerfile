FROM ubuntu:14.04
MAINTAINER Scott Wilcox <scott@dor.ky>

# stop upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl
ENV DEBIAN_FRONTEND noninteractive

# generate locale
RUN locale-gen en_US.UTF-8

# add php7 repo
RUN apt-get install -y openssh-server software-properties-common mysql-server mysql-client nginx python-setuptools curl git unzip
RUN LC_ALL=en_US.UTF-8 add-apt-repository -y ppa:ondrej/php-7.0

# update dependancies
RUN apt-get update
RUN apt-get -y upgrade

# install our packages
RUN apt-get install -y php7.0-common php7.0-cgi php7.0-cli php7.0-phpdbg php7.0-fpm php7.0-dbg php7.0-curl php7.0-gd php7.0-imap php7.0-intl php7.0-ldap php7.0 php7.0-json php7.0-sqlite3 php7.0-mysql php7.0-opcache

# supervisord
RUN /usr/bin/easy_install supervisor
RUN /usr/bin/easy_install supervisor-stdout
ADD ./conf/supervisord.conf /etc/supervisord.conf

# mysql
EXPOSE 3306
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

# php-fpm config
RUN mkdir /run/php
RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/upload_max_filesize\s*=\s*2M/upload_max_filesize = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/post_max_size\s*=\s*8M/post_max_size = 100M/g" /etc/php/7.0/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php/7.0/fpm/php-fpm.conf
RUN sed -i -e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" /etc/php/7.0/fpm/pool.d/www.conf
RUN find /etc/php/7.0/cli/conf.d/ -name "*.ini" -exec sed -i -re 's/^(\s*)#(.*)/\1;\2/g' {} \;

# nginx
EXPOSE 80
RUN sed -i -e"s/keepalive_timeout\s*65/keepalive_timeout 2/" /etc/nginx/nginx.conf
RUN sed -i -e"s/keepalive_timeout 2/keepalive_timeout 2;\n\tclient_max_body_size 100m/" /etc/nginx/nginx.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./conf/nginx.conf /etc/nginx/sites-available/default
ADD www /usr/share/nginx/www
RUN chown -R www-data:www-data /usr/share/nginx/www

# switch to work dir
WORKDIR /usr/share/nginx/www

# add bootstrap script
ADD ./start.sh /start.sh
RUN chmod 755 /start.sh

# volumes
VOLUME ["/var/lib/mysql", "/usr/share/nginx/www"]

# bootstrap fire
CMD ["/bin/bash", "/start.sh"]
