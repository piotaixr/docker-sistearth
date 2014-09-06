docker-sistearth
================

A Dockerfile which build a Symfony2-ready container.

Features :
----------

* Latest PHP version
* Composer already installed and available in $PATH
* Apache and PHP 5 already configured
* Using SSH keys to login


What you have to do :
---------------------

## Nginx

* Place your own config in ``nginx-config``

## SSH

* Copy/paste your SSH public key in ``authorized_keys``
* Generate RSA keys for your container and place them along to the Dockerfile

## SSL

Generate following files and place them along to the Dockerfile : 
* server.crt  
* server.csr  
* server.key
* public.pem
* private.pem

## Custom initialization

* Replace ``init.sh`` by your own script

## Let's go !

* Run ``bash docker build .``

Tips :
------

You still have to set acl to symfony's cache and logs folders.
If your Docker don't have that feature by default, here is a workaround :

* Add : ``DOCKER_OPTS="${DOCKER_OPTS} --storage-driver=devicemapper"`` in ``/etc/default/docker``
* Run : ``sudo service docker restart``