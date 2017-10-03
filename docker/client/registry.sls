{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for image in client.registry.get('image', {}) %}

{%- set target_registry = image.get('target_registry', client.registry.target_registry) ~ '/' %}
{%- if image.registry is defined and image.registry != "" and image.registry is not none %}
{%- set source_registry = image.registry ~ '/' %}
{%- else %}
{%- set source_registry = "" %}
{%- endif %}

docker_image_{{ image.name }}_pull:
  cmd.run:
    - name: docker pull {{ source_registry }}{{ image.name }}

docker_image_{{ image.name }}_tag:
  cmd.run:
    - name: docker tag {{ source_registry }}{{ image.name }} {{ target_registry }}{{ image.name }}
    - require:
        - cmd: docker_image_{{ image.name }}_pull

docker_image_{{ image.name }}_push:
  cmd.run:
    - name: docker push {{ target_registry }}{{ image.name }}
    - require:
        - cmd: docker_image_{{ image.name }}_tag

{%- endfor %}