#!jinja|yaml|gpg
{% from "pod-ft/podft/map.jinja" import common with context %}
{% from "pod-ft/podft/map.jinja" import apps with context %}
{% from "pod-ft/podft/map.jinja" import merged_config with context %}


{%- set deploy_base = "/tmp/deploy_apps" %}
{%- set helm_cmd = merged_config.helm_dir ~ "/helm" %}
{%- set kubectl_cmd = merged_config.kubectl_dir ~ "/kubectl" %}
{%- set ns = merged_config.namespace %}

{% for app_name, app in apps.items() %}
{%- set chart_dir = deploy_base ~ "/" ~ app_name ~ "-chart" %}

{%- set settings = {} %}
{%- do settings.update(common) %}
{%- do settings.update(app) %}

# Создаем директорию чарта
{{ chart_dir }}:
  file.directory:
    - mode: "0755"
    - makedirs: True

# Генерируем Chart.yaml
{{ chart_dir }}/Chart.yaml:
  file.managed:
    - source: salt://pod-ft/podft/helm/Chart.yaml.j2
    - template: jinja
    - context:
        app_name: {{ app_name }}
        app: {{ app }}
        common: {{ common }}
        merged_config: {{ merged_config }}
        settings: {{ settings }}        
    - require:
      - file: {{ chart_dir }}

# Генерируем values.yaml
{{ chart_dir }}/values.yaml:
  file.managed:
    - source: salt://pod-ft/podft/helm/values.yaml.j2
    - template: jinja
    - context:
        app: {{ app }}
        app_name: {{ app_name }}
        common: {{ common }}
        merged_config: {{ merged_config }}
        settings: {{ settings }}
    - require:
      - file: {{ chart_dir }}

# Копируем шаблоны Helm чарта
copy_helm_templates_{{ app_name }}:
  file.recurse:
    - name: {{ chart_dir }}/templates
    - source: salt://pod-ft/podft/helm/templates
    - file_mode: "0644"
    - dir_mode: "0755"
    - makedirs: True
    - context:
        app: {{ app }}
        common: {{ common }}
    - require:
      - file: {{ chart_dir }}

# Деплой Helm чарта
deploy_helm_chart_{{ app_name }}:
  cmd.run:
    - name: >-
        {{ helm_cmd }} --namespace {{ ns }} upgrade --install {{ app_name }} {{ chart_dir }}
        --values {{ chart_dir }}/values.yaml
        {%- if app_name == 'qrcdrcompliancecontrolrule' %}
        ; sleep 180; {{ kubectl_cmd }} --namespace {{ ns }} rollout restart deployment mdpgateway
        {%- endif %}
    - timeout: {{ app.get('timeout', 100) }}
    - require:
      - file: {{ chart_dir }}/Chart.yaml
      - file: {{ chart_dir }}/values.yaml
      - file: copy_helm_templates_{{ app_name }}
{% endfor %}

restart-mdpgateway:
  cmd.run:
    - name: >-
        {{ kubectl_cmd }} --namespace {{ ns }} rollout restart deployment mdpgateway
    - timeout: 60
    - unless: >-
        ! {{ kubectl_cmd }} get deployment mdpgateway -n {{ ns }}