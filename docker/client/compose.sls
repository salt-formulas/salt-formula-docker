{% from "docker/map.jinja" import client with context %}

include:
  - docker.client
  {%- if client.compose.source.engine == 'docker' %}
  - docker.host
  {%- endif %}

{%- if client.compose.source.engine == 'pkg' %}
docker_compose:
  pkg.installed:
    - names: {{ client.compose.source.pkgs }}
{%- elif client.compose.source.engine == 'pip' %}
docker_compose_python_pip:
  pkg.installed:
    - name: python-pip

docker_compose:
  pip.installed:
    - name: docker-compose
    - require:
      - pkg: docker_compose_python_pip
{%- elif client.compose.source.engine == 'docker' %}
docker_compose_wrapper:
  file.managed:
    - name: /usr/local/bin/docker-compose
    - source: salt://docker/files/docker-compose
    - template: jinja
    - defaults:
        image: {{ client.compose.source.image|default('docker/compose') }}
    - mode: 755

docker_compose:
  cmd.wait:
    - name: /usr/local/bin/docker-compose version
    - watch:
      - file: docker_compose_wrapper
{%- endif %}

{%- for app, compose in client.compose.iteritems() %}
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

{%- if compose.status is defined %}
docker_{{ app }}_{{ compose.status }}:
  cmd.run:
    - name: '{% if client.compose.source.engine == 'pip' %}/usr/local/bin/{%
    endif %}docker-compose {{ compose.status }} -d'
    - cwd: {{ client.compose.base }}/{{ app }}
    - user: {{ compose.user|default("root") }}
    - require:
        {%- if client.compose.source.engine == 'pkg' %}
        - pkg: docker_compose
        {%- elif client.compose.source.engine == 'pip' %}
        - pip: docker_compose
        {%- elif client.compose.source.engine == 'docker' %}
        - cmd: docker_compose
        {%- endif %}
    - watch_in:
      - file: docker_{{ app }}_env
      - file: docker_{{ app }}_compose
{%- endif %}

{%- endif %}
{%- endfor %}
