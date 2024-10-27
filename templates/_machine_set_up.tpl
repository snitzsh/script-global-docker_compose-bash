{{- define "docker-compose.machine_set_up-bash" -}}
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
  {{- $env := $values.env }}
  {{- /* project configs */}}
  {{- $images := $project_obj.images }}
  {{- $path := $project_obj.path }}
  {{- $tag := $project_obj.tag }}
  {{- $_workdir := $project_obj._workdir }}
  {{- $target := $project_obj.target }}
  {{- $target_script := $project_obj.target_script }}
  {{- $host := $project_obj.host }}
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
    target: {{ $target }}
    args:
      _WORKDIR: {{ $_workdir }}
  image: "{{ $service_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  restart: always
  stdin_open: true
  tty: true
  environment: {}
  volumes:
    - "{{ $path }}{{ $folder_name }}:{{ $_workdir }}"
  {{ $labels_yaml | nindent 2 }}
  {{- /*
  ports:
    - '3000:3000'
  {{ $networks_yaml | nindent 2 }}
  {{ $depends_on_yaml | nindent 2 }}
  command: npm run local
  */}}
  {{- end }}
{{- end }}
