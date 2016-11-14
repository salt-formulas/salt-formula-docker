{% from "docker/map.jinja" import swarm with context %}
{%- if swarm.enabled|default(True) %}

include:
  - docker.host

{%- if swarm.role == 'master' %}

docker_swarm_init:
  cmd.run:
    - name: >
        docker swarm init
        {%- if swarm.advertise_addr is defined %} --advertise-addr {{ swarm.advertise_addr }}{%- endif %}
        {%- if swarm.get('bind', {}).get('address', None) %} --listen-addr {{ swarm.bind.address }}{% if swarm.bind.port is defined %}:{{ swarm.bind.port }}{% endif %}{%- endif %}
    - unless: "test -e /var/lib/docker/swarm/state.json"
    - require:
      - service: docker_service

docker_swarm_grains_publish:
  module.run:
  - name: mine.update
  - watch:
    - cmd: docker_swarm_init

{%- else %}

{%- for node_name, node_grains in salt['mine.get']('*', 'grains.items').iteritems() %}
{%- if node_grains.get("docker_swarm_AdvertiseAddr", None) == swarm.master.host+":"+swarm.master.port|string %}
{%- set join_token = node_grains.get('docker_swarm_tokens').get(swarm.role, "unknown") %}

docker_swarm_join:
  cmd.run:
    - name: >
        docker swarm join
        --token {{ join_token }}
        {%- if swarm.advertise_addr is defined %} --advertise-addr {{ swarm.advertise_addr }}{%- endif %}
        {%- if swarm.get('bind', {}).get('address', None) %} --listen-addr {{ swarm.bind.address }}{% if swarm.bind.port is defined %}:{{ swarm.bind.port }}{% endif %}{%- endif %}
        {{ swarm.master.host }}:{{ swarm.master.port }}
    - unless: "test -e /var/lib/docker/swarm/state.json"
    - require:
      - service: docker_service

{%- endif %}
{%- endfor %}

{%- endif %}

{%- endif %}
