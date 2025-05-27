{{- define "annotations.add" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- $port := (index . 2) }}
{{- if (eq $kind "pod") }}
{{-   if or $params.Values.podAnnotations $params.Values.vault.enabled $params.Values.prometheus.enabled }}
annotations:
{{-     include "annotations.add.values" $params }}
{{-     include "annotations.add.prometheus" (list $params $port) }}
{{-     include "annotations.add.vault" (list $params "pod") }}
{{-   end }}
{{- else if (eq $kind "job") }}
{{-   if or $params.Values.podAnnotations $params.Values.vault.enabled $params.Values.istio.enabled }}
annotations:
{{-     include "annotations.add.values" $params }}
{{-     include "annotations.add.vault" (list $params "job") }}
{{-     include "annotations.add.istio" $params }}
{{-   end }}
{{- end }}
{{- end }}

{{- define "annotations.add.values" }}
{{- with .Values.podAnnotations }}
{{- toYaml . | nindent 2 }}
{{- end }}
{{- end }}

{{- define "annotations.add.prometheus" }}
{{- $params := (index . 0)  }}
{{- if $params.Values.prometheus.enabled }}
  prometheus.io/path: /{{ include "app.name" $params }}/actuator/prometheus
  prometheus.io/port: '{{(index . 1)}}'
  prometheus.io/scrape: 'true'
{{- end }}
{{- end }}

{{- define "annotations.add.vault" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if $params.Values.vault.enabled }}
  vault.hashicorp.com/agent-inject: 'true'
{{- if $params.Values.vault.tlsSkipVerify }}
  vault.hashicorp.com/tls-skip-verify: 'true'
{{- end }}
{{-   range $index, $par := $params.Values.vault.vault_secret }}
  vault.hashicorp.com/agent-inject-secret-vault{{$index}}: {{ $par | quote }}
  vault.hashicorp.com/agent-inject-template-vault{{$index}}: {{ print ">" }}
    {{ print "{{- with secret \"" $par "\" -}}" }}
    {{ print "  {{ range $k, $v := .Data.data }}" }}
    {{ print "    export {{ $k }}='{{ $v }}'" }}
    {{ print "  {{ end }}" }}
    {{ print "{{- end -}}" }}
{{-   end }}
  vault.hashicorp.com/role: {{$params.Values.vault.vault_role | default $params.Release.Namespace }}
  vault.hashicorp.com/agent-init-first: 'true'
{{-   if (eq $kind "job") }}
  vault.hashicorp.com/agent-pre-populate-only: 'true'
{{-   end }}
{{- end }}
{{- end }}

{{- define "annotations.add.istio" }}
{{- if .Values.istio.enabled }}
  sidecar.istio.io/inject: "false"
{{- end }}  
{{- end }}