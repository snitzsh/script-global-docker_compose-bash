{{- /*

TODO:
  - make port dynamic
  - Support configs volume.

DOCS:
  - https://github.com/redis/redis/blob/unstable/redis.conf
  - https://www.docker.com/blog/how-to-use-the-redis-docker-official-image/

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
{{- define "docker-compose.redis" -}}
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
  {{- $depends_on := $project_obj.depends_on }}
  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $utility_name $app_name $project_name }}
  {{- $folder_name := printf "%s/%s/%s" $utility_name $app_name $project_name }}
  {{- /* imported modules */}}
  {{- $depends_on_2 := include "docker-compose.functions.depends-on" (
        dict
          "globals" $globals
          "depends_on" $depends_on
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $service_labels := (
        include "docker-compose.functions.service-labels" .
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $networks := include "docker-compose.networks" (
        dict
          "globals" $globals
          "app_name" $app_name
          "data_type" "list"
      ) | fromJson | toYaml | nindent 2
  }}

{{ $service_name }}:
  image: "{{ $project_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: always
  stdin_open: true
  tty: true
  environment:
    REDIS_USERNAME: {{ $values.auth.username }}
  volumes:
    - "./volumes/{{ $service_name }}/data:/data"
    {{- /*
      - "./configs/{{ $service_name }}/config:/user/local/etc/redis"
    */}}
  {{ $service_labels }}
  expose:
    - "6379"
  ports:
    - "6379:6379"
  command: "redis-server --save 20 1 --loglevel warning --requirepass {{ $values.auth.password }}"
  {{ $networks }}
  {{ $depends_on_2 }}
  {{- end }}
{{- end }}
