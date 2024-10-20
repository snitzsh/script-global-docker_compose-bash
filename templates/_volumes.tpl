{{- /*

TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - Reusuable funciton that will generate networks.

ARGS:
  - globals
      data-type     : dict
      description   : Helm's global dict
      example       : {<[helm's object]>}
  - services_name:
      data-type     : list
      description   : services name to create volumes for.
      example       : ""

RETURN:
  - dict

OUTPUT:
  {
    ...,
    "<[service_name]>": {},
    ...
  }

*/}}
{{- define "docker-compose.volumes" -}}
  {{- $globals := .globals }}
  {{- $services_name := default list .services_name }}
  {{- $volumes := include "docker-compose.functions.volumes" (
        dict
          "globals" $globals
          "services_name" $services_name
      ) | fromJson
  }}
  {{ $volumes | toJson }}
{{- end }}
