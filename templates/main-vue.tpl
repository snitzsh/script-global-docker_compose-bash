{{- /*
TODO:
  - build image per VITE_APP_PLATFORM_COMPONENTS
*/}}
{{- define "mainVue" -}}
{{- $component_name := "main-vue" -}}
{{- $path := .Values.main_vue_env.path -}}
{{- $workdir := .Values.main_vue_env._workdir -}}
main_vue:
  container_name: {{ $component_name }}
  image: "{{ $component_name }}"
  restart: "always"
  stdin_open: true
  tty: true
  build:
    context: {{ $path }}
    dockerfile: "Dockerfile"
    target: {{ .Values.main_vue_env.docker_target }}
    args:
      _WORKDIR: {{ .Values.main_vue_env._workdir }}
      VITE_APP_PLATFORM_SCRIPT_TARGET: {{ .Values.main_vue_env.target_script }}
      VITE_APP_PLATFORM_CLUSTER_NAME: {{ .Values.env.cluster_name }}
      VITE_APP_PLATFORM_CLUSTER_TYPE: {{ .Values.env.cluster_type }}
      VITE_APP_PLATFORM_HOST: {{ .Values.main_vue_env.target_script }}
      {{- /* TODO: make port dynamic */}}
      VITE_APP_PLATFORM_PORT: "8080"
  environment: {}
  {{- /*
    environment:
      - HOST=0.0.0.0:3000
      - CHOKIDAR_USEPOLLING=true
  */}}
  volumes:
    {{- /*
      - "./volumes/{{ $component_name }}/:/app"
      # Volumes below only works for target: dev
    - "./volumes/{{ $component_name }}/src:/app/src"
    - "./volumes/{{ $component_name }}/package.json:/app/package.json"
    */}}
    - "{{ $path }}/src:{{ $workdir }}/src"
  labels:
    - "com.docker.compose.service=private"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=ui"
  ports:
    - "8080:8080"
  {{- /*
  # expose:
  #   - "8080"
    -- --public 0.0.0.0:8080
  # command: npm run serve
  */}}
{{- end }}
