{% from "docker/map.jinja" import swarm with context %}
{%- if swarm.enabled|default(True) %}

include:
  - docker.host

{%- for name, network in swarm.get('network', {}).iteritems() %}
{%- if network.get('enabled', True) %}

docker_swarm_network_{{ name }}_create:
  cmd.run:
    - name: >
        docker network create
        {%- if network.get('attachable', False) %} --attachable {%- endif %}
        {%- if network.get('internal', False) %} --internal {%- endif %}
        {%- if network.get('ipv6', False) %} --ipv6 {%- endif %}
        {%- if network.driver is defined %} --driver {{ network.driver }} {%- endif %}
        {%- if network.gateway is defined %} --gateway {{ network.gateway }} {%- endif %}
        {%- if network.iprange is defined %} --ip-range {{ network.iprange }} {%- endif %}
        {%- if network.ipamdriver is defined %} --ipam-driver {{ network.ipamdriver }} {%- endif %}
        {%- if network.subnet is defined %} --subnet {{ network.subnet }} {%- endif %}
        {%- for param,value in network.get('opt', {}).iteritems() %} --opt {{ param }}={{ value }} {%- endfor %}
        {{ name }}
    - unless: "docker network ls | grep {{ name }}"
    - require_in:
      {%- if swarm.role == 'master' %}
      - cmd: docker_swarm_init
      {%- else %}
      - cmd: docker_swarm_join
      {%- endif %}

{%- endif %}
{%- endfor %}

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

{%- set join_token = None %}

{%- for node_name, node_grains in salt['mine.get']('*', swarm.mine_function).iteritems() %}
{%- if node_grains.get("docker_swarm_AdvertiseAddr", None) == swarm.master.host|string+":"+swarm.master.port|string %}
{%- set join_token = node_grains.get('docker_swarm_tokens').get(swarm.role, "unknown") %}
{%- endif %}
{%- endfor %}

{%- set join_token = swarm.get('join_token', {}).get(swarm.role, join_token) %}

{%- if join_token %}

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

{%- endif %}

{%- endif %}
