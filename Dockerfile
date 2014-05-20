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
RUN DEBIAN_FRONTEND=noninteractive add-apt-repository ppa:ondrej/php5


#
# Installing packages
# -------------------
#
# 'DEBIAN_FRONTEND=noninteractive' : disable prompts
#

RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-client mysql-server 
RUN DEBIAN_FRONTEND=noninteractive apt-get -y --force-yes install apache2 libapache2-mod-php5
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
# Configuring Apache
# ------------------
#
# Putting our site config
# Disabling all sites config
# Enabling our site config
# Enabling mods
#

RUN find /etc/apache2/sites-enabled/ -type l -exec rm -v "{}" \;
ADD apache-config /etc/apache2/sites-available/sistearth-v4
# RUN a2ensite sistearth-v4
RUN ln -s /etc/apache2/sites-available/sistearth-v4 /etc/apache2/sites-enabled/sistearth-v4
RUN a2enmod rewrite
RUN service apache2 restart

#
# Configuring PHP
# ---------------
# 

RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php5/cli/php.ini
RUN sed -i 's/;date.timezone =/date.timezone = Europe\/Paris/g' /etc/php5/apache2/php.ini

#
# User
# ----
#

RUN adduser --gecos "" sistearth
RUN adduser sistearth sudo
RUN chown sistearth:sistearth /var/www/

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
