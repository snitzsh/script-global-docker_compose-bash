{{- /*
Docs:
  - https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.
TODO:
  - make port dynamic
*/}}
{{- define "docker-compose.redisinsight" -}}
  {{- /* args */}}
  {{- $globals := .globals }}
  {{- $software_type := .software_type }}
  {{- $component_name := .component_name }}
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
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name }}
  {{- $folder_name := printf "%s/%s/%s" $component_name $app_name $project_name }}
  {{- /* imported modules */}}
  {{- $depends_on_2 := include "docker-compose.functions.depends-on" (
        dict
          "global" $values
          "depends_on" $depends_on
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $service_labels := (
        include "docker-compose.functions.service-labels" .
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "redis")
          "data_type" "array"
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
  {{ $service_labels  }}
  ports:
    - 5540:5540
  {{ $networks }}
  {{ $depends_on_2 }}
  {{- end }}
{{- end }}
