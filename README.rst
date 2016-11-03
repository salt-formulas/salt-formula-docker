
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
        insecure_registries:
          - 127.0.0.1
        log:
          engine: json-file
          size: 50m

Swarm
-----

Role can be master, manager or worker. Where master is the first manager that
will initialize the swarm.

Metadata for manager (first node):

.. code-block:: yaml

    docker:
      host:
        enabled: true
      swarm:
        role: manager
        advertise_addr: 192.168.1.5
        bind:
          address: 192.168.1.5
          port: 2377

Metadata for worker:

.. code-block:: yaml

    docker:
      host:
        enabled: true
      swarm:
        role: worker
        master:
          host: 192.168.1.5
          port: 2377

Token to join to master node is obtained from grains using salt.mine.  In case
of any ``join_token undefined`` issues, ensure you have ``docker_swarm_``
grains available.

Client
------

Container
~~~~~~~~~

.. code-block:: yaml

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

Compose
~~~~~~~

There are three options how to install docker-compose:

- distribution package (default)
- using Pip
- using Docker container

Install docker-compose using Docker (default is distribution package)

.. code-block:: yaml

    docker:
      client:
        compose:
          source:
            engine: docker
            image: docker/compose:1.8.0
          django_web:
            # Run up action, any positional argument to docker-compose CLI
            # If not defined, only docker-compose.yml is generated
            status: up
            # Run image pull every time state is run triggering container
            # restart in case it's changed
            pull: true
            environment:
              SOMEVAR: somevalue
            service:
              db:
                image: postgres
              web:
                image: djangoapp
                volumes:
                  - /srv/volumes/django:/srv/django
                ports:
                  - 8000:8000
                depends_on:
                  - db

Service
-------

To deploy service in Swarm mode, you can use ``docker.client.service``:

.. code-block:: yaml

    parameters:
      docker:
        client:
          service:
            postgresql:
              environment:
                POSTGRES_USER: user
                POSTGRES_PASSWORD: password
                POSTGRES_DB: mydb
              restart:
                condition: on-failure
              image: "postgres:9.5"
              ports:
                - 5432:5432
              volume:
                data:
                  type: bind
                  source: /srv/volumes/postgresql/maas
                  destination: /var/lib/postgresql/data


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

