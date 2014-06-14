
# Docker

Formulas for working with Docker

## Sample pillar

    django_pki:
      server:
        enabled: true
        secret_key: 'y5m^_^ak6+y5m^_y5m^_^ak6+^ak6+5(f...'
        default_key_length: 2048
        default_country: 'CZ'
        passphrase_min_length: 12
        workers: 3
        bind:
          address: 0.0.0.0
          port: 8642
          protocol: tcp
        source:
          engine: 'git'
          address: 'git@repo.domain.com:django/django-pki.git'
          rev: 'master'
        cache:
          engine: 'memcached'
          host: '127.0.0.1'
          prefix: 'CACHE_DJANGO_PKI'
        database:
          engine: 'postgresql'
          host: '127.0.0.1'
          name: 'django_pki'
          password: 'pwd'
          user: 'django_pki'
        mail:
          host: 'mail.domain.com'
          password: 'mail-pwd'
          user: 'mail-user'

## Read more

* https://github.com/saltstack-formulas/docker-formula
* 