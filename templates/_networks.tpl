{{- /*

TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - Generates network per compose file (not service)

ARGS:
  - globals
      data-type     : dict
      description   : Helm's global dict
      example       : {<[helm's object]>}
  - app_name:
      data-type     : string (optional)
      description   : app's name from $.apps[] or nill
      example       : "<[app_name]>" | nil
  - data_type:
      data-type     : string
      description   : generate a proper output based on value
      example       : "dict | list"

RETURN:
  - dict

OUTPUT:
  {
    ...,
    "<[app_name]>": {},
    ...
  }

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
