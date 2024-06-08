{{- /*
TODO:
  - disbaled networks if image_only: true
*/}}
{{- define "networks" -}}
{{- $globals := .globals }}
{{- $service_name := .service_name }}
{{- $networks := include "docker-compose.functions.networks" (
      dict
        "global" $globals.Values
        "networks" (list "postgres" "redis")
        "data_type" "object"
        "service_name" $service_name
    )
-}}
{{- $networks -}}
{{- end }}
