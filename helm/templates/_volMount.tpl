{{- define "vol.mount" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if (eq $kind "deployment-main-cont") }}
{{-   include "vol.mount.commonShare" $params}}
{{-   include "vol.mount.rulelist" $params}}
{{-   include "vol.mount.upstream" $params}}
{{-   include "vol.mount.wavelist" $params}}
{{-   include "vol.mount.sharefolder" $params}}
{{-   include "vol.mount.shareconfigfolder" $params}}
{{-   include "vol.mount.CmS" $params}}
{{-   if $params.Values.initContainers }}
{{-     range $params.Values.initContainers }}
{{-       if contains "devopsutils" .image.repository }}
{{-         include "vol.mount.devopsutils" (list $params "main" (print "diasoft-" (splitList  "/" .image.repository |last ))) }}  
{{-       else if or (contains "metadata-" .image.repository) (contains "-metadata" .image.repository) }}
{{-         include "vol.mount.metadata" (list .image.repository "main") }}
{{-       else if or (contains "additionalfiles-" .image.repository) (contains "-additionalfiles" .image.repository) }}
{{-         include "vol.mount.additionalfiles" (list .image.repository "main") }}
{{-       end }}  
{{-     end }}  
{{-   end }} 
{{- else if (eq $kind "deployment-init-cont") }}
{{-   if ge (len .) 3 }}
{{-     if contains "devopsutils" (index . 2) }}
{{-       include "vol.mount.commonShare" $params}}
{{-       include "vol.mount.devopsutils" (list $params "init" (print "diasoft-" (index . 2))) }}
{{-       include "vol.mount.wavelist" $params}}
{{-     else if or (contains "metadata-" (index . 2)) (contains "-metadata" (index . 2)) }}
{{-       include "vol.mount.metadata" (list (index . 2) "init") }}
{{-     else if or (contains "additionalfiles-" (index . 2)) (contains "-additionalfiles" (index . 2)) }}
{{-       include "vol.mount.additionalfiles" (list (index . 2) "init") }}
{{-     end}}
{{-   end}}
{{- else if (eq $kind "job-main-cont") }}
{{-   include "vol.mount.commonShare" $params}}
{{-   include "vol.mount.sharefolder" $params}}
{{-   if $params.Values.initContainers }}
{{-     range $params.Values.initContainers }}
{{-       if contains "devopsutils" .image.repository }}
{{-         include "vol.mount.devopsutils" (list $params "main" (print "diasoft-" (splitList  "/" .image.repository |last ))) }} 
{{-       end }}  
{{-     end }} 
{{-   end }} 
{{- else if (eq $kind "job-init-cont") }}
{{-   if $params.Values.initContainers }}
{{-     range $params.Values.initContainers }}
{{-       if contains "devopsutils" .image.repository }}
{{-         include "vol.mount.devopsutils" (list $params "init" (print "diasoft-" (splitList  "/" .image.repository |last ))) }} 
{{-       end }}  
{{-     end }} 
{{-   end }} 
{{- end }}
{{- end }}

{{- define "vol.mount.commonShare" }}
{{- if and (.Values.commonShare).enabled .Values.commonShare }}    
- name: {{ include "app.fullName" . }}
  mountPath: {{ .Values.commonShare.mountPath }}
{{- end -}}
{{- end -}}

{{- define "vol.mount.devopsutils" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}   
{{- $vol_name := (index . 2) }} 
- name: {{$vol_name}}
  mountPath: {{ ternary "/home/devopsutils" "/share/scripts" ( eq $kind "init")  }}
{{- end -}}

{{- define "vol.mount.rulelist" }}
{{- if and (.Values.ruleList).enabled .Values.ruleList }}    
- name: rulelist-volume
  mountPath: {{ default "/share/config/rulelist.yaml" .Values.ruleList.mountPath }}
  subPath: {{ default "rulelist.yaml" .Values.ruleList.subPath }}
{{- end }}
{{- end }}

{{- define "vol.mount.upstream" }}
{{- if and (.Values.upstream).enabled .Values.upstream }}    
- name: {{ include "app.name" . }}-config-upstream
  mountPath: {{ default "/etc/nginx/conf.d/upstream.conf" .Values.upstream.mountPath }}
  subPath: {{ default "nginx-upstream.conf" .Values.upstream.subPath }}
{{- end }}
{{- end }}

{{- define "vol.mount.wavelist" }}
{{- if and (.Values.waveList).enabled .Values.waveList }}    
- name: wave-list
  mountPath: {{ default "/opt/diasoft/flextera/DevOpsUtils/wave-list.properties" .Values.waveList.mountPath }}
  subPath: {{ default "wave-list.properties" .Values.waveList.subPath }}
{{- end }}
{{- end }}

{{- define "vol.mount.sharefolder" }}  
- name: share-folder-volume
  mountPath: /share
{{- end }}

{{- define "vol.mount.shareconfigfolder" }}  
- name: config-folder-volume
  mountPath: /share/config
{{- end }}

{{- define "vol.mount.CmS" }}  
{{- range $index, $cmsVmConfig := .Values.customCmSVolume }}    
- name: {{ default (ternary (printf "%s%d" "custom-volume" $index) "custom-volume" (gt $index 0)) $cmsVmConfig.name }}
{{-   range tuple "secret" "config" "configMap" "name" }}
{{-     $_ := unset $cmsVmConfig .}}
{{-   end }}
{{- $cmsVmConfig | toYaml | nindent 2 }}
{{- end }}
{{- end }}

{{- define "vol.mount.metadata" }}  
{{- $shortImageName := (splitList  "/" (index . 0)) |last }}
{{- $folder := print "/share/metadata/" ($shortImageName | replace "metadata-" "" | replace "-metadata" "") }}
{{- $kind := (index . 1) }}
- name: diasoft-{{$shortImageName}}
  mountPath: {{ ternary "/home/metadata" $folder ( eq $kind "init")  }}
{{- end }}

{{- define "vol.mount.additionalfiles" }} 
{{- $shortImageName := (splitList  "/" (index . 0)) |last }}
{{- $folder := print "/share/additionalfiles/" ($shortImageName | replace "additionalfiles-" "" | replace "-additionalfiles" "") }}
{{- $kind := (index . 1) }} 
- name: diasoft-{{$shortImageName}}
  mountPath: {{ ternary "/home/additionalfiles" $folder ( eq $kind "init")  }}
{{- end }}





{{- define "vol-ui.mount" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if (eq $kind "deployment-main-cont") }}
{{-   include "vol-ui.mount.commonShare" $params}}
{{-   include "vol-ui.mount.devopsutils" (list $params "main")}}
{{-   include "vol-ui.mount.rulelist" $params}}
{{-   include "vol-ui.mount.upstream" $params}}
{{-   include "vol-ui.mount.wavelist" $params}}
{{-   include "vol-ui.mount.sharefolder" $params}}
{{-   include "vol-ui.mount.shareconfigfolder" $params}}
{{- else if (eq $kind "deployment-init-cont") }}
{{-   include "vol-ui.mount.commonShare" $params}}
{{-   include "vol-ui.mount.devopsutils" (list $params "init") }}
{{-   include "vol-ui.mount.wavelist" $params}}
{{- else if (eq $kind "job-main-cont") }}
{{-   include "vol-ui.mount.devopsutils" (list $params "main")}}
{{-   include "vol-ui.mount.commonShare" $params}}
{{-   include "vol-ui.mount.sharefolder" $params}}
{{- else if (eq $kind "job-init-cont") }}
{{-   include "vol-ui.mount.devopsutils" (list $params "init") }}
{{- end }}
{{- end }}

{{- define "vol-ui.mount.commonShare" }}
{{- if and (.Values.commonShare).enabled .Values.commonShare }}    
- name: {{ include "ui.name" . }}
  mountPath: {{ .Values.commonShare.mountPath }}
{{- end -}}
{{- end -}}

{{- define "vol-ui.mount.devopsutils" }}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}
{{- if $params.Values.initContainers }}  
  {{- range $params.Values.initContainers }}
    {{- if contains "devopsutils" .image.repository }}
- name: diasoft-devopsutils
  mountPath: {{ ternary "/home/devopsutils" "/share/scripts" ( eq $kind "init")  }}
    {{- end }}  
  {{- end }}  
{{- end }}  
{{- end }}

{{- define "vol-ui.mount.rulelist" }}
{{- if and (.Values.ruleList).enabled .Values.ruleList }}    
- name: rulelist-volume
  mountPath: {{ default "/share/config/rulelist.yaml" .Values.ruleList.mountPath }}
  subPath: {{ default "rulelist.yaml" .Values.ruleList.subPath }}
{{- end }}
{{- end }}

{{- define "vol-ui.mount.upstream" }}
{{- if and (.Values.upstream).enabled .Values.upstream }}    
- name: {{ include "app.name" . }}-config-upstream
  mountPath: {{ default "/etc/nginx/conf.d/upstream.conf" .Values.upstream.mountPath }}
  subPath: {{ default "nginx-upstream.conf" .Values.upstream.subPath }}
{{- end }}
{{- end }}

{{- define "vol-ui.mount.wavelist" }}
{{- if and (.Values.waveList).enabled .Values.waveList }}    
- name: wave-list
  mountPath: {{ default "/opt/diasoft/flextera/DevOpsUtils/wave-list.properties" .Values.waveList.mountPath }}
  subPath: {{ default "wave-list.properties" .Values.waveList.subPath }}
{{- end }}
{{- end }}

{{- define "vol-ui.mount.sharefolder" }}  
- name: share-folder-volume
  mountPath: /share
{{- end }}

{{- define "vol-ui.mount.shareconfigfolder" }}  
- name: config-folder-volume
  mountPath: /share/config
{{- end }}
