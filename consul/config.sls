{% from "consul/map.jinja" import consul with context %}

consul-config:
  file.managed:
    - source: salt://consul/files/config.json
    - template: jinja
    - name: /etc/consul.d/config.json
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: {{ consul.user }}
    - group: {{ consul.user }}
    - require:
      - user: {{ consul.user }}

{% for script in consul.scripts %}
consul-script-install-{{ loop.index }}:
  file.managed:
    - source: {{ script.source }}
    - name: {{ script.name }}
    - template: jinja
    - user: {{ consul.user }}
    - group: {{ consul.user }}
    - mode: 0755
{% endfor %}

consul-script-config:
  file.managed:
    - source: salt://consul/files/services.json
    - name: /etc/consul.d/services.json
    - template: jinja
    {% if consul.service != False %}
    - watch_in:
       - service: consul
    {% endif %}
    - user: {{ consul.user }}
    - group: {{ consul.user }}
    - require:
      - user: {{ consul.user }}
