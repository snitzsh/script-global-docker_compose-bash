{{- /*

TODO:
  - Support configs volume.

DOCS:
  - https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.

NOTE:
  - null

DESCRIPTION:
  - Generates service

ARGS:
  - globals
      data-type   : dict
      description : Helm's global dict
      example     : {<[helm's object]>}
  - software_type
      data-type     : string
      description   : service's software type
      example       : "<[software_type]>"
  - utility_name
      data-type     : string
      description   : service's utility name
      example       : "<[utilty_name]>"
  - app_name
      data-type     : string
      description   : service's app name
      example       : "<[app_name]>"
  - project_name
      data-type     : string
      description   : service's project name
      example       : "<[project_name]>"
  - project_object
      data-type     : dict
      description   : service's project info
      example       : {..., "key": "value", ...}

RETURN:
  - yaml

OUTPUT:
  a:
    b: c

*/}}
{{- define "docker-compose.redisinsight" -}}
  {{- /* args */}}
  {{- $globals := .globals }}
  {{- $software_type := .software_type }}
  {{- $utility_name := .utility_name }}
  {{- $app_name := .app_name }}
  {{- $project_name := .project_name }}
  {{- $project_obj := .project_obj }}
  {{- /* globals */}}
  {{- $values := $globals.Values }}
  {{- $image_only := $values.image_only }}
  {{- $platform := $values.platform }}
  {{- /* image configs */}}
  {{- $path := $project_obj.path }}
  {{- $workdir := $project_obj._workdir }}
  {{- $tag := $project_obj.tag }}
  {{- $depends_on_2 := $project_obj.depends_on_2 }}
  {{- $service_name := $project_obj.service_name }}
  {{- $folder_name := $project_obj.folder_name }}
  {{- $labels_yaml := $project_obj.labels_yaml }}
  {{- /* local variables */}}
  {{- /* imported modules */}}
  {{- $networks := include "docker-compose.networks" (
        dict
          "globals" $globals
          "app_name" $app_name
          "data_type" "list"
      ) | fromJson | toYaml | nindent 2
  }}

{{ $service_name }}:
  image: "redislabs/{{ $project_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: always
  stdin_open: true
  tty: true
  environment: {}
  volumes:
    - "./volumes/{{ $service_name }}:/db"
  {{ $labels_yaml | nindent 2 }}
  ports:
    - 5540:5540
  {{ $networks }}
  {{ $depends_on_2 | nindent 2 }}
  {{- end }}
{{- end }}
