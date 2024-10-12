{{- /*
TODO:
  - build image per VITE_APP_PLATFORM_COMPONENTS
  - make port dynamic
*/}}
{{- define "docker-compose.main-vue" -}}
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
  {{- $depends_on_1 := $project_obj.depends_on }}
  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name }}
  {{- $folder_name := printf "%s/%s/%s" $component_name $app_name $project_name }}
  {{- /* imported modules "depends_on" (list "postgres" "redis") */}}
  {{- $depends_on := include "docker-compose.functions.depends_on" (
        dict
          "global" $values
          "app_name" $app_name
          "depends_on" $depends_on_1
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $service_labels := (
        include "docker-compose.functions.service-labels" .
      ) | fromJson | toYaml | nindent 2
  }}

{{ $service_name }}:
  build:
    {{- /*
      TODO:
        - make sure you handle same naming convention as github repo names
          Ex: there are names that *-camel_case_repo_name-*
          Name of the repos should be the same as the image names
    */}}
    context: "{{ $path }}{{ $folder_name }}"
    dockerfile: "Dockerfile"
    target: {{ $project_obj.target }}
    args:
      _WORKDIR: {{ $project_obj._workdir }}
      VITE_APP_PLATFORM_SCRIPT_TARGET: {{ $project_obj.target_script }}
      VITE_APP_PLATFORM_CLUSTER_NAME: {{ $values.env.cluster_name }}
      VITE_APP_PLATFORM_CLUSTER_TYPE: {{ $values.env.cluster_type }}
      VITE_APP_PLATFORM_HOST: {{ $project_obj.host }}
      VITE_APP_PLATFORM_PORT: "8080"
  image: "{{ $service_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: "always"
  stdin_open: true
  tty: true
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
  {{ $depends_on }}
  {{- /*
    expose:
      - "8080"
    command: npm run serve
  */}}
  {{- end }}
{{- end }}
