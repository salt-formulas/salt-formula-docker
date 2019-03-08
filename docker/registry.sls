{%- from "docker/map.jinja" import registry with context -%}
{%- if registry.get('enabled', True) %}

docker_registry_packages:
  pkg.installed:
    - pkgs: {{ registry.pkgs | json }}
    - watch_in:
      - service: docker_registry_service

docker_registry_service:
  service.running:
    - name: {{ registry.service }}
    - enable: true
    - require:
      - pkg: docker_registry_packages

docker_registry_config:
  file.managed:
    - name: /etc/docker/registry/config.yml
    - source: salt://docker/files/registry.yml
    - template: jinja
    - require:
      - pkg: docker_registry_packages
    - watch_in:
      - service: docker_registry_service

{%- if registry.storage.engine == 'filesystem' %}
docker_registry_storage_root:
  file.directory:
    - name: {{ registry.storage.root }}
    - owner: docker-registry
    - group: docker-registry
    - mode: 750
{%- endif %}

{%- endif %}
