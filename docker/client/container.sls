{% from "docker/map.jinja" import client with context %}
{% from "docker/map.jinja" import blacklist with context %}

include:
  - docker.client

{%- for name, container in client.get('container', {}).iteritems() %}
  {%- set id = name %}
  {%- set required_containers = [] %}

{%- if not grains.get('noservices') %}

{{id}}_image:
  {%- if grains['saltversioninfo'] >= [2017, 7, 0] %}
  docker_image.present:
  {%- else %}
  dockerng.image_present:
  {%- endif %}
    - name: {{ container.image }}
    {%- if container.build is defined %}
    - build: {{ container.build }}
    {%- endif %}
    - force: {{ container.force|default(False) }}
    - require:
      - pkg: docker_python

{%- endif %}

{%- set binds = {} %}
{%- set volumes = {} %}
{%- for volume in container.get('volumes', []) %}

  {%- set volume_parts = volume.split(':') %}
  {%- set path = volume_parts[0] %}

  {%- if volume_parts is iterable and volume_parts|length > 1 %}
  {# volume is bind #}
    {%- do binds.update({volume:volume}) %}
  {%- else %}
    {%- do volumes.update({volume:volume}) %}
  {%- endif %}

  {%- if path.startswith('/') and container.makedirs|default(True) %}
{{ id }}_volume_{{ path }}:
  file.directory:
    - name: {{ path }}
    - makedirs: true
  {%- endif %}

{%- endfor %}

{%- if not grains.get('noservices') %}

{{id}}_container:
  {%- if grains['saltversioninfo'] >= [2017, 7, 0] %}
  docker_container.running:
  {%- else %}
  dockerng.running:
  {%- endif %}
    - name: {{id}}
    - start: {{ container.start|default(True) }}
    - user: {{ container.user|default("root") }}
    - image: {{container.image}}
    - privileged: {{ container.privileged|default(False) }}
  {%- if 'command' in container %}
    - command: {{container.command}}
  {%- endif %}
  {%- if 'environment' in container and container.environment is iterable %}
    - environment:
    {%- for variable, value in container.environment.iteritems() %}
        - {{variable}}: {{value}}
    {%- endfor %}
  {%- endif %}
  {%- if 'ports' in container and container.ports is iterable %}
    - port_bindings:
    {% for port in container.ports %}
      - {{ port }}
    {% endfor %}
  {%- endif %}
  {%- if volumes %}
    - volumes:
    {%- for volume in volumes.iterkeys() %}
      - {{volume}}
    {%- endfor %}
  {%- endif %}
  {%- if binds %}
    - binds:
    {%- for bind in binds.iterkeys() %}
      - {{ bind }}
    {%- endfor %}
  {%- endif %}
  {%- if 'volumes_from' in container %}
    - volumes_from:
    {%- for volume in container.volumes_from %}
      {%- do required_containers.append(volume) %}
      - {{volume}}
    {%- endfor %}
  {%- endif %}
  {%- if 'links' in container %}
    - links:
    {%- for link in container.links %}
      {%- set name, alias = link.split(':',1) %}
      {%- do required_containers.append(name) %}
        {{name}}: {{alias}}
    {%- endfor %}
  {%- endif %}
  {%- if 'restart' in container %}
    - restart_policy: {{ container.restart }}
  {%- endif %}
    - watch:
  {%- if grains['saltversioninfo'] >= [2017, 7, 0] %}
      - docker_image: {{id}}_image
  {%- else %}
      - dockerng: {{id}}_image
  {%- endif %}
  {%- if required_containers is defined %}
    {%- for containerid in required_containers %}
      {%- if grains['saltversioninfo'] >= [2017, 7, 0] %}
      - docker_container: {{containerid}}
      {%- else %}
      - dockerng: {{containerid}}
      {%- endif %}
    {%- endfor %}
  {%- endif %}
  {%- for key, value in container.iteritems() %}
    {%- if key not in blacklist.dockerng_running %}
    - {{ key }}: {{ value }}
    {%- endif %}
  {%- endfor %}

{%- endif %}

{% endfor %}
