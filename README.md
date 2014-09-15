skeleton-docker
===============


Setup
==

Generate keys for host and container
```sh
ssh-keygen -t rsa -C "your_email@example.com"
```

Add your public key to container
```sh
cat ~/.ssh/id_rsa.pub > ./authorized_keys
```

Configure ssmtp.conf
```sh
vi ssmtp.conf
```

Run stack 
```sh
fig up -d
```

Shh
```sh
ssh devop@0.0.0.0:2221
```

web
```sh
echo '0.0.0.0 syfon.dev' >> /etc/hosts
syfon.dev:8001
```

Stack
==

##PHP
* php5 
* php-apc 
* php-gettext
* php-pear
* php5-cli
* php5-common
* php5-curl
* php5-dev
* php5-gd
* php5-imagick
* php5-intl
* php5-json 
* php5-mcrypt 
* php5-mysqlnd
* php5-readline
* php5-xdebug
* php5-xmlrpc

##Other
* phpunit
* composer
* sass
* less
* coffee-script
* ruby
* msmtprc
* bower
* grunt-cli
* nodejs
* rsyslog
* phantomjs
