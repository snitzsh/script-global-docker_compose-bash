{{- /*
TODO:
  - disbaled networks if image_only: true
*/}}
{{- define "docker-compose.volumes" -}}
  {{- $globals := .globals }}
  {{- $services_name := .services_name }}
{{- $volumes := include "docker-compose.functions.volumes" (
      dict
        "globals" $globals
        "services_name" $services_name
    ) | fromJson
}}
{{ $volumes | toJson }}
{{- end }}
