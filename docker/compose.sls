{%- from "docker/map.jinja" import compose with context %}

docker_python:
  pkg.installed:
    - name: python-docker

{%- for name, container in compose.container.items() %}
  {%- set id = name %}
  {%- set required_containers = [] %}

{{id}}_image:
  dockerng.image_present:
    - name: {{ container.image }}
    - require:
      - pkg: docker_python

{{id}}_container:
  dockerng.running:
    - name: {{id}}
    - user: {{ container.user|default("root") }}
    - image: {{container.image}}
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
  {%- if 'volumes' in container %}
    - volumes:
    {%- for volume in container.volumes %}
      - {{volume}}
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
    - require:
      - dockerng: {{id}}_image
  {%- if required_containers is defined %}
    {%- for containerid in required_containers %}
      - dockerng: {{containerid}}
    {%- endfor %}
  {%- endif %}
{% endfor %}
