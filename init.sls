#!jinja|yaml|gpg
include:
    - {{ tpldot }}.deploy_truststore
    - {{ tpldot }}.sysconfig.deploy
    - {# {{ tpldot }}.helm.deploy #}