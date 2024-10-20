{{- /*
TODO:
  - disbaled networks if image_only: true
*/}}
{{- define "docker-compose.networks" -}}
  {{- $globals := .globals }}
  {{- $app_name := .app_name }}
  {{- $data_type := .data_type }}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "globals" $globals
          "app_name" $app_name
          "data_type" $data_type
      ) | fromJson
  }}
  {{ $networks | toJson }}
{{- end }}
