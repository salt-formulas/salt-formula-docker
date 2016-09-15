{% from "docker/map.jinja" import host with context %}
{%- if host.enabled %}

docker_packages:
  pkg.installed:
  - pkgs: {{ host.pkgs }}

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
  - watch_in:
    - service: docker_service

{%- endif %}

/etc/docker/daemon.json:
  file.managed:
  - source: salt://docker/files/daemon.json
  - template: jinja
  - require:
    - pkg: docker_packages
  - watch_in:
    - service: docker_service

docker_service:
  service.running:
  - name: {{ host.service }}
  - enable: true
  - require:
    - pkg: docker_packages

{%- if host.registry is defined %}

{%- for name,registry in host.registry.iteritems() %}

docker_{{ registry.address }}_login:
  cmd.run:
  - name: 'docker login -u {{ registry.user }} -p {{ registry.password }} {{ registry.address }}'
  - unless: grep {{ registry.address }} /root/.docker/config.json

{%- endfor %}

{%- endif %}

{%- endif %}
