{% from "docker/map.jinja" import host with context %}
{%- if host.enabled %}

docker_packages:
  pkg.installed:
    - names: 

    python-apt

docker-dependencies:
   pkg.installed:
    - pkgs:
      - iptables
      - ca-certificates
      - lxc

docker_repo:
  pkgrepo.managed:
  - repo: 'deb http://get.docker.io/ubuntu docker main'
  - file: '/etc/apt/sources.list.d/docker.list'
  - key_url: salt://docker/docker.pgp
  - require_in:
    - pkg: lxc-docker
    - require:
      - pkg: docker-python-apt

lxc-docker:
  pkg.latest:
    - require:
      - pkg: docker-dependencies

docker:
  service.running