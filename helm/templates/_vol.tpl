{{- define "vol.def" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if (eq $kind "deployment") }}
{{-   include "vol.def.commonShare" $params}}
{{-   include "vol.def.rulelist" $params}}
{{-   include "vol.def.upstream" $params}}
{{-   include "vol.def.wavelist" $params}}
{{-   include "vol.def.CmS" $params}}
{{-   include "vol.def.emptyDir" "share-folder-volume" }} 
{{-   include "vol.def.emptyDir" "config-folder-volume" }} 
{{-   if $params.Values.initContainers }}
{{-     range $params.Values.initContainers }}
{{-         include "vol.def.emptyDir" (print "diasoft-" (splitList  "/" .image.repository |last )) }} 
{{-     end }} 
{{-   end }} 
{{- else if (eq $kind "job") }}
{{-   include "vol.def.commonShare" $params}}
{{-   include "vol.def.emptyDir" "share-folder-volume" }} 
{{-   if $params.Values.initContainers }}
{{-     range $params.Values.initContainers }}
{{-       if contains "devopsutils" .image.repository }}
{{-         include "vol.def.emptyDir" (print "diasoft-" (splitList  "/" .image.repository |last )) }} 
{{-       end }} 
{{-     end }} 
{{-   end }} 
{{- end }}
{{- end }}

{{- define "vol.def.commonShare" }}
{{- if and (.Values.commonShare).enabled .Values.commonShare }}    
- name: {{ include "app.fullName" . }}
  persistentVolumeClaim:
    claimName: {{ .Values.persistentVolumeClaim | quote}}
{{- end }}
{{- end }}

{{- define "vol.def.devopsutils" }}
{{- if .Values.initContainers }}  
  {{- range .Values.initContainers }}
    {{- if contains "devopsutils" .image.repository }}
- name: diasoft-devopsutils
  emptyDir: {}
    {{- end }}  
  {{- end }}  
{{- end }}   
{{- end }}

{{- define "vol.def.rulelist" }}
{{- if and (.Values.ruleList).enabled .Values.ruleList }}    
- name: rulelist-volume
  configMap:
    defaultMode: 420
    name: {{ include "app.name" . }}-rulelist
{{- end }}
{{- end }}

{{- define "vol.def.upstream" }}
{{- if and (.Values.upstream).enabled .Values.upstream }}    
- name: {{ include "app.name" . }}-config-upstream
  configMap:
    defaultMode: 420
    name: {{ include "app.name" . }}-config
{{- end }}
{{- end }}

{{- define "vol.def.wavelist" }}
{{- if and (.Values.waveList).enabled .Values.waveList }}    
- name: wave-list
  configMap:
    defaultMode: 0777
    name: wave-list
{{- end }}
{{- end }}

{{- define "vol.def.emptyDir" }}  
- name: {{.}}
  emptyDir: {}
{{- end }}

{{- define "vol.def.CmS" }}
{{- range .Values.customCmSVolume }}    
- name: {{ .name }}
{{-   if .secret }} 
  secret:
{{- toYaml .secret | nindent 4 }}
{{-   end }}
{{-   if or .configMap .config }} 
  configMap:
{{- toYaml  (default .config .configMap) | nindent 4 }}
{{-   end }}
{{- end }}
{{- end }}




{{- define "vol-ui.def" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if (eq $kind "deployment") }}
{{-   include "vol-ui.def.commonShare" $params}}
{{-   include "vol-ui.def.devopsutils" $params}}
{{-   include "vol-ui.def.rulelist" $params}}
{{-   include "vol-ui.def.upstream" $params}}
{{-   include "vol-ui.def.wavelist" $params}}
{{-   include "vol-ui.def.sharefolder" $params}}
{{-   include "vol-ui.def.shareconfigfolder" $params}}
{{- else if (eq $kind "job") }}
{{-   include "vol-ui.def.devopsutils" $params}}
{{-   include "vol-ui.def.commonShare" $params}}
{{-   include "vol-ui.def.sharefolder" $params}}
{{- end }}
{{- end }}

{{- define "vol-ui.def.commonShare" }}
{{- if and (.Values.commonShare).enabled .Values.commonShare }}    
- name: {{ include "ui.name" . }}
  persistentVolumeClaim:
    claimName: {{ .Values.persistentVolumeClaim | quote}}
{{- end }}
{{- end }}

{{- define "vol-ui.def.devopsutils" }}
{{- if .Values.initContainers }}  
  {{- range .Values.initContainers }}
    {{- if contains "devopsutils" .image.repository }}
- name: diasoft-devopsutils
  emptyDir: {}
    {{- end }}  
  {{- end }}  
{{- end }}   
{{- end }}

{{- define "vol-ui.def.rulelist" }}
{{- if and (.Values.ruleList).enabled .Values.ruleList }}    
- name: rulelist-volume
  configMap:
    defaultMode: 420
    name: {{ include "ui.name" . }}-rulelist
{{- end }}
{{- end }}

{{- define "vol-ui.def.upstream" }}
{{- if and (.Values.upstream).enabled .Values.upstream }}    
- name: {{ include "ui.name" . }}-config-upstream
  configMap:
    defaultMode: 420
    name: {{ include "ui.name" . }}-config
{{- end }}
{{- end }}

{{- define "vol-ui.def.wavelist" }}
{{- if and (.Values.waveList).enabled .Values.waveList }}    
- name: wave-list
  configMap:
    defaultMode: 0777
    name: wave-list
{{- end }}
{{- end }}

{{- define "vol-ui.def.sharefolder" }}  
- name: share-folder-volume
  emptyDir: {}
{{- end }}

{{- define "vol-ui.def.shareconfigfolder" }}  
- name: config-folder-volume
  emptyDir: {}
{{- end }}