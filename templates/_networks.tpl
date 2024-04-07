{{- define "networks" -}}
{{- $networks := include "docker-compose.functions.networks" (dict "global" .Values "networks" (list "postgres" "redis") "data_type" "object") -}}
{{- $networks }}
{{- end }}
