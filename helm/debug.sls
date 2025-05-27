#!jinja|yaml|gpg
#!jinja|yaml|gpg
{% from tpldir~"/map.jinja" import common with context %}
{% from tpldir~"/map.jinja" import apps with context %}
{% from tpldir~"/map.jinja" import merged_config with context %}


{%- set deploy_base = "/tmp/deploy_apps" %}
{%- set helm_cmd = merged_config.helm_dir ~ "/helm" %}
{%- set ns = merged_config.namespace %}

{# {% for app_name, app in apps.items() %}
{%- set chart_dir = deploy_base ~ "/" ~ app_name ~ "-chart" %}

{%- set settings = {} %}
{%- do settings.update(common) %}
{%- do settings.update(app) %}

debug_system_variable_{{ app_name }}:
  test.succeed_without_changes: 
      - name: |

              "{{ merged_config.INGRESS_HOST_PREFIX }}{{ app_name }}"



{% endfor %}   #}
restart-mdpgateway:
  cmd.run:
    - name: >-
        {{ helm_cmd }} --namespace {{ ns }} rollout restart deployment mdpgateway
    - unless: >-
        ! kubectl get deployment mdpgateway -n {{ ns }}

      {# {{ settings.isDatabase | tojson }} #}      
                {# {%- set data =  settings.get('data', {})  %}
                {%- if not app_name.endswith('ui')%}
                data:                       
                  DB_URL: "jdbc:postgresql://{{ merged_config.DB_HOST }}:{{ merged_config.DB_PORT }}/{{ merged_config.DB_DATABASE }}?currentSchema={{ app_name }}"
                  DB_SCHEMA: {{ app_name }}
                  SERVICE_NAME: "{{ app_name }}"
                {%- for key, value in data.items() %}
                  {{ key }}: {{ value | tojson if value is string else value }}
                {%- endfor %}
                {% else %}
                data:                       
                  SERVICE_NAME: "{{ app_name }}"
                {%- for key, value in data.items() %}                          
                  {{ key }}: {{ value | tojson if value is string else value }}                          
                {%- endfor %}
                {%- endif %} #}
                    
              
              
              {# {% set common_data = settings.get('data', {}) %}


              {%- if settings.get('data', {}) %}
              data:
                {%- if not app_name.endswith('ui')%}
                DB_URL: jdbc:postgresql://dhdigital-db1:5432/salt_deploy_db?currentSchema=mdpauth
                DB_URL: jdbc:postgresql://dhdigital-db1:5432/salt_deploy_db?currentSchema=mdpauth
                {{ key }}: "{{ value }}"
                  {% endif -%}

                # DB_URL: jdbc:postgresql://dhdigital-db1:5432/salt_deploy_db?currentSchema=mdpauth
                {%- for key, value in app_data.items() %}
                {{ key }}: "{{ value }}"
                {%- endfor %}
                
                {%- for key, value in common_data.items() if key not in app_data  %}
                  {%- if not app_name.endswith('ui')%}
                {{ key }}: "{{ value }}"
                  {% endif -%}
                {%- endfor %}
                {% endif %} #}


{# {% from "podft/map.jinja" import system with context %} #}

{# show_merged_system_config:
  test.succeed_without_changes:
    - name: "Show merged system_config"
    - comment: | 
                  {{ settings | tojson }} #}