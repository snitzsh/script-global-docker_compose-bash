{{- define "volumes" -}}
{{- $volumes := include "docker-compose.functions.volumes" (dict "global" .Values) -}}
{{- $volumes }}
{{- end }}
