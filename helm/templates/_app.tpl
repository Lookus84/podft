{{- define "app.name" -}}
{{- if eq $.Values.imageType "ui" -}}
{{-     default .Chart.Name .Values.ui.image.image_name | trunc 63 | trimSuffix "-" }}
{{-   else if eq $.Values.imageType "app" -}}
{{-     default .Chart.Name .Values.app.image.image_name | trunc 63 | trimSuffix "-" }}
{{-   else  -}}
{{-     default .Chart.Name $.Values.app.image.image_name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{- define "app.image" -}}
{{- if eq $.Values.imageType "ui" -}}
{{-     .Values.ui.image.repository }}:{{ .Values.ui.image.tag | default .Chart.AppVersion }}
{{-   else if eq $.Values.imageType "app" -}}
{{-     .Values.app.image.repository }}:{{ .Values.app.image.tag | default .Chart.AppVersion }}
{{-   else  -}}
{{-     .Values.app.image.repository }}:{{ .Values.app.image.tag | default .Chart.AppVersion }}
{{- end }}
{{- end }}

{{- define "app.pullPolicy" -}}
{{ .Values.app.image.pullPolicy | default "Always"}}
{{- if eq $.Values.imageType "ui" -}}
{{-     .Values.ui.image.pullPolicy | default "Always" }}
{{-   else if eq $.Values.imageType "app" -}}
{{-     .Values.app.image.pullPolicy | default "Always" }}
{{-   else  -}}
{{-     .Values.app.image.pullPolicy | default "Always" }}
{{- end }}
{{- end }}

{{/*
Common ingress
*/}}
{{- define "app.inghost" -}}
{{- $host := (index . 0)}}
{{- $domain := (index . 1)}}
{{- ternary (printf "%s.%s" $host $domain) (printf "%s" $host) (ne $domain nil) }}
{{- end }}

{{/*
Using ports
*/}}
{{- define "app.ports" -}}
{{- $def := (first (index . 0)) }}
{{- $kind := (index . 1) }}
{{- range $index, $par := (index . 0) }}
- name: {{ default (ternary (printf "%s%d" $def.name $index) "http" (gt $index 0)) $par.name | quote }}
  protocol: {{ default $def.protocol $par.protocol | quote }}
  {{- if (eq $kind "service") }}
  port: {{ $par.port }}
  targetPort: {{ default $par.port $par.targetPort }}
  {{- else if (eq $kind "deployment") }}
  containerPort: {{ $par.port }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "app.labels" -}}
helm.sh/chart: {{ include "app.chart" . }}
{{ include "app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "app.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "app.name" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Define name with prefix for entities names.
*/}}
{{- define "app.fullName" -}}
{{- if .Values.namePrefix.enabled -}}
{{- printf "%s-%s" .Values.namePrefix.prefix (include "app.name" .) -}}
{{- else }}
{{- include "app.name" . }}
{{- end }}
{{- end }}