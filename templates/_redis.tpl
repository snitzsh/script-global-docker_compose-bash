{{- /*
Docs:
  - https://github.com/redis/redis/blob/unstable/redis.conf
  - https://www.docker.com/blog/how-to-use-the-redis-docker-official-image/

TODO:
  - make port dynamic
  - Support configs volume.
*/}}
{{- define "redis" -}}
  {{- /* args */}}
  {{- $globals := .globals -}}
  {{- $software_type := .software_type -}}
  {{- $component_name := .component_name -}}
  {{- $app_name := .app_name -}}
  {{- $project_name := .project_name -}}
  {{- $project_obj := .project_obj -}}
  {{- /* globals */}}
  {{- $values := $globals.Values -}}
  {{- $image_only := $values.image_only -}}
  {{- $platform := $values.platform -}}
  {{- /* image configs */}}
  {{- $path := $project_obj.path -}}
  {{- $workdir := $project_obj._workdir -}}
  {{- $tag := $project_obj.tag -}}
  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_name $app_name $project_name -}}
  {{- /* imported modules */}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "redis")
          "data_type" "array"
      )
  -}}

{{ $service_name }}:
  image: "{{ $component_name }}:{{ $tag }}"
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
  {{- $networks | indent 2 -}}
  {{- end }}
{{- end }}
