{% from "docker/map.jinja" import host with context %}
{% from "linux/map.jinja" import system with context %}


{%- if host.enabled %}

linux_packages:
  pkg.installed:
    - pkgs: {{ system.pkgs }}

include:
  - linux.system.repo

docker_packages:
  pkg.installed:
    - refresh: True
    - pkgs: {{ host.pkgs }}

update:
  cmd.run:
  - name: 'apt-get update'

network.ipv4.ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

{%- if grains.os == 'Ubuntu' %}

/etc/default/docker:
  file.managed:
  - source: salt://docker/files/default
  - template: jinja
  - require:
    - pkg: docker_packages
  {%- if not grains.get('noservices','false')%}
  - watch_in:
    - service: docker_service
  {%- endif %}

{%- endif %}

/etc/docker/daemon.json:
  file.managed:
  - source: salt://docker/files/daemon.json
  - template: jinja
  - makedirs: True
  - require:
    - pkg: docker_packages
  {%- if not grains.get('noservices','false')%}
  - watch_in:
    - service: docker_service
  {%- endif %}

{%- if not grains.get('noservices','false')%}

docker_service:
  service.running:
  - name: {{ host.service }}
  - enable: true
  - require:
    - pkg: docker_packages

{%- endif %}


{%- if host.registry is defined %}

{%- for name,registry in host.registry.iteritems() %}

docker_{{ registry.address }}_login:
  cmd.run:
  - name: 'docker login -u {{ registry.user }} -p {{ registry.password }} {{ registry.address }}'
  - unless: grep {{ registry.address }} /root/.docker/config.json

{%- endfor %}

{%- endif %}

{%- endif %}
