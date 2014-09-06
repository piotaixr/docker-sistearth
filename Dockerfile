# Sistearth's Dockerfile
# ======================
#
# Used to generate a docker container for Sistearth V4
# Heavily edited from John Fink's docker-lampstack 
# (https://github.com/jbfink/docker-lampstack)
#
#
# VERSION : 0.1

FROM ubuntu:latest

MAINTAINER Dale, <dale-sistearth@outlook.com>

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
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client mysql-server 
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
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php5/fpm/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php5/cli/php.ini

RUN find /etc/nginx/sites-enabled/ -type l -exec rm -v "{}" \;
ADD nginx-config /etc/nginx/sites-available/sistearth.com
RUN ln -s /etc/nginx/sites-available/sistearth.com /etc/nginx/sites-enabled/sistearth.com
RUN service nginx restart

#
# User
# ----
#

RUN adduser --gecos "" sistearth
RUN adduser sistearth sudo
RUN mkdir -p /var/www
RUN chown sistearth:sistearth /var/www/
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
RUN mkdir /home/sistearth/.ssh
ADD id_rsa /home/sistearth/.ssh/id_rsa
ADD id_rsa.pub /home/sistearth/.ssh/id_rsa.pub
ADD authorized_keys /home/sistearth/.ssh/authorized_keys
RUN chown sistearth:sistearth /home/sistearth/.ssh -R

# 
# SSL
# ---
#
# Adding crt, pem, key
#
RUN mkdir /home/sistearth/ssl
ADD private.pem /home/sistearth/ssl/public.pem
ADD public.pem /home/sistearth/ssl/private.pem
ADD server.crt /home/sistearth/ssl/server.crt
ADD server.csr /home/sistearth/ssl/server.csr
ADD server.key /home/sistearth/ssl/server.key


#
# Other configurations
# --------------------
#
# Using a script : 
# - generate random passwords (sistearth user, root mysql, sistearth mysql)
#
# Passwords are visible in 'docker build' display
#

ADD init.sh /init.sh
RUN chmod 755 /init.sh
RUN bash /init.sh
RUN rm /init.sh

EXPOSE 22 80

CMD ["/usr/bin/supervisord", "-n"]
