=====
Usage
=====

Docker is a platform for developers and system administrators for developing,
shipping, and running applications. Docker enables you to quickly assemble
applications from components and eliminates the friction that can come when
shipping the code. Also, with Docker, you get your code tested and deployed
into production as fast as possible.

This file provides the sample configurations for different use cases.

Docker host configuration samples
=================================

* Docker host sample pillar configuration:

  .. code-block:: yaml

    docker:
      host:
        enabled: true
        options:
          bip: 172.31.255.1/16
          insecure-registries:
            - 127.0.0.1
            - 10.0.0.1
          log-driver: json-file
          log-opts:
            max-size: 50m

* Proxy configuration for Docker host:

  .. code-block:: yaml

    docker:
      host:
        proxy:
          enabled: true
          http: http://user:pass@proxy:3128
          https: http://user:pass@proxy:3128
          no_proxy:
            - localhost
            - 127.0.0.1
            - docker-registry


Docker Swarm configuration samples
==================================

Role can be master, manager, or worker. Master is the first manager that
will initialize the swarm.

* Metadata for manager (the first node):

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

* Metadata for worker:

  .. code-block:: yaml

    docker:
      host:
        enabled: true
      swarm:
        role: worker
        master:
          host: 192.168.1.5
          port: 2377

The token to join to the master node is obtained from grains using
``salt.mine``.  In case of any ``join_token undefined`` issues, verify that
you have ``docker_swarm_`` grains available.

Docker client configuration samples
===================================

* Container:

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

* Docker compose:

  The states providing this functionality include:

  - docker.client.stack
  - docker.client.compose

  Stack is new and works with Docker Swarm Mode.
  Compose is legacy and works only if node is not a member of Swarm.
  Metadata for both states are similar and differs only in implementation.

  * Stack:

    .. code-block:: yaml

        docker:
          client:
            stack:
              django_web:
                enabled: true
                update: true
                environment:
                  SOMEVAR: somevalue
                version: "3.1"
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

  * Compose

    You can install ``docker-compose`` using one of the following options:

    - Distribution package (default)
    - Using Pip
    - Using Docker container

    Install ``docker-compose`` using Docker (default is distribution package):

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

* Registry

  .. code-block:: yaml

    docker:
      client:
        registry:
          target_registry: apt:5000
          image:
            - registry: docker
              name: compose:1.8.0
            - registry: tcpcloud
              name: jenkins:latest
            - registry: ""
              name: registry:2
              target_registry: myregistry

Docker Service configuration samples
====================================

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

Docker Registry configuration samples
=====================================

* Basic Docker Registry configuration:

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

* Docker login to private registry:

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

Docker container service management configuration samples
=========================================================

* Start a service in a container:

  .. code-block:: yaml

     contrail_control_started:
       dockerng_service.start:
         - container: f020d0d3efa8
         - service: contrail-control

  or

  .. code-block:: yaml

     contrail_control_started:
       dockerng_service.start:
         - container: contrail_controller
         - service: contrail-control

* Stop a service in a container:

.. code-block:: yaml

    contrail_control_stoped:
      dockerng_service.stop:
        - container: f020d0d3efa8
        - service: contrail-control

* Restart a service in a container:

.. code-block:: yaml

    contrail_control_restart:
      dockerng_service.restart:
        - container: f020d0d3efa8
        - service: contrail-control

* Enable a service in a container:

.. code-block:: yaml

    contrail_control_enable:
      dockerng_service.enable:
        - container: f020d0d3efa8
        - service: contrail-control

* Disable a service in a container:

.. code-block:: yaml

    contrail_control_disable:
      dockerng_service.disable:
        - container: f020d0d3efa8
        - service: contrail-control

**Read more**

* https://docs.docker.com/installation/ubuntulinux/
* https://github.com/saltstack-formulas/docker-formula

**Documentation and bugs**

* http://salt-formulas.readthedocs.io/
   Learn how to install and update salt-formulas

* https://github.com/salt-formulas/salt-formula-docker/issues
   In the unfortunate event that bugs are discovered, report the issue to the
   appropriate issue tracker. Use the Github issue tracker for a specific salt
   formula

* https://launchpad.net/salt-formulas
   For feature requests, bug reports, or blueprints affecting the entire
   ecosystem, use the Launchpad salt-formulas project

* https://launchpad.net/~salt-formulas-users
   Join the salt-formulas-users team and subscribe to mailing list if required

* https://github.com/salt-formulas/salt-formula-docker
   Develop the salt-formulas projects in the master branch and then submit pull
   requests against a specific formula

* #salt-formulas @ irc.freenode.net
   Use this IRC channel in case of any questions or feedback which is always
   welcome
