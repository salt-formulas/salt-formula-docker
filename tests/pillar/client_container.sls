docker:
  client:
    enabled: true
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
    compose:
      source:
        engine: pip