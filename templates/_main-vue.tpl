{{- /*
TODO:
  - build image per VITE_APP_PLATFORM_COMPONENTS
*/}}

{{- define "main-vue" -}}
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
  {{- $path := $image_configs.path -}}
  {{- $workdir := $image_configs._workdir -}}
  {{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" $values "depends_on" (list "postgres" "redis")) -}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}

{{ $service_name }}:
  container_name: {{ $service_name }}
  image: "{{ $service_name }}:latest"
  restart: "always"
  stdin_open: true
  tty: true
  platform: {{ $platform }}
  build:
    context: "{{ $path }}{{ $folder_name }}"
    dockerfile: "Dockerfile"
    target: {{ $image_configs.target }}
    args:
      _WORKDIR: {{ $image_configs._workdir }}
      VITE_APP_PLATFORM_SCRIPT_TARGET: {{ $image_configs.target_script }}
      VITE_APP_PLATFORM_CLUSTER_NAME: {{ $values.env.cluster_name }}
      VITE_APP_PLATFORM_CLUSTER_TYPE: {{ $values.env.cluster_type }}
      VITE_APP_PLATFORM_HOST: {{ $image_configs.host }}
      VITE_APP_PLATFORM_PORT: "8080"
  environment: {}
  {{- /*
    environment:
      - CHOKIDAR_USEPOLLING=true
  */}}
  volumes:
    - "{{ $path }}{{ $folder_name }}/src:{{ $workdir }}/src"
  {{ $service_labels }}
  ports:
    - "8080:8080"
  {{- /*
    expose:
      - "8080"
    command: npm run serve
  */}}
{{- end }}
