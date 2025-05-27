{{- define "cms.param" -}}
{{- $params := (index . 0) }}
{{- $kind := (index . 1) }}

{{- $dbSecretCriteryList := list "DB_DATABASE" "DB_DRIVER" "DB_LOGIN" "DB_PASSWORD" "DATASOURCE_LOGIN" "DATASOURCE_PASSWORD" "DATASOURCE_DRIVER_CLASS_NAME" "DB_ADMIN" "DB_ADMINPASSWORD" "DB_HOST" "DB_PORT" "DB_TYPE" "DATASOURCE_USERNAME" "DB_SCHEMA" "DB_SID" "DB_SERVICE_NAME" "DB_POSTGRESDRIVER" "DB_URL" "DATASOURCE_URL" "MDPSECURITY_DB_DRIVER" "MDPSECURITY_DB_DATABASE" "MDPSECURITY_DB_SCHEMA" "MDPSECURITY_DB_URL" "MDPSECURITY_DB_CONNECTION_TEST_QUERY" }}
{{- $systemCriteryList := list "LIMIT_CPU" "LIMIT_MEMORY" "REQUEST_CPU" "REQUEST_MEMORY" "PROBE_TYPE" "PROBE_APP_CONTEXT" "PROBE_API" "PROBE_COMMAND" "NODE_PORT" "SERVICE_TYPE" "PVC_ENABLE" "SERVICE_ACCOUNT" "NODE_SELECTOR" "NODE_NAME" "INGRESS_HOSTS" "INGRESS_TLS_USE" "INGRESS_TLS_CM_ISSUER" "INGRESS_TLS_CM_ISSUER_KIND" "INGRESS_TLS_CM_ISSUER_GROUP" "INGRESS_PATH_VARIETY_USE" }}
{{- $loginMaskList := list "PASSWORD" "LOGIN" "USERNAME" "OAUTH2_CLIENT_ID" "OAUTH2_CLIENT_SECRET" }}
{{- $nothingToDoList := list "CHANNEL_PREFIX" }}

{{- $dbDict := dict }}
{{- $sysDict := dict }}
{{- $loginDict := dict }}
{{- $nothingToDoDict := dict }}
{{- $simpleDict := dict }}

{{- range $key, $val := $params }}
{{-   if has $key $dbSecretCriteryList}}
{{-    $_ := set $dbDict $key $val }}
{{-    else if has $key $systemCriteryList}}
{{-      $_ := set $sysDict $key $val }}
{{-    else if has $key $nothingToDoList}}
{{-      $_ := set $nothingToDoDict $key $val }}
{{-    else }}
{{-      range $mask := $loginMaskList }}
{{-        if contains (lower $mask) (lower $key)}}
{{-          $_ := set $loginDict $key $val }}
{{-        end }}
{{-      end }}
{{-      if and (not (hasKey $dbDict $key)) (not (hasKey $sysDict $key)) (not (hasKey $nothingToDoDict $key)) (not (hasKey $loginDict $key))}}
{{-          $_ := set $simpleDict $key $val }}
{{-      end }} 
{{-   end }}  
{{- end }}  


{{- if (eq $kind "db-secret") }}
{{-   range $key, $val := $dbDict }}
{{      $key }}: {{ $val | b64enc | quote }}
{{-   end }}
{{- else if (eq $kind "login-secret") }}
{{-   range $key, $val := $loginDict }}
{{      $key }}: {{ $val | b64enc | quote }}
{{-   end }}
{{- else if (eq $kind "configmap") }}
{{-   range $key, $val := $simpleDict }}
{{       $key }}: {{ $val | quote }}
{{-   end }}
{{- end }}

{{- end }}
