# Symfony2
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
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install php5 php-apc php5-intl php5-cli php5-json php5-mysql
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git openssh-server supervisor
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install pwgen vim curl less bash-completion acl
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install byobu



#
# Installing composer
# -------------------
#
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer


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
# Config
# Disabling all sites config
# Putting our site config
# Enabling our site config
# Enabling mods
#

RUN sed -i -e "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php5/fpm/php.ini
RUN sed -i -e "s/;daemonize\s*=\s*yes/daemonize = no/g" /etc/php5/fpm/php-fpm.conf
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Vilnius/g' /etc/php5/fpm/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Vilnius/g' /etc/php5/cli/php.ini

RUN find /etc/nginx/sites-enabled/ -type l -exec rm -v "{}" \;
ADD nginx.conf /etc/nginx/sites-available/syfon.dev
RUN ln -s /etc/nginx/sites-available/syfon.dev /etc/nginx/sites-enabled/syfon.dev
RUN service nginx restart

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

#
# WWW
# ---
#

RUN mkdir -p /home/devop/www/
RUN chown devop:devop /home/devop/www/

#
# Scripts
# ---
#

ADD init.sh /init.sh
RUN chmod 755 /init.sh
RUN bash /init.sh
RUN rm /init.sh

EXPOSE 22 80

CMD ["/usr/bin/supervisord", "-n"]
