{{- define "bt.name" -}}
{{- default (index . 0).Chart.Name (index . 1).image_name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "bt.image" -}}
{{ (index . 1).repository }}:{{ (index . 1).tag | default (index . 0).Chart.AppVersion }}
{{- end }}

{{- define "bt.pullPolicy" -}}
{{ (index . 1).pullPolicy | default "Always"}}
{{- end }}

{{- define "bt.moduleName" -}}
{{- default (index . 0).Chart.Name (index . 1).module_name | trunc 63 | trimSuffix "-brokertool" | trimPrefix "brokertool-" }}
{{- end }}

{{- define "bt.fullName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "bt.name" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "bt.name" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}

{{- define "bt.fullModuleName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "bt.moduleName" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "bt.moduleName" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}
