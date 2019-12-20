{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for name, network in client.get('network', {}).items() %}
{%- if network.get('enabled', True) %}

docker_network_{{ name }}_create:
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
        {%- for param,value in network.get('opt', {}).items() %} --opt {{ param }}={{ value }} {%- endfor %}
        {{ name }}
    - unless: "docker network ls | grep {{ name }}"

{%- else %}

docker_service_{{ name }}_rm:
  cmd.run:
    - name: docker network rm {{ name }}
    - onlyif: "docker network ls | grep {{ name }}"

{%- endif %}
{%- endfor %}
