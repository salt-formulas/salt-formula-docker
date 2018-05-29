{% from "docker/map.jinja" import host with context %}

{%- if host.enabled %}

{%- if grains.os == 'CentOS' %}
docker_requirements:
  pkg.installed:
    - pkgs:
      - yum-utils
{%- endif %}

docker_packages:
  pkg.installed:
  - pkgs: {{ host.pkgs }}


{%- if grains.get('virtual_subtype', None) not in ['Docker', 'LXC'] %}

network.ipv4.ip_forward:
  sysctl.present:
    - name: net.ipv4.ip_forward
    - value: 1

{%- endif %}

{%- if grains.os == 'Ubuntu' %}

/etc/default/docker:
  file.managed:
  - source: salt://docker/files/default
  - template: jinja
  - require:
    - pkg: docker_packages
  - watch_in:
    - service: docker_service

{%- endif %}


{%- if grains.os == 'RedHat' or grains.os == 'CentOS' %}

/etc/sysconfig/docker-storage-setup:
  file.managed:
  - source: salt://docker/files/docker-storage-setup
  - template: jinja
  - makedirs: True
  - require:
    - pkg: docker_packages
  - watch_in:
    - service: docker_service

{%- else %}

/etc/docker/daemon.json:
  file.managed:
  - source: salt://docker/files/daemon.json
  - template: jinja
  - makedirs: True
  - require:
    - pkg: docker_packages
  - watch_in:
    - service: docker_service

{%- endif %}

{%- if host.get('proxy', {}).get('enabled', False) %}
{%- if host.proxy.get('http') or host.proxy.get('https') or host.proxy.get('no_proxy') %}

/etc/systemd/system/docker.service.d/http-proxy.conf:
  file.managed:
  - source: salt://docker/files/http-proxy.conf
  - template: jinja
  - makedirs: True
  - require_in:
    - service: docker_service
  - watch_in:
    - service: docker_service

{% else %}

/etc/systemd/system/docker.service.d/http-proxy.conf:
  file.absent

{%- endif %}

systemd_reload_due_proxy:
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /etc/systemd/system/docker.service.d/http-proxy.conf

{%- endif %}


docker_service:
  service.running:
  - name: {{ host.service }}
  - enable: true
  {%- if grains.get('noservices') %}
  - onlyif: /bin/false
  {%- endif %}
  - require:
    - pkg: docker_packages

{%- if host.registry is defined %}

{%- for name,registry in host.registry.iteritems() %}

docker_{{ registry.get('address', name) }}_login:
  cmd.run:
  - name: 'docker login -u {{ registry.user }} -p {{ registry.password }}{% if registry.get('address') %} {{ registry.address }}{% endif %}'
  - user: {{ registry.get('system_user', 'root') }}
  - unless: grep {{ registry.address|default('https://index.docker.io/v1/') }} {{ salt['user.info'](registry.get('system_user', 'root')).home }}/.docker/config.json

{%- endfor %}

{%- endif %}

{%- endif %}
