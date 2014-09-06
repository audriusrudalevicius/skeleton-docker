# ======================
#
# VERSION : 0.1

FROM ubuntu:latest

MAINTAINER Audrius, <d3trax@gmail.com>

#
# Preparing package installation
# ------------------------------
#
# Add latest PHP 5 sources
#

RUN dpkg-divert --local --rename /usr/bin/ischroot && ln -sf /bin/true /usr/bin/ischroot

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install software-properties-common python-software-properties
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:ondrej/php5
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository -y ppa:nginx/stable


#
# Installing packages
# -------------------
#
# 'DEBIAN_FRONTEND=noninteractive' : disable prompts
#

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install nginx php5-fpm
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install php5 php-apc php-gettext php-pear php5-cli php5-common php5-curl php5-dev php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd\
 php5-readline\
 php5-xdebug\
 php5-xmlrpc
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git openssh-server supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pwgen vim curl less bash-completion acl
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install byobu tree
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install wget build-essential openssl
RUN DEBIAN_FRONTEND=noninteractive apt-get install -q -y msmtp ca-certificates

#
# Installing composer
# -------------------
#
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer


#
# Configuring supervisor
# ----------------------
#
# Adding custom config
# Adding log folder
#

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN mkdir -p /var/log/supervisor

#
# Configuring Nginx and PHP
# -------------------------
#

RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Vilnius/g' /etc/php5/fpm/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Vilnius/g' /etc/php5/cli/php.ini

RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN find /etc/nginx/sites-enabled/ -type l -exec rm -v "{}" \;
ADD nginx.conf /etc/nginx/sites-available/syfon.dev
RUN ln -s /etc/nginx/sites-available/syfon.dev /etc/nginx/sites-enabled/syfon.dev

RUN echo "xdebug.remote_enable = 1\nxdebug.max_nesting_level = 5000\nxdebug.var_display_max_depth = 8\nxdebug.remote_autostart=0\nxdebug.remote_connect_back=1\nxdebug.remote_port=9000" >> /etc/php5/fpm/conf.d/20-xdebug.ini
RUN echo "xdebug.remote_enable = 1\nxdebug.max_nesting_level = 5000\nxdebug.var_display_max_depth = 8\nxdebug.remote_autostart=0\nxdebug.remote_connect_back=1\nxdebug.remote_port=9000" >> /etc/php5/cli/conf.d/20-xdebug.ini
RUN composer global require "phpunit/phpunit=4.1.*"

#
# Other
# ----
#
RUN apt-get -y install ruby
RUN gem install sass
RUN add-apt-repository ppa:chris-lea/node.js && apt-get update
RUN apt-get install -y nodejs
RUN npm install -g bower
RUN npm install -g grunt-cli
RUN npm install -g coffee-script
RUN npm install -g less

#
# User
# ----
#

RUN adduser --gecos "" devop
RUN adduser devop sudo
RUN chmod 4755 /usr/bin/sudo

#
# SSH
# ---
#
# Adding keys to use Git
# Adding authorized_keys for login 
#

RUN mkdir /var/run/sshd 
RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
RUN sed -ri 's/#UsePAM no/UsePAM no/g' /etc/ssh/sshd_config
RUN mkdir /home/devop/.ssh
ADD id_rsa /home/devop/.ssh/id_rsa
ADD id_rsa.pub /home/devop/.ssh/id_rsa.pub
ADD authorized_keys /home/devop/.ssh/authorized_keys
RUN chown devop:devop /home/devop/.ssh -R
RUN chmod g-w -R /home/devop/.ssh
RUN chmod 700 /home/devop/.ssh
RUN chmod 600 /home/devop/.ssh/*

#
# WWW
# ---
#

RUN touch /var/log/nginx/project_error.log
RUN mkdir -p /home/devop/www/
RUN chown devop:devop /home/devop/www/
RUN ln -s /var/log/nginx/project_error.log /home/devop/projcet_error.log
RUN chown -R 755 /var/log/nginx

#
# Mail
# ---
#

RUN adduser www-data mail

RUN rm -f /etc/msmtprc

ADD ssmtp.conf /etc/msmtprc
RUN chown devop:mail /etc/msmtprc
RUN chmod 660 /etc/msmtprc

RUN mkdir -p /var/log/msmtp
RUN chown devop:mail /var/log/msmtp

RUN touch /etc/logrotate.d/msmtp
RUN rm /etc/logrotate.d/msmtp
RUN echo "/var/log/msmtp/*.log {\n rotate 12\n monthly\n compress\n missingok\n notifempty\n }" > /etc/logrotate.d/msmtp

RUN sed -i 's/;sendmail_path\s=.*/sendmail_path = \/usr\/bin\/msmtp -t/' /etc/php5/fpm/php.ini
RUN sed -i 's/;sendmail_path\s=.*/sendmail_path = \/usr\/bin\/msmtp -t/' /etc/php5/cli/php.ini

#
# Scripts
# ---
#

ADD init.sh /init.sh
RUN chmod 755 /init.sh
RUN bash /init.sh
RUN rm /init.sh
RUN  echo "    IdentityFile ~/.ssh/id_rsa" >> /etc/ssh/ssh_config

#
# Tests
# ---
#

RUN echo "<?php \$headers = 'From: webmaster@example.com'; mail('d3trax@gmail.com', 'Test email using PHP', 'This is a test email message', \$headers, '-fwebmaster@example.com');" > /home/devop/www/test.php
RUN php /home/devop/www/test.php
RUN rm -f /home/devop/www/test.php

EXPOSE 22 80

CMD ["/usr/bin/supervisord", "-n"]
