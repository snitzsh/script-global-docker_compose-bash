{{- /*
TODO:
  - build image per RUST_APP_PLATFORM_COMPONENTS
  - make port dynamic
*/}}
{{- define "apisRust" -}}
{{- $component_name := "api-rust" -}}
{{- $path := .Values.main_rust_env.path -}}
{{- $workdir := .Values.main_rust_env._workdir -}}
{{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" .Values "depends_on" (list "postgres" "redis")) -}}
apis:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "{{ $component_name }}"
  restart: "always"
  build:
    context: {{ $path }}
    dockerfile: "Dockerfile"
    target: {{ .Values.main_rust_env.docker_target }}
    args:
      _WORKDIR: {{ .Values.main_rust_env._workdir }}
      RUST_APP_PLATFORM_SCRIPT_TARGET: {{ .Values.main_rust_env.target_script }}
      RUST_APP_PLATFORM_CLUSTER_NAME: {{ .Values.env.cluster_name }}
      RUST_APP_PLATFORM_CLUSTER_TYPE: {{ .Values.env.cluster_type }}
      RUST_APP_PLATFORM_HOST: {{ .Values.main_rust_env.target_script }}
      RUST_APP_PLATFORM_PORT: "3000"
  environment: {}
  volumes:
    - "{{ $path }}:{{ $workdir }}"
  labels:
    - "com.docker.compose.service=private"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=apis"
  ports:
    - '3000:3000'
  {{- $depends_on }}

  {{- /*
  command: api-rust
    TODO: Enabled property if any is enabled
  */}}
{{- end }}
