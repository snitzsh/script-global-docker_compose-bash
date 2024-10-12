{{- /*
TODO:
  - disbaled networks if image_only: true
*/}}
{{- define "docker-compose.volumes" -}}
{{- $volumes := include "docker-compose.functions.volumes" (
      dict
        "global" .Values
    ) | fromJson
}}
{{ $volumes | toJson }}
{{- end }}
