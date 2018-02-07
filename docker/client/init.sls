{% from "docker/map.jinja" import client with context %}
{%- if client.get('enabled', False) %}

include:
  {%- if pillar.docker.client.network is defined %}
  - docker.client.network
  {%- endif %}
  {%- if pillar.docker.client.container is defined %}
  - docker.client.container
  {%- endif %}
  {%- if pillar.docker.client.compose is defined %}
  - docker.client.compose
  {%- endif %}
  {%- if pillar.docker.client.stack is defined %}
  - docker.client.stack
  {%- endif %}
  {%- if pillar.docker.client.registry is defined %}
  - docker.client.registry
  {%- endif %}
  {%- if pillar.docker.client.service is defined %}
  - docker.client.service
  {%- endif %}

docker_python:
  pkg.installed:
    - names: {{ client.pkgs }}

{%- endif %}
