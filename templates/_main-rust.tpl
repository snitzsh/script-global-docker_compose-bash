{{- /*
TODO:
  - build image per RUST_APP_PLATFORM_COMPONENTS
  - make port dynamic
*/}}
{{- define "docker-compose.main-rust" -}}
  {{- /* Args */}}
  {{- $globals := .globals }}
  {{- $software_type := .software_type }}
  {{- $utility_name := .utility_name }}
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
  {{- $service_name := printf "%s-%s-%s" $utility_name $app_name $project_name }}
  {{- $folder_name := printf "%s/%s/%s" $utility_name $app_name $project_name }}
  {{- /* imported modules */}}
  {{- $depends_on_2 := include "docker-compose.functions.depends-on" (
        dict
          "globals" $globals
          "depends_on" $depends_on
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $service_labels := (
        include "docker-compose.functions.service-labels" .
      ) | fromJson | toYaml | nindent 2
  }}
  {{- $networks := include "docker-compose.networks" (
        dict
          "globals" $globals
          "app_name" $app_name
          "data_type" "list"
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
      RUST_APP_PLATFORM_SCRIPT_TARGET: {{ $project_obj.target_script }}
      RUST_APP_PLATFORM_CLUSTER_NAME: {{ $values.env.cluster_name }}
      RUST_APP_PLATFORM_CLUSTER_TYPE: {{ $values.env.cluster_type }}
      RUST_APP_PLATFORM_HOST: {{ $project_obj.host }}
      RUST_APP_PLATFORM_PORT: "3000"
  image: "{{ $service_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: "always"
  stdin_open: true
  tty: true
  environment: {}
  volumes:
    - "{{ $path }}{{ $folder_name }}:{{ $workdir }}"
  {{ $service_labels }}
  ports:
    - '3000:3000'
  {{ $networks }}
  {{ $depends_on_2 }}
  {{- /*
  command: api-rust
  */}}
  {{- end }}
{{- end }}
