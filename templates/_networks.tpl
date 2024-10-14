{{- /*
TODO:
  - disbaled networks if image_only: true

NOTE:
  - null

DESCRIPTION:
  - Generates networks for the platform.

ARGS:
  - globals: dict
  - service_name: string

RETURN:
  - yaml

OUTPUT EXAMPLE:
  networks:
    cache-dbs-snitzsh-redis:
      driver: bridge
*/}}
{{- define "docker-compose.networks" -}}
{{- $globals := .globals }}
{{- $service_name := .service_name }}
{{- /*
*/}}
{{- $networks := include "docker-compose.functions.networks" (
      dict
        "global" $globals.Values
        "networks" (list "postgres" "redis")
        "data_type" "object"
        "service_name" $service_name
    ) | fromJson
}}

{{ $networks | toJson }}
{{- end }}
