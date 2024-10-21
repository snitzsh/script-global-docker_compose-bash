{{- /*

TODO:
  - build image per VITE_APP_PLATFORM_COMPONENTS
  - make port dynamic

NOTE:
  - null

DESCRIPTION:
  - Generates service

ARGS:
  - globals
      data-type   : dict
      description : Helm's global dict
      example     : {<[helm's object]>}
  - software_type
      data-type     : string
      description   : service's software type
      example       : "<[software_type]>"
  - utility_name
      data-type     : string
      description   : service's utility name
      example       : "<[utilty_name]>"
  - app_name
      data-type     : string
      description   : service's app name
      example       : "<[app_name]>"
  - project_name
      data-type     : string
      description   : service's project name
      example       : "<[project_name]>"
  - project_object
      data-type     : dict
      description   : service's project info
      example       : {..., "key": "value", ...}

RETURN:
  - yaml

OUTPUT:
  a:
    b: c

*/}}
{{- define "docker-compose.main-vue" -}}
  {{- /* args */}}
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
  {{- $depends_on_yaml := $project_obj.depends_on_yaml }}
  {{- $service_name := $project_obj.service_name }}
  {{- $folder_name := $project_obj.folder_name }}
  {{- $labels_yaml := $project_obj.labels_yaml }}
  {{- $networks_yaml := $project_obj.networks_yaml }}
  {{- /* local variables */}}
  {{- /* imported modules */}}

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
  {{ $labels_yaml | nindent 2 }}
  ports:
    - "8080:8080"
  {{ $networks_yaml | nindent 2 }}
  {{ $depends_on_yaml | nindent 2 }}
  {{- /*
    expose:
      - "8080"
    command: npm run serve
  */}}
  {{- end }}
{{- end }}
