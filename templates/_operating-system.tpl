{{- define "docker-compose.operating-systems" -}}
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
  {{- /* project configs */}}
  {{- $images := $project_obj.images }}
  {{- $path := $project_obj.path }}
  {{- $workdir := $project_obj._workdir }}
  {{- $tag := $project_obj.tag }}
  {{- $depends_on_2 := $project_obj.depends_on_2 }}
  {{- $service_name := $project_obj.service_name }}
  {{- $folder_name := $project_obj.folder_name }}
  {{- $labels_yaml := $project_obj.labels_yaml }}
  {{- /* local variables */}}
  {{- /* imported modules */}}
  {{- $networks := include "docker-compose.networks" (
        dict
          "globals" $globals
          "app_name" $app_name
          "data_type" "list"
      ) | fromJson | toYaml | nindent 2
  }}

{{ $service_name }}:
  image: "{{ $project_name }}:{{ $tag }}"
  platform: {{ $platform }}
  {{- if not $image_only }}
  container_name: {{ $service_name }}
  {{- /*
  hostname: {{ $service_name }}
  */}}
  restart: always
  {{- /* This allows you to interact with the container and send input to it from your terminal. */}}
  stdin_open: true
  {{- /* This is useful if you want to run interactive commands within your container, such as a shell.*/}}
  tty: true
  environment: {}
    {{- /*
    # It should load all of the other components .env files.
    POSTGRES_USER: {{ $values.auth.username }}
    POSTGRES_PASSWORD: {{ $values.auth.password }}
    POSTGRES_DB: snitzsh_db
      # Additional databases
      DB1_NAME: mydb1
      DB1_USER: db1user
      DB1_PASSWORD: db1password
      DB2_NAME: mydb2
      DB2_USER: db2user
      DB2_PASSWORD: db2password
    */}}
  volumes:
    - "./volumes/{{ $service_name }}/data:/var/lib/postgresql/data"
    - "./volumes/{{ $service_name }}/init.sql:/docker-entrypoint-initdb.d/create_tables.sql"
  {{ $labels_yaml | nindent 2 }}
  {{- /*
  expose:
    - "5432"
  ports:
    - "5432:5432"
  */}}
  {{ $networks }}
  {{ $depends_on_2 | nindent 2 }}
  {{- end }}
{{- end }}
