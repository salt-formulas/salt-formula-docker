{%- from "docker/map.jinja" import host with context %}

{%- if host.enabled %}

{% for name, container in host.container.items() %}
docker-image-{{ name }}:
  cmd.run:
    - name: docker pull {{ container.image }}
    - require:
      - service: docker_service

{# TODO: SysV init script #}
{%- set init_system = salt["cmd.run"]("ps -p1 | grep -q systemd && echo systemd || echo upstart") %}

docker-container-startup-config-{{ name }}:
  file.managed:
{%- if init_system == "systemd" %}
    - name: /etc/systemd/system/docker-{{ name }}.service
    - source: salt://docker/files/systemd.conf
{%- elif init_system == "upstart" %}
    - name: /etc/init/docker-{{ name }}.conf
    - source: salt://docker/files/upstart.conf
{%- endif %}
    - mode: 700
    - user: root
    - template: jinja
    - defaults:
        name: {{ name | json }}
        container: {{ container | json }}
    - require:
      - cmd: docker-image-{{ name }}

docker-container-service-{{ name }}:
  service.running:
    - name: docker-{{ name }}
    - enable: True
    - watch:
      - file: docker-container-startup-config-{{ name }}
{% endfor %}

{%- endif %}
