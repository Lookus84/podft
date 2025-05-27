#!jinja|yaml|gpg
{%- set env = salt['grains.get']('podft:environment', 'test') %}
{%- set system =  salt['pillar.get']('podft:' + env + ':system', {}) %}
{% set common = system.get('common', {}) %}


"Delete Helm releases in namespace {{ common.namespace }}":
  cmd.run:
    - name: >-
        {{ common.helm_dir }}/helm list --namespace {{ common.namespace }} -q | 
        xargs -r -n 1 {{ common.helm_dir }}/helm uninstall --namespace {{ common.namespace }}
    - timeout: 100
    - context:
        common: {{ common }}

"Delete all Jobs in namespace {{ common.namespace }}":
  cmd.run:
    - name: >-
        {{ common.kubectl_dir }}/kubectl delete jobs --namespace {{ common.namespace }} --all
    - context:
        common: {{ common }}
{#
"Delete all ConfigMaps in namespace {{ common.namespace }}":
  cmd.run:
    - name: >-
        kubectl --kubeconfig=/tmp/kubernetes/kubeconfig delete configmap --namespace {{ common.namespace }} --all
    - require:
      - file: check_kubeconfig

"Delete all Secrets in namespace {{ common.namespace }}":
  cmd.run:
    - name: >-
        kubectl --kubeconfig=/tmp/kubernetes/kubeconfig delete secret --namespace {{ common.namespace }} --all
    - require:
      - file: check_kubeconfig
#}