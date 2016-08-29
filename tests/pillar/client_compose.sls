docker:
  client:
    enabled: true
    compose:
      source:
        engine: pip
      django_web:
        # Run up action, any positional argument to docker-compose CLI
        # If not defined, only docker-compose.yml is generated
        status: up
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
