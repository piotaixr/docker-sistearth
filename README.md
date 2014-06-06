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

* Replacing ``nginx-config`` file by your own config
* Copy/paste your SSH public key in ``authorized_keys``
* Generating RSA keys for your container and placing them along to the Dockerfile
* Editing ``init.sh`` to place your own database initialization queries
* Run ``bash docker build .``

Tips :
------

You still have to set acl to symfony's cache and logs folders.
If your Docker don't have that feature by default, here is a workaround :

* Add : ``DOCKER_OPTS="${DOCKER_OPTS} --storage-driver=devicemapper"`` in ``/etc/default/docker``
* Run : ``sudo service docker restart``