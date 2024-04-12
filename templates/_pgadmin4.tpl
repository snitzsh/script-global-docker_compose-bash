{{- define "pgadmin4" -}}
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
          "app_name" $app_name
          "networks" (list "postgres")
          "data_type" "array"
      )
  -}}
{{ $service_name }}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: "dpage/{{ $component_name }}:{{ $tag }}"
  restart: always
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
