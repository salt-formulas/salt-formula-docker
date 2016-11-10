{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for name, service in client.get('service', {}).iteritems() %}
{%- if service.get('enabled', True) %}

docker_service_{{ name }}_create:
  cmd.run:
    - name: >
        docker service create
        --name {{ name }}
        --with-registry-auth
        {%- for env, value in service.get('environment', {}).iteritems() %} -e {{ env }}="{{ value }}"{%- endfor %}
        {%- for port in service.get('ports', []) %} -p {{ port }}{%- endfor %}
        {%- for label, value in service.get('label', {}).iteritems() %} -l {{ label }}="{{ value }}"{%- endfor %}
        {%- if service.network is defined %} --network {{ service.network }}{%- endif %}
        {%- if service.replicas is defined %} --replicas {{ service.replicas }}{%- endif %}
        {%- if service.user is defined %} --user {{ service.user }}{%- endif %}
        {%- if service.workdir is defined %} --workdir {{ service.workdir }}{%- endif %}
        {%- if service.mode is defined %} --mode {{ service.mode }}{%- endif %}
        {%- if service.endpoint is defined %} --endpoint-mode {{ service.endpoint }}{%- endif %}
        {%- if service.constraint is defined %} --constraint {{ service.constraint }}{%- endif %}
        {%- for name, volume in service.get('volume', {}).iteritems() %} --mount {% for key, value in volume.iteritems() %}{{ key }}={{ value }}{% if not loop.last %},{% endif %}{% endfor %}{%- endfor %}
        {%- for param, value in service.get('restart', {}).iteritems() %} --restart-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('update', {}).iteritems() %} --update-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('log', {}).iteritems() %} --log-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('limit', {}).iteritems() %} --limit-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('reserve', {}).iteritems() %} --reserve-{{ param }} {{ value }}{%- endfor %}
        {{ service.image }}
        {%- if service.command is defined %} {{ command }}{%- endif %}
        {%- for arg in service.get('args', []) %} {{ arg }}{%- endif %}
    - unless: "docker service ls | grep {{ name }}"

{%- if service.get('update_service', False) %}
docker_service_{{ name }}_update:
  cmd.run:
    - name: >
        docker service update
        --name {{ name }}
        --with-registry-auth
        {%- if service.replicas is defined %} --replicas {{ service.replicas }}{%- endif %}
        {%- if service.user is defined %} --user {{ service.user }}{%- endif %}
        {%- if service.workdir is defined %} --workdir {{ service.workdir }}{%- endif %}
        {%- if service.endpoint is defined %} --endpoint-mode {{ service.endpoint }}{%- endif %}
        {%- for param, value in service.get('restart', {}).iteritems() %} --restart-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('update', {}).iteritems() %} --update-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('log', {}).iteritems() %} --log-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('limit', {}).iteritems() %} --limit-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('reserve', {}).iteritems() %} --reserve-{{ param }} {{ value }}{%- endfor %}
        --image {{ service.image }}
        {{ name }}
    - require:
      - cmd: docker_service_{{ name }}_create
{%- endif %}

{%- else %}

docker_service_{{ name }}_rm:
  cmd.run:
    - name: docker service rm {{ name }}
    - onlyif: "docker service ls | grep {{ name }}"

{%- endif %}
{%- endfor %}
