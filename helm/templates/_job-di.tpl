{{- define "di.name" -}}
{{- default (index . 0).Chart.Name (index . 1).image_name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "di.image" -}}
{{ (index . 1).repository }}:{{ (index . 1).tag | default (index . 0).Chart.AppVersion }}
{{- end }}

{{- define "di.pullPolicy" -}}
{{ (index . 1).pullPolicy | default "Always"}}
{{- end }}

{{- define "di.moduleName" -}}
{{- default (index . 0).Chart.Name (index . 1).module_name | trunc 63 | trimSuffix "-datainstall" | trimPrefix "datainstall-" }}
{{- end }}

{{- define "di.fullName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "di.name" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "di.name" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}

{{- define "di.fullModuleName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "di.moduleName" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "di.moduleName" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}