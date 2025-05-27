{{- define "env.add" -}}
{{- $param := (index . 0) }}
{{- $kind := (index . 1) }}
{{- with $param.environments }} 
    {{- if or (eq $kind "deployment-main-cont") (eq $kind "deployment-init-cont") }}
      {{- include "env.simple" $param}}
      {{- include "env.podFields" $param}}
      {{- include "env.resourceFieldRef" $param}}
    {{- else if (eq $kind "job-main-cont") }}
      {{- include "env.simple" $param}}
{{-     end }}
{{- end }}
{{- end }}


{{- define "env.simple" }}
{{- range $key, $val := .environments.simple }}
- name: {{ $key }}
  value: {{ $val }}
{{- end }}
{{- end }}

{{- define "env.podFields" }}
{{- range $index, $par := .environments.podFields }}
- name: {{ $par.name }}
  valueFrom:
    fieldRef:
      fieldPath: {{ $par.fieldPath }}
{{- end }}
{{- end }}

{{- define "env.resourceFieldRef" }}
{{- range $index, $par := .environments.resourceFieldRef }}
- name: {{ $par.name }}
  valueFrom:
    resourceFieldRef:
      containerName: {{ include "app.name" $ }}
      resource: {{ $par.resource }}
{{- end }}
{{- end }}




