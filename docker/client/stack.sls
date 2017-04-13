{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for app, compose in client.stack.iteritems() %}
  {%- if compose.service is defined %}

docker_{{ app }}_dir:
  file.directory:
    - name: {{ client.compose.base }}/{{ app }}
    - makedirs: true

docker_{{ app }}_compose:
  file.managed:
    - name: {{ client.compose.base }}/{{ app }}/docker-compose.yml
    - source: salt://docker/files/docker-compose.yml
    - template: jinja
    - defaults:
        compose: {{ compose }}
        service: {{ compose.service }}
        network: {{ compose.network|default({}) }}
    - require:
        - file: docker_{{ app }}_dir

    {%- if compose.environment is defined %}

docker_{{ app }}_env:
  file.managed:
    - name: {{ client.compose.base }}/{{ app }}/.env
    - source: salt://docker/files/docker-env
    - template: jinja
    - user: {{ compose.user|default("root") }}
    - mode: 640
    - defaults:
        env: {{ compose.environment }}
    - require:
        - file: docker_{{ app }}_dir

    {%- else %}

docker_{{ app }}_env:
  file.absent:
    - name: {{ client.compose.base }}/{{ app }}/.env

    {%- endif %}

    {%- if compose.enabled|default(True) %}

docker_stack_{{ app }}:
  cmd.run:
    - name: docker stack deploy --compose-file docker-compose.yml {{ app }}
    - cwd: {{ client.compose.base }}/{{ app }}
    - user: {{ compose.user|default("root") }}
    - unless: "docker stack ls | grep '{{ app }}'"
    - require:
      - file: docker_{{ app }}_env
      - file: docker_{{ app }}_compose

docker_stack_{{ app }}_update:
  cmd.wait:
    - name: docker stack deploy --compose-file docker-compose.yml {{ app }}
    - cwd: {{ client.compose.base }}/{{ app }}
    - user: {{ compose.user|default("root") }}
    - require:
      - cmd: docker_stack_{{ app }}
    - watch:
      - file: docker_{{ app }}_env
      - file: docker_{{ app }}_compose

    {%- else %}

docker_remove_{{ app }}:
  cmd.run:
    - name: docker stack rm {{ app }}
    - user: {{ compose.user|default("root") }}
    - onlyif: "docker stack ls | grep '{{ app }}'"

    {%- endif %}

  {%- else %}

    {#-
      No stack.service is defined so we can add support for deploying using
      bundle file, etc.
    #}

  {%- endif %}
{%- endfor %}
