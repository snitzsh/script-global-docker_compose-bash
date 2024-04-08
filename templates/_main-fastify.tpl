{{- define "main-fastify" -}}
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
  {{- $path := $component_configs.path -}}
  {{- $workdir := $component_configs._workdir -}}
  {{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" $values "depends_on" (list "postgres" "redis")) -}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}

{{ $service_name }}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: {{ $service_name }}:latest
  restart: always
  platform: {{ $platform }}
  build:
    context: "{{ $path }}{{ $folder_name }}"
    dockerfile: "Dockerfile"
    target: {{ $component_configs.target }}
    args:
      _WORKDIR: {{ $component_configs._workdir }}
      RUST_APP_PLATFORM_SCRIPT_TARGET: {{ $component_configs.target_script }}
      RUST_APP_PLATFORM_CLUSTER_NAME: {{ $values.env.cluster_name }}
      RUST_APP_PLATFORM_CLUSTER_TYPE: {{ $values.env.cluster_type }}
      RUST_APP_PLATFORM_HOST: {{ $component_configs.host }}
      RUST_APP_PLATFORM_PORT: "3000"
  environment: {}
  volumes:
    - "{{ $path }}{{ $folder_name }}:{{ $workdir }}"
  {{ $service_labels }}
  ports:
    - '3000:3000'
  {{- $depends_on | indent 2 }}
  {{- /*
  command: npm run local
  */}}
{{- end }}
