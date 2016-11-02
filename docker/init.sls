{%- if pillar.docker is defined %}
include:
{%- if pillar.docker.host is defined %}
- docker.host
{%- endif %}
{%- if pillar.docker.swarm is defined %}
- docker.swarm
{%- endif %}
{%- if pillar.docker.client is defined %}
- docker.client
{%- endif %}
{%- if pillar.docker.registry is defined %}
- docker.registry
{%- endif %}
{%- endif %}
