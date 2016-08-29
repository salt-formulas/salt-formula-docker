{%- if pillar.docker is defined %}
include:
{%- if pillar.docker.host is defined %}
- docker.host
{%- endif %}
{%- if pillar.docker.container is defined %}
- docker.container
{%- endif %}
{%- if pillar.docker.registry is defined %}
- docker.registry
{%- endif %}
{%- endif %}
