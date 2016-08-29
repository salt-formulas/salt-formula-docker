
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

Host
----

.. code-block:: yaml

    docker:
      host:
        enabled: true

Client
------

    docker:
      client:
        container:
          jenkins:
            # Don't start automatically
            start: false
            restart: unless-stopped
            image: jenkins:2.7.1
            ports:
              - 8081:8080
              - 50000:50000
            environment:
              JAVA_OPTS: "-Dhudson.footerURL=https://www.example.com"
            volumes:
              - /srv/volumes/jenkins:/var/jenkins_home

Registry
--------

.. code-block:: yaml

    docker:
      registry:
        log:
          level: debug
          formatter: json
        cache:
          engine: redis
          host: localhost
        storage:
          engine: filesystem
          root: /srv/docker/registry
        bind:
          host: 0.0.0.0
          port: 5000
        hook:
          mail:
            levels:
              - panic
            # Options are rendered as yaml as is so use hook-specific options here
            options:
              smtp:
                addr: smtp.sendhost.com:25
                username: sendername
                password: password
                insecure: true
              from: name@sendhost.com
              to:
                - name@receivehost.com

Docker login to private registry
--------------------------------

.. code-block:: yaml

    docker:
      host:
        enabled: true
        registry:
          first:
            address: private.docker.com
            user: username
            password: password
          second:
            address: private2.docker.com
            user: username2
            password: password2

Read more
---------

* https://docs.docker.com/installation/ubuntulinux/
* https://github.com/saltstack-formulas/docker-formula

