{{- /*
TODO:
  - Support multi db per app.
*/}}
{{- define "postgres" -}}
  {{- $globals := .globals -}}
  {{- $app_name := .app_name -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $values := $globals.Values -}}
  {{- $platform := $values.platform -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_type $app_name $component_name -}}
  {{- $image_configs := .image_configs -}}
  {{- $tag := $image_configs.tag -}}
  {{- $path := $image_configs.path -}}
  {{- $workdir := $image_configs._workdir -}}

  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "postgres") "data_type" "array"
      )
  -}}

{{ $service_name }}:
  container_name: {{ $service_name }}
  hostname: {{ $service_name }}
  image: "{{ $component_name }}:{{ $tag }}"
  restart: always
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
  {{ $service_labels }}
  expose:
    - "5432"
  ports:
    - "5432:5432"
  {{- $networks | indent 2 }}
{{- end }}
