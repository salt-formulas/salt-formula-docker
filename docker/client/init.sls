{% from "docker/map.jinja" import client with context %}
{%- if client.get('enabled') %}

include:
  {%- if client.network is defined %}
  - docker.client.network
  {%- endif %}
  - docker.client.container
  {%- if client.compose is defined %}
  - docker.client.compose
  {%- endif %}
  {%- if client.stack is defined %}
  - docker.client.stack
  {%- endif %}
  {%- if client.registry is defined %}
  - docker.client.registry
  {%- endif %}
  {%- if client.service is defined %}
  - docker.client.service
  {%- endif %}

docker_python:
  pkg.installed:
    - names: {{ client.pkgs }}

{%- endif %}
