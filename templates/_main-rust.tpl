{{- /*
TODO:
  - build image per RUST_APP_PLATFORM_COMPONENTS
  - make port dynamic
  - make tag dynamic
  - Make this file to either just build image or build image and create container
*/}}
{{- define "main-rust" -}}
  {{- $globals := .globals -}}
  {{- $app_name := .app_name -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $values := $globals.Values -}}
  {{- $architecture := $values.platform.architecture -}}
  {{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" $globals.Values "depends_on" (list "postgres" "redis")) -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_type $app_name $component_name -}}
  {{- $image_env := index $values $service_name -}}
  {{- $path := $image_env.path -}}
  {{- $workdir := $image_env._workdir -}}

{{- $service_name -}}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: "{{ $service_name }}:latest"
  restart: "always"
  platform:
    architecture: {{ $architecture }}
  build:
    context: "{{ $path }}{{ $folder_name }}"
    dockerfile: "Dockerfile"
    target: {{ $image_env.docker_target }}
    args:
      _WORKDIR: {{ $image_env._workdir }}
      RUST_APP_PLATFORM_SCRIPT_TARGET: {{ $image_env.target_script }}
      RUST_APP_PLATFORM_CLUSTER_NAME: {{ $values.env.cluster_name }}
      RUST_APP_PLATFORM_CLUSTER_TYPE: {{ $values.env.cluster_type }}
      RUST_APP_PLATFORM_HOST: {{ $image_env.host }}
      RUST_APP_PLATFORM_PORT: "3000"
  environment: {}
  volumes:
    - "{{ $path }}{{ $folder_name }}:{{ $workdir }}"
  labels:
    - "com.docker.compose.app-name={{ $app_name }}"
    - "com.docker.compose.software-type={{ $software_type }}"
    - "com.docker.compose.component-type={{ $component_type }}"
    - "com.docker.compose.service-name={{ $service_name }}"
    - "com.docker.compose.docker-target={{ $image_env.docker_target }}"
    - "com.docker.compose.docker-target-script={{ $image_env.target_script }}"
    - "com.docker.compose.architecture={{ $architecture }}"
  ports:
    - '3000:3000'
  {{- $depends_on }}

  {{- /*
  command: api-rust
  */}}
{{- end }}
