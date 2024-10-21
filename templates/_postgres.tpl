{{- /*

TODO:
  - Support multi db per app (same image or different image)
  - make port dynamic
  - Support configs volume.

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
{{- define "docker-compose.postgres" -}}
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
  hostname: {{ $service_name }}
  restart: always
  stdin_open: true
  tty: true
  environment:
    POSTGRES_USER: {{ $values.auth.username }}
    POSTGRES_PASSWORD: {{ $values.auth.password }}
    POSTGRES_DB: snitzsh_db
    {{- /*
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
  expose:
    - "5432"
  ports:
    - "5432:5432"
  {{ $networks }}
  {{ $depends_on_2 | nindent 2 }}
  {{- end }}
{{- end }}
