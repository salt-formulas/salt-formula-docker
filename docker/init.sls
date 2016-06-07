{%- if pillar.docker is defined %}
include:
{%- if pillar.docker.host is defined %}
- docker.host
{%- endif %}
{%- if pillar.docker.control is defined %}
- docker.control
{%- endif %}
{%- if pillar.docker.compose is defined %}
- docker.compose
{%- endif %}
{%- if pillar.docker.registry is defined %}
- docker.registry
{%- endif %}
{%- endif %}
