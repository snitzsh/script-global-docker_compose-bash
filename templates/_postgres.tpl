{{- /*
TODO:
  - Support multi db per app (same image or different image)
  - make port dynamic
  - Support configs volume.
*/}}
{{- define "postgres" -}}
  {{- /* args */}}
  {{- $globals := .globals -}}
  {{- $software_type := .software_type -}}
  {{- $component_name := .component_name -}}
  {{- $app_name := .app_name -}}
  {{- $project_name := .project_name -}}
  {{- $project_obj := .project_obj -}}
  {{- /* globals */}}
  {{- $values := $globals.Values -}}
  {{- $image_only := $values.image_only -}}
  {{- $platform := $values.platform -}}
  {{- /* image configs */}}
  {{- $path := $project_obj.path -}}
  {{- $workdir := $project_obj._workdir -}}
  {{- $tag := $project_obj.tag -}}
  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name -}}
  {{- $folder_name := printf "%s/%s/%s" $component_name $app_name $project_name -}}
  {{- /* imported modules */}}
  {{- $service_labels := include "docker-compose.functions.service-labels" . -}}
  {{- $networks := include "docker-compose.functions.networks" (
        dict
          "global" $values
          "networks" (list "postgres")
          "data_type" "array"
      )
  -}}

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
  {{ $service_labels }}
  expose:
    - "5432"
  ports:
    - "5432:5432"
  {{- $networks | indent 2 }}
  {{- end }}
{{- end }}
