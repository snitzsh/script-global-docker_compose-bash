{{- /*
https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.
  expose:
    - "8001"
*/}}

{{- define "redisinsight" -}}
  {{- $globals := .globals -}}
  {{- $app_name := .app_name -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $values := $globals.Values -}}
  {{- $platform := $values.platform -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_type $app_name $component_name -}}
  {{- $image_configs := .image_configs -}}
  {{- $tag := $image_configs.tag -}}
  {{- $path := $image_configs.path -}}
  {{- $workdir := $image_configs._workdir -}}

  {{- $depends_on := include "docker-compose.functions.depends_on" (
        dict
          "global" $values
          "app_name" $app_name
          "depends_on" (list "redis")
      )
  -}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "redis")
          "data_type" "array"
      )
  -}}

{{ $service_name }}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: "redislabs/{{ $component_name }}:{{ $tag }}"
  restart: always
  environment: {}
  volumes:
    - "./volumes/{{ $service_name }}:/db"
  {{ $service_labels }}
  ports:
    - 5540:5540
  {{- $networks | indent 2 }}
  {{- $depends_on | indent 2 }}
{{- end }}
