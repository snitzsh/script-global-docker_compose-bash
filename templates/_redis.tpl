{{- /*
Docs:
  - https://github.com/redis/redis/blob/unstable/redis.conf
  - https://www.docker.com/blog/how-to-use-the-redis-docker-official-image/

TODO:
  - Support configs volume.
*/}}
{{- define "redis" -}}
  {{- $globals := .globals -}}
  {{- $app_name := .app_name -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $values := $globals.Values -}}
  {{- $platform := $values.platform -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_type $app_name $component_name -}}
  {{- $component_configs := .component_configs -}}
  {{- $tag := $component_configs.tag -}}
  {{- $path := $component_configs.path -}}
  {{- $workdir := $component_configs._workdir -}}

  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "app_name" $app_name
          "networks" (list "redis")
          "data_type" "array"
      )
  -}}

{{ $service_name }}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: "{{ $component_name }}:{{ $tag }}"
  restart: always
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
