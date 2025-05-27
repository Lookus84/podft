#!jinja|yaml|gpg

{% from "pod-ft/podft/map.jinja" import merged_config with context %}


show_merged_system_config:
  test.succeed_without_changes:
    - name: "Show merged system_config"
    - comment: |
                system_config:
                {%- for key, value in merged_config.items() %}
                    {{ key }}: "{{ value|default('') }}"
                {%- endfor %}

{# debug_system_variable:
  test.succeed_without_changes:
    - name: "Debugging helm variable"
    - comment: |
                {{ helm | tojson }}
                {# {{ system | tojson }} #}
                {# {{ secrets }} #}
                {# {{ configmap }} #}
                {# {{ settings_stand | tojson }} #}
 #}

{# 
{%- set env = salt['grains.get']('podft:environment', 'test') %}
{% set os_common = system.get('common', {}) %}

{% for app_name, app in apps.items() %}

debug_system_variable: 
  test.succeed_without_changes:
    - name: "System variable content: {{ map }} " 



{% set resources = app.get('resources', common.get('resources', {})) %}
{% set isDatabase = app.get('isDatabase', common.get('isDatabase', 'false')) %}
{% set isDatainstall = app.get('isDatainstall', common.get('isDatainstall', 'false')) %}

debug_system_variable_{{ app_name }}:
  test.succeed_without_changes: 
      - name: |
 
              {% if resources != {} %}
              resources:
              {%- for resource, values in resources.items() %}
                {% if (resource == 'db' and isDatabase|lower == 'false') or (resource == 'di' and isDatainstall|lower == 'false') %}
                  {%- continue %}
                {% endif -%}
                {{ resource }}:
                  limits:
                    cpu: {{ values.limits.cpu }}
                    memory: {{ values.limits.memory }}
                    ephemeral-storage: {{ values.limits.get('ephemeral-storage', '1024Mi') }}
                  requests:
                    cpu: {{ values.requests.cpu }}
                    memory: {{ values.requests.memory }}
                    ephemeral-storage: {{ values.requests.get('ephemeral-storage', '256Mi') }}

              {%- endfor -%}
              {%- else %}
              resources: {}
              {% endif -%}
 
{% endfor %}  #}
