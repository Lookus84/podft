{{- define "envFrom.add" -}}
{{- $param := (index . 0) }}
{{- $name := (index . 1)}}
{{- $kind := (index . 2) }}
{{- with $param.environmentsFrom }} 
  {{- with $param.environmentsFrom.systemCmS }} 
    {{- if and $param.environmentsFrom.systemCmS.enabled (or (eq $kind "deployment-main-cont") (eq $kind "job-main-cont")) }}
      {{-   include "envFrom.secret" (printf "%s-%s" ($param.environmentsFrom.systemCmS.name | default ("system")) "secret") }}
      {{-   include "envFrom.config" (printf "%s-%s" ($param.environmentsFrom.systemCmS.name | default ("system")) "config") }}
    {{- else if and $param.environmentsFrom.systemCmS.enabled (eq $kind "deployment-init-cont") }}     
      {{-   include "envFrom.config" (printf "%s-%s" ($param.environmentsFrom.systemCmS.name | default ("system")) "config") }}
    {{- else if and $param.environmentsFrom.systemCmS.enabled (eq $kind "job-init-cont") }}
    {{- end }}
  {{- end }}
  {{- with $param.environmentsFrom.privateCmS }} 
    {{- if and $param.environmentsFrom.privateCmS.enabled (or (eq $kind "deployment-main-cont") (eq $kind "job-main-cont")) }}
      {{-   include "envFrom.secret" (printf "%s-%s" $name "dbsecret") }}
      {{-   include "envFrom.secret" (printf "%s-%s" $name "loginsecret") }}
      {{-   include "envFrom.config" (printf "%s-%s" $name "config") }}
    {{- else if (eq $kind "deployment-init-cont") }}     
      {{-   include "envFrom.config" (printf "%s-%s" $name "config") }}
    {{- else if (eq $kind "job-init-cont") }}
    {{- end }}
  {{- end }}
{{- end }}
{{- end }}

{{- define "envFrom.secret" }}
- secretRef:
    name: {{ . }}
{{- end }}

{{- define "envFrom.config" }}
- configMapRef:
    name: {{ . }}
{{- end }}



