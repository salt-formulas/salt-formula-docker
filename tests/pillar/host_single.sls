docker:
  host:
    enabled: true
    options:
      bip: 192.168.0.1/24
      log-driver: json-file
      log-opts:
        size: 50m
      insecure-registry:
      - srv01
      - srv02
      - srv03
