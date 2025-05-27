{{- define "init.container.body" -}}
{{- $param := (index . 0) }}
{{- $initContParam := (index . 1) }}
{{- $kind := (index . 2) }}
{{- $shortImageName := (splitList  "/" $initContParam.image.repository)|last }}
- name: init-{{$shortImageName}}
  image: "{{ $initContParam.image.repository }}:{{ $initContParam.image.tag | default $param.Chart.AppVersion }}"
  command:
    - /bin/sh
  args:    
    {{- include "init.container.args" (list $param $initContParam $kind)  }}         
{{- with $initContParam.environmentsFrom }}
  envFrom:
    {{- include "envFrom.add" (list $initContParam (include "app.fullName" $param ) $kind) | indent 4 }}
{{- end }}
{{- with $initContParam.environments }}
  env:
    {{- include "env.add" (list $initContParam $kind) | indent 4 }} 
{{- end }}
{{- with $initContParam.resources }}
  resources: 
    {{- toYaml . | nindent 4 }}
{{- end }}
  volumeMounts:
    {{- include "vol.mount" (list $param $kind $shortImageName) | indent 4}}
  terminationMessagePath: /dev/termination-log
  terminationMessagePolicy: File
  imagePullPolicy: {{ $initContParam.image.pullPolicy | default ("Always") }}
  securityContext:
    {{- toYaml $param.Values.securityContext | nindent 12 }}
{{- end }}

{{/*not used*/}}
{{- define "init.container.name" -}}
{{- (splitList  "/" .)|last }}
{{- end }}

{{- define "init.container.args" -}}
{{- $param := (index . 0) }}
{{- $initContParam := (index . 1) }}
{{- $kind := (index . 2) }}
{{- if contains "devopsutils" $initContParam.image.repository }}
{{-   if (eq $kind "deployment-init-cont") }}
    - '-c'
    - if [ -f "/opt/diasoft/flextera/DevOpsUtils/scripts/mismatchs-check.sh" ]; then bash /opt/diasoft/flextera/DevOpsUtils/scripts/mismatchs-check.sh; fi;
      {{- if and ($param.Values.commonShare).enabled $param.Values.commonShare }} 
      find {{$param.Values.commonShare.mountPath}} ! -perm 777 -exec chmod 777 {} +;
      {{- end }}
      {{- if $param.Values.vault.enabled }}
      {{ $param.Values.vault.cmdToInject }}
      {{- end }}
      mkdir -p /home/devopsutils && cp -R /opt/diasoft/flextera/DevOpsUtils/scripts/. /home/devopsutils; cp -R /opt/diasoft/flextera/DevOpsUtils/lib/. /home/devopsutils/lib;  cp -R /opt/diasoft/flextera/DevOpsUtils/ru/. /home/devopsutils/ru;  
      if [ -f "/opt/diasoft/flextera/DevOpsUtils/scripts/waitForWave.sh" ] && [ "$CHECK_ORDER" != "false" ]; then bash /opt/diasoft/flextera/DevOpsUtils/scripts/waitForWave.sh "{{ include "app.name" $param }}" "$CHECK_ORDER_TIMEOUT"; fi 
{{-   else if (eq $kind "job-init-cont") }}
    - '-c'
    - mkdir -p /home/devopsutils && cp -R
      /opt/diasoft/flextera/DevOpsUtils/scripts/. /home/devopsutils; cp
      -R /opt/diasoft/flextera/DevOpsUtils/lib/. /home/devopsutils/lib; 
      cp -R /opt/diasoft/flextera/DevOpsUtils/ru/. /home/devopsutils/ru;
      
{{-   end }}
{{- else if or (contains "metadata-" $initContParam.image.repository) (contains "-metadata" $initContParam.image.repository) }}
    - '-c'
    - mkdir -p /home/metadata; metadata_path=/opt/diasoft/metadata/; 
      if [ ! -d ${metadata_path} ] && [ -d "/opt/diasoft/flextera/metadata/" ]; then metadata_path=/opt/diasoft/flextera/metadata/; elif [ ! -d ${metadata_path} ] && [ ! -d "/opt/diasoft/flextera/metadata/" ]; then metadata_path=/app/files/; fi;
      if [ -d ${metadata_path} ];then cp -r ${metadata_path}* /home/metadata; chmod -R 777 /home/metadata/*; echo 'Metadata copied successfully'; echo 'Files copied.' > /home/metadata/.devopsutils-copy-finished; else echo 'There is no metadatafiles'; fi;
      {{-  if or (contains "corews" $initContParam.image.repository) (contains "ftplatform" $initContParam.image.repository) }}
      datainstall_source=/opt/diasoft/datainstall/; datainstall_dest=/home/metadata/datainstall/; if [ -d "/opt/diasoft/flextera/datainstall/" ]; then datainstall_source=/opt/diasoft/flextera/datainstall/; fi; if [ -d "${datainstall_source}" ]; then cp -R ${datainstall_source} ${datainstall_dest}; echo 'Datainstall copied successfully'; echo 'Files copied.' > ${datainstall_dest}.devopsutils-copy-finished; else echo "Datainstall does not exists"; fi;
      {{- end }}
{{- else if or (contains "additionalfiles-" $initContParam.image.repository) (contains "-additionalfiles" $initContParam.image.repository) }}
    - '-c'
    - mkdir -p /home/additionalfiles; additionalfiles_path=/opt/diasoft/additionalfiles/; if [ ! -d ${additionalfiles_path} ];then additionalfiles_path=/opt/diasoft/flextera/additionalfiles/; fi; if [ -d ${additionalfiles_path} ];then cp -r ${additionalfiles_path}* /home/additionalfiles; echo 'Additionalfiles copied successfully'; echo 'Files copied.' > /home/additionalfiles/.devopsutils-copy-finished; else echo 'There is no additionalfiles'; fi;            
{{- end }}
{{- end }}