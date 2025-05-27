{{/* UNIPROBE */}}
{{- define "app.uniProbe" -}}
{{- $param := (index . 0)}}
{{- $probeKind := (index . 2)}}
{{- $paramDict := ($param.Values | merge (dict)) -}}
{{- $moduleName := ( include "app.name" $param) -}}

{{- if (dig $probeKind "enabled" "false" $paramDict) }}
{{- $port := (first (index . 1).ports).port|int }}
{{- $probeType := dig $probeKind "type" "tcp" $paramDict }}
{{$probeKind}}:
{{-   if eq $probeType "tcp" }}
  tcpSocket:
    port: {{ $port }} 
{{-   else if eq $probeType "http" }}
{{- $rpContext := (dig $probeKind "context" (dig $moduleName "SERVICE_CONTEXT" (dig $moduleName "PROBE_APP_CONTEXT" (dig $moduleName "SERVICE_NAME" $moduleName $paramDict) $paramDict) $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/"}}
{{- $rpApi := (dig $probeKind "api" (dig $moduleName "PROBE_API" "/actuator/health" $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/" }}
  httpGet:
    path: {{ empty $rpContext | ternary "" (print "/" $rpContext)}}{{ empty $rpApi | ternary "" (print "/" $rpApi) }}
    port: {{ $port }}
{{-   else if eq $probeType "command" }}
{{-  $rpCommand := (dig $probeKind "command" "" $paramDict) }}
      {{- if $param.Values.initContainers }}  
        {{- range $param.Values.initContainers }}
          {{- if contains "devopsutils" .image.repository }}
            {{- $rpCommand = ternary (printf "%s %d %s %s" .scripts.probeHealthCheck $port $moduleName $moduleName) $rpCommand (gt (.image.tag | int) 22090801) }}
          {{- end }}  
        {{- end }}  
      {{- end }}
  exec:
    command: ['sh', '-c', '{{$rpCommand}}']
{{-   end }}

{{-   if (dig $probeKind "timeoutSeconds" nil $paramDict) }}
  timeoutSeconds: {{ (dig $probeKind "timeoutSeconds" nil $paramDict) |int }}
{{-   end }}
{{-   if (dig $probeKind "periodSeconds" nil $paramDict) }}
  periodSeconds: {{ (dig $probeKind "periodSeconds" nil $paramDict) |int }}
{{-   end }}
{{-   if (dig $probeKind "successThreshold" nil $paramDict) }}
  successThreshold: {{ (dig $probeKind "successThreshold" nil $paramDict) |int }}
{{-   end }}
{{-   if (dig $probeKind "failureThreshold" nil $paramDict) }}
  failureThreshold: {{ (dig $probeKind "failureThreshold" nil $paramDict) |int }}
{{-   end }}
{{-   if and (dig $probeKind "initialDelaySeconds" nil $paramDict) (eq $probeKind "livenessProbe") }}
  initialDelaySeconds: {{ (dig $probeKind "initialDelaySeconds" nil $paramDict) |int }}
{{-   end }}

{{- end }}
{{- end }}



{{/* READINESSPROBE */}}
{{- define "app.readinessProbe" -}}
{{- $param := (index . 0)}}
{{- $paramDict := ($param.Values | merge (dict)) -}}
{{- $moduleName := ( include "app.name" $param) -}}

{{- if $param.Values.readinessProbe.enabled }}
{{- $port := (first (index . 1).ports).port|int}}
readinessProbe:
{{-   if eq $param.Values.readinessProbe.type "tcp" }}
  tcpSocket:
    port: {{ $port }} 
{{-   else if eq $param.Values.readinessProbe.type "http" }}
{{- $rpContext := (dig "readinessProbe" "context" (dig $moduleName "SERVICE_CONTEXT" (dig $moduleName "PROBE_APP_CONTEXT" (dig $moduleName "SERVICE_NAME" $moduleName $paramDict) $paramDict) $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/"}}
{{- $rpApi := (dig "readinessProbe" "api" (dig $moduleName "PROBE_API" "/actuator/health" $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/" }}
  httpGet:
    path: /{{$rpContext}}/{{$rpApi}}
    port: {{ $port }}
{{-   else if eq $param.Values.readinessProbe.type "command" }}
{{- $rpCommand := (dig "readinessProbe" "command" (ternary (printf "%s %d %s %s" $param.Values.devopsutils.scripts.probeHealthCheck $port $moduleName $moduleName) "" (gt ($param.Values.devopsutils.image.tag | int) 22090801)) $paramDict) }}
  exec:
    command: ['sh', '-c', '{{$rpCommand}}']
{{-   end }}

{{-   if $param.Values.readinessProbe.timeoutSeconds }}
  timeoutSeconds: {{ $param.Values.readinessProbe.timeoutSeconds |int }}
{{-   end }}
{{-   if $param.Values.readinessProbe.periodSeconds }}
  periodSeconds: {{ $param.Values.readinessProbe.periodSeconds |int }}
{{-   end }}
{{-   if $param.Values.readinessProbe.successThreshold }}
  successThreshold: {{ $param.Values.readinessProbe.successThreshold |int }}
{{-   end }}
{{-   if $param.Values.readinessProbe.failureThreshold }}
  failureThreshold: {{ $param.Values.readinessProbe.failureThreshold |int }}
{{-   end }}

{{- end }}
{{- end }}

{{/* LIVENESSPROBE */}}
{{- define "app.livenessProbe" -}}
{{- $param := (index . 0)}}
{{- $paramDict := ($param.Values | merge (dict)) -}}
{{- $moduleName := ( include "app.name" $param) -}}

{{- if $param.Values.livenessProbe.enabled }}
{{- $port := (first (index . 1).ports).port|int}}
livenessProbe:
{{-   if eq $param.Values.livenessProbe.type "tcp" }}
  tcpSocket:
    port: {{ $port }} 
{{-   else if eq $param.Values.livenessProbe.type "http" }}
{{- $rpContext := (dig "livenessProbe" "context" (dig $moduleName "SERVICE_CONTEXT" (dig $moduleName "PROBE_APP_CONTEXT" (dig $moduleName "SERVICE_NAME" $moduleName $paramDict) $paramDict) $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/"}}
{{- $rpApi := (dig "livenessProbe" "api" (dig $moduleName "PROBE_API" "/actuator/health" $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/" }}
  httpGet:
    path: /{{$rpContext}}/{{$rpApi}}
    port: {{ $port }}
{{-   else if eq $param.Values.livenessProbe.type "command" }}
{{- $rpCommand := (dig "livenessProbe" "command" (ternary (printf "%s %d %s %s" $param.Values.devopsutils.scripts.probeHealthCheck $port $moduleName $moduleName) "" (gt ($param.Values.devopsutils.image.tag | int) 22090801)) $paramDict) }}
  exec:
    command: ['sh', '-c', '{{$rpCommand}}']
{{-   end }}

{{-   if $param.Values.livenessProbe.timeoutSeconds }}
  timeoutSeconds: {{ $param.Values.livenessProbe.timeoutSeconds |int }}
{{-   end }}
{{-   if $param.Values.livenessProbe.periodSeconds }}
  periodSeconds: {{ $param.Values.livenessProbe.periodSeconds |int }}
{{-   end }}
{{-   if $param.Values.livenessProbe.successThreshold }}
  successThreshold: {{ $param.Values.livenessProbe.successThreshold |int }}
{{-   end }}
{{-   if $param.Values.livenessProbe.failureThreshold }}
  failureThreshold: {{ $param.Values.livenessProbe.failureThreshold |int }}
{{-   end }}
{{-   if $param.Values.livenessProbe.initialDelaySeconds }}
  initialDelaySeconds: {{ $param.Values.livenessProbe.initialDelaySeconds |int }}
{{-   end }}

{{- end }}
{{- end }}

{{/* STARTUPPROBE */}}
{{- define "app.startupProbe" -}}
{{- $param := (index . 0)}}
{{- $paramDict := ($param.Values | merge (dict)) -}}
{{- $moduleName := ( include "app.name" $param) -}}

{{- if $param.Values.startupProbe.enabled }}
{{- $port := (first (index . 1).ports).port|int}}
startupProbe:
{{-   if eq $param.Values.startupProbe.type "tcp" }}
  tcpSocket:
    port: {{ $port }} 
{{-   else if eq $param.Values.startupProbe.type "http" }}
{{- $rpContext := (dig "startupProbe" "context" (dig $moduleName "SERVICE_CONTEXT" (dig $moduleName "PROBE_APP_CONTEXT" (dig $moduleName "SERVICE_NAME" $moduleName $paramDict) $paramDict) $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/"}}
{{- $rpApi := (dig "startupProbe" "api" (dig $moduleName "PROBE_API" "/actuator/health" $paramDict) $paramDict) | trimSuffix "/" | trimPrefix "/" }}
  httpGet:
    path: /{{$rpContext}}/{{$rpApi}}
    port: {{ $port }}
{{-   else if eq $param.Values.startupProbe.type "command" }}
{{- $rpCommand := (dig "startupProbe" "command" (ternary (printf "%s %d %s %s" $param.Values.devopsutils.scripts.probeHealthCheck $port $moduleName $moduleName) "" (gt ($param.Values.devopsutils.image.tag | int) 22090801)) $paramDict) }}
  exec:
    command: ['sh', '-c', '{{$rpCommand}}']
{{-   end }}

{{-   if $param.Values.startupProbe.timeoutSeconds }}
  timeoutSeconds: {{ $param.Values.startupProbe.timeoutSeconds |int }}
{{-   end }}
{{-   if $param.Values.startupProbe.periodSeconds }}
  periodSeconds: {{ $param.Values.startupProbe.periodSeconds |int }}
{{-   end }}
{{-   if $param.Values.startupProbe.successThreshold }}
  successThreshold: {{ $param.Values.startupProbe.successThreshold |int }}
{{-   end }}
{{-   if $param.Values.startupProbe.failureThreshold }}
  failureThreshold: {{ $param.Values.startupProbe.failureThreshold |int }}
{{-   end }}

{{- end }}
{{- end }}


