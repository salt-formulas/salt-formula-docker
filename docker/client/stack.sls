{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for app, compose in client.stack.items() %}
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
        volume: {{ compose.volume|default({}) }}
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

    {%- for name, service in compose.service.items() %}
      {%- for volume in service.get('volumes', []) %}
        {%- if volume is string and ':' in volume %}
          {%- set path = volume.split(':')[0] %}
        {%- elif volume is mapping and volume.get('type', 'bind') == 'bind' %}
          {%- set path = volume.source %}
        {%- else %}
          {%- set path = None %}
        {%- endif %}

        {%- if path != None and path not in compose.get('volume', {}).keys() %}
docker_{{ app }}_{{ name }}_volume_{{ path }}:
  file.directory:
    - name: {{ path }}
    - makedirs: true
    - unless: "test -e {{ path }}"
        {%- endif %}
      {%- endfor %}
    {%- endfor %}

    {%- if compose.enabled|default(True) %}

docker_stack_{{ app }}:
  cmd.run:
    - name: >
        retry=5
        i=1;
        while [[ $i -lt $retry ]]; do
          docker stack deploy --compose-file docker-compose.yml {{ app }};
          ret=$?;
          if [[ $ret -eq 0 ]]; then echo 'Stack created'; break;
          else
            echo "Stack creation failed, retrying in 3 seconds.." >&2;
            sleep 3;
            i=$(( i + 1 ));
          fi;
          if [[ $i -ge $retry ]]; then
            echo "Stack creation failed!"; exit 1;
          fi;
        done;
    - shell: /bin/bash
    - cwd: {{ client.compose.base }}/{{ app }}
    - user: {{ compose.user|default("root") }}
    - unless: "docker stack ls | grep '{{ app }}'"
    - require:
      - file: docker_{{ app }}_env
      - file: docker_{{ app }}_compose

docker_stack_{{ app }}_update:
  cmd.wait:
    - name: >
        retry=5
        i=1;
        while [[ $i -lt $retry ]]; do
          docker stack deploy --compose-file docker-compose.yml {{ app }};
          ret=$?;
          if [[ $ret -eq 0 ]]; then echo 'Stack updated'; break;
          else
            echo "Stack update failed, retrying in 3 seconds.." >&2;
            sleep 3;
            i=$(( i + 1 ));
          fi;
          if [[ $i -ge $retry ]]; then
            echo "Stack update failed!"; exit 1;
          fi;
        done;
    - shell: /bin/bash
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
