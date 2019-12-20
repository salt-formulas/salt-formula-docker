{% from "docker/map.jinja" import client with context %}

include:
  - docker.client

{%- for name, service in client.get('service', {}).items() %}
{%- if service.get('enabled', True) %}

{%- for vname, volume in service.get('volume', {}).items() %}
{%- if volume.get('type', 'bind') == 'bind' %}
docker_service_{{ name }}_volume_{{ vname }}:
  file.directory:
    - name: {{ volume.source }}
    - makedirs: true
    - unless: "test -e {{ volume.source }}"
{%- endif %}
{%- endfor %}

docker_service_{{ name }}_create:
  cmd.run:
    - name: >
        i=1;
        while [ $i -lt 5 ]; do
        docker service create
        --name {{ name }}
        --with-registry-auth
        --detach=true
        {%- for env, value in service.get('environment', {}).items() %} -e {{ env }}="{{ value }}"{%- endfor %}
        {%- for port in service.get('ports', []) %} -p {{ port }}{%- endfor %}
        {%- for name, host in service.get('hosts', {}).items() %} --host {{ host.get('name', name) }}:{{ host.address }}{%- endfor %}
        {%- for label, value in service.get('label', {}).items() %} -l {{ label }}="{{ value }}"{%- endfor %}
        {%- if service.network is defined %} --network {{ service.network }}{%- endif %}
        {%- if service.replicas is defined %} --replicas {{ service.replicas }}{%- endif %}
        {%- if service.user is defined %} --user {{ service.user }}{%- endif %}
        {%- if service.workdir is defined %} --workdir {{ service.workdir }}{%- endif %}
        {%- if service.mode is defined %} --mode {{ service.mode }}{%- endif %}
        {%- if service.endpoint is defined %} --endpoint-mode {{ service.endpoint }}{%- endif %}
        {%- if service.hostname is defined %} --hostname {{ service.hostname }}{%- endif %}
        {%- if service.constraint is defined %} --constraint {{ service.constraint }}{%- endif %}
        {%- for constraint in service.get('constraints', []) %} --constraint {{ constraint }}{%- endfor %}
        {%- for name, volume in service.get('volume', {}).items() %} --mount {% for key, value in volume.items() %}{{ key }}={{ value }}{% if not loop.last %},{% endif %}{% endfor %}{%- endfor %}
        {%- for param, value in service.get('restart', {}).items() %} --restart-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('update', {}).items() %} --update-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('log', {}).items() %} --log-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('limit', {}).items() %} --limit-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('reserve', {}).items() %} --reserve-{{ param }} {{ value }}{%- endfor %}
        {{ service.image }}
        {%- if service.command is defined %} {{ service.command }}{%- endif %}
        {%- for arg in service.get('args', []) %} {{ arg }}{%- endfor %};
        ret=$?;
        [ $ret -eq 0 ] && exit 0;
        echo "Service creation failed, retrying in 3 seconds.." >&2;
        sleep 3;
        i=$[ $i + 1 ];
        done
    - shell: /bin/bash
    - unless: "docker service ls | grep {{ name }}"

{%- if service.get('update_service', False) %}
docker_service_{{ name }}_update:
  cmd.run:
    - name: >
        i=1;
        while [ $i -lt 5 ]; do
        docker service update
        --with-registry-auth
        --detach=true
        {%- if service.replicas is defined %} --replicas {{ service.replicas }}{%- endif %}
        {%- if service.user is defined %} --user {{ service.user }}{%- endif %}
        {%- if service.workdir is defined %} --workdir {{ service.workdir }}{%- endif %}
        {%- if service.endpoint is defined %} --endpoint-mode {{ service.endpoint }}{%- endif %}
        {%- for param, value in service.get('restart', {}).items() %} --restart-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('update', {}).items() %} --update-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('log', {}).items() %} --log-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('limit', {}).items() %} --limit-{{ param }} {{ value }}{%- endfor %}
        {%- for param, value in service.get('reserve', {}).items() %} --reserve-{{ param }} {{ value }}{%- endfor %}
        --image {{ service.image }}
        {{ name }};
        ret=$?;
        [ $ret -eq 0 ] && exit 0;
        echo "Service update failed, retrying in 3 seconds.." >&2;
        sleep 3;
        i=$[ $i + 1 ];
        done
    - shell: /bin/bash
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
