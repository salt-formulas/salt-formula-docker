{% from "docker/map.jinja" import host with context %}
{%- if host.enabled %}

docker_packages:
  pkg.latest:
  - pkgs: {{ host.pkgs }}

net.ipv4.ip_forward:
  sysctl.present:
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

docker_service:
  service.running:
  - name: {{ host.service }}
  - require:
    - pkg: docker_packages

{%- endif %}