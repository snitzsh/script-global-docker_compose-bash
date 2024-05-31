{{- /*
TODO:
  - make port dynamic
*/}}
{{- define "pgadmin4" -}}
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
  {{- $depends_on := include "docker-compose.functions.depends_on" (
        dict
          "global" $values
          "app_name" $app_name
          "depends_on" (list "postgres")
      )
  -}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "postgres")
          "data_type" "array"
      )
  -}}

{{ $service_name }}:
  image: "dpage/{{ $component_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: always
  stdin_open: true
  tty: true
  environment:
    PGADMIN_DEFAULT_EMAIL: {{ $values.auth.email }}
    PGADMIN_DEFAULT_PASSWORD: {{ $values.auth.password }}
  volumes:
    - "./volumes/{{ $service_name }}:/var/lib/pgadmin"
  {{ $service_labels }}
  expose:
    - '80'
  ports:
    - '5050:80'
  {{- $networks | indent 2 }}
  {{- $depends_on | indent 2 }}
  {{- end }}
{{- end }}
