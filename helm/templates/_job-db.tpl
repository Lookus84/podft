{{- define "dbm.name" -}}
{{- default (index . 0).Chart.Name (index . 1).image_name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "dbm.image" -}}
{{ (index . 1).repository }}:{{ (index . 1).tag | default (index . 0).Chart.AppVersion }}
{{- end }}

{{- define "dbm.pullPolicy" -}}
{{ (index . 1).pullPolicy | default "Always"}}
{{- end }}

{{- define "dbm.moduleName" -}}
{{- default (index . 0).Chart.Name (index . 1).module_name | trunc 63 | trimSuffix "-database" | trimPrefix "database-" }}
{{- end }}

{{- define "dbm.fullName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "dbm.name" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "dbm.name" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}

{{- define "dbm.fullModuleName" -}}
{{- if (index . 0).Values.namePrefix.enabled -}}
{{- printf "%s-%s" (index . 0).Values.namePrefix.prefix (include "dbm.moduleName" (list (index . 0) (index . 1))) -}}
{{- else }}
{{- include "dbm.moduleName" (list (index . 0) (index . 1)) }}
{{- end }}
{{- end }}
