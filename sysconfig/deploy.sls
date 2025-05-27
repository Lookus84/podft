#!jinja|yaml|gpg
{% from "pod-ft/podft/map.jinja" import merged_config with context %}
{% from "pod-ft/podft/map.jinja" import secrets with context %}

/tmp/deploy_apps/system-chart:
  file.directory:
    - mode: "0755"
    - makedirs: True

/tmp/deploy_apps/system-chart/Chart.yaml:
  file.managed:
    - source: salt://pod-ft/podft/sysconfig/Chart.yaml
    - require:
      - file: "/tmp/deploy_apps/system-chart"


"/tmp/deploy_apps/system-chart/values.yaml":
  file.managed:
    - source: salt://pod-ft/podft/sysconfig/values.yaml.j2
    - template: jinja
    - context:
        secrets: {{ secrets }}
        merged_config: {{ merged_config }}     

copy_helm_templates:
  file.recurse:
    - name: "/tmp/deploy_apps/system-chart/templates"
    - source: salt://pod-ft/podft/sysconfig/templates
    - file_mode: "0644"
    - dir_mode: "0755"
    - makedirs: True

"Deploy system":
  cmd.run:
    - name: >-
        {{ merged_config.helm_dir }}/helm --namespace {{ merged_config.namespace }} 
        upgrade --install system /tmp/deploy_apps/system-chart 
        --values /tmp/deploy_apps/system-chart/values.yaml
    - context:
        merged_config: {{ merged_config }}
    - require:
      - file: "/tmp/deploy_apps/system-chart/values.yaml"
      - file: "/tmp/deploy_apps/system-chart/Chart.yaml"