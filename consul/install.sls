{% from "consul/map.jinja" import consul with context %}

consul-dep-unzip:
  pkg.installed:
    - name: unzip

consul-bin-dir:
  file.directory:
    - name: /usr/local/bin
    - makedirs: True

# Create consul user
consul-user:
  group.present:
    - name: {{ consul.user }}
  user.present: 
    - name: {{ consul.user }}
    - createhome: false
    - system: true
    - groups:
      - {{ consul.user }}
    - require:
      - group: {{ consul.user }}

# Create directories
consul-config-dir:
  file.directory:
    - name: /etc/consul.d
    - user: {{ consul.user }}
    - group: {{ consul.user }}

consul-runtime-dir:
  file.directory:
    - name: /var/consul
    - user: {{ consul.user }}
    - group: {{ consul.user }}

consul-data-dir:
  file.directory:
    - name: /usr/local/share/consul
    - user: {{ consul.user }}
    - group: {{ consul.user }}
    - makedirs:

# Install agent
consul-download:
  file.managed:
    - name: /tmp/consul_{{ consul.version }}_linux_amd64.zip
    - source: https://releases.hashicorp.com/consul/{{ consul.version }}/consul_{{ consul.version }}_linux_amd64.zip
    - source_hash: sha256={{ consul.hash }}
    - unless: test -f /usr/local/bin/consul-{{ consul.version }}

consul-extract:
  cmd.wait:
    - name: unzip /tmp/consul_{{ consul.version }}_linux_amd64.zip -d /tmp
    - watch:
      - file: consul-download

consul-install:
  file.rename:
    - name: /usr/local/bin/consul-{{ consul.version }}
    - source: /tmp/consul
    - require:
      - file: /usr/local/bin
    - watch:
      - cmd: consul-extract

consul-clean:
  file.absent:
    - name: /tmp/consul_{{ consul.version }}_linux_amd64.zip
    - watch:
      - file: consul-install

consul-link:
  file.symlink:
    - target: consul-{{ consul.version }}
    - name: /usr/local/bin/consul
    - watch:
      - file: consul-install
