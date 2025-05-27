#!jinja|yaml|gpg
{% from "pod-ft/podft/map.jinja" import common with context %}
{% from "pod-ft/podft/map.jinja" import merged_config with context %}

{%- set cert_dir = merged_config.cert_dir %}
{%- set namespace = merged_config.namespace %}
{%- set kubectl = merged_config.kubectl_dir ~ '/kubectl' %}

{# Обработка каждого секрета: копирование + создание секрета в Kubernetes #}
{%- for secret in common.secrets %}
{{ secret.name }}_cert_and_secret:
  file.managed:
    - name: {{ cert_dir }}/{{ secret.file }}
    - source: salt://pod-ft/podft/certs/{{ secret.file }}
    - mode: "0644"
    - makedirs: True

  cmd.run:
    - name: |
        {{ kubectl }} -n {{ namespace }} create secret generic {{ secret.name }} \
        --from-file={{ cert_dir }}/{{ secret.file }}
    - unless: |
        {{ kubectl }} -n {{ namespace }} get secret {{ secret.name }}
    - require:
        - file: {{ secret.name }}_cert_and_secret
{%- endfor %}