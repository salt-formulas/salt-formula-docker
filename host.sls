{% from "docker/map.jinja" import host with context %}
{%- if host.enabled %}

{%- if grains.os == 'Ubuntu' %}

docker_repo:
  pkgrepo.managed:
  - repo: 'deb http://get.docker.io/ubuntu docker main'
  - file: '/etc/apt/sources.list.d/docker.list'
  - key_url: salt://docker/files/docker_apt.pgp
  - require_in:
    - pkg: docker_packages

{%- endif %}

docker_packages:
  pkg.latest:
  - pkgs: {{ host.pkgs }}

docker_service:
  service.running:
  - name: {{ host.service }}
  - require:
    - pkg: docker_packages

{%- endif %}