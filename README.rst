
======
Docker
======

Docker is a platform for developers and sysadmins to develop, ship, and run applications. Docker lets you quickly assemble applications from components and eliminates the friction that can come when shipping code. Docker lets you get your code tested and deployed into production as fast as possible.

Docker is supported on the following systems:

* Debian 8.0 Jessie (64-bit)
* Ubuntu Trusty 14.04 (LTS) (64-bit)
* Ubuntu Precise 12.04 (LTS) (64-bit)
* Ubuntu Raring 13.04 and Saucy 13.10 (64 bit)

Sample pillar
-------------

.. code-block:: yaml

    docker:
      host:
        enabled: true

Containers
----------

    docker:
      host:
        container:
          registry:
            image: "registry:2"
            runoptions:
              - -e "REGISTRY_STORAGE=inmemory"
              - -e "GUNICORN_OPTS=[\"--preload\"]"
              - "--log-driver=syslog"
              - "-p 5000:5000"
              - "--rm"

Compose
-------

.. code-block:: yaml

    docker:
      compose:
        container:
          postgres:
            restart: always
            image: postgres:latest
            volumes_from:
              - memcached
            ports:
              - "5432:5432"


Read more
---------

* https://docs.docker.com/installation/ubuntulinux/
* https://github.com/saltstack-formulas/docker-formula
 