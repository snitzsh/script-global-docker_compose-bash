{{- /*
TODO:
  - Support multi db per app.
*/}}
{{- define "postgres" -}}
{{- $component_name := "postgres" -}}
postgres:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "{{ $component_name }}:latest"
  restart: always
  environment:
    POSTGRES_USER: {{ .Values.auth.username }}
    POSTGRES_PASSWORD: {{ .Values.auth.password }}
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
    - "./volumes/{{ $component_name }}/data:/var/lib/postgresql/data"
    - "./volumes/{{ $component_name }}/init.sql:/docker-entrypoint-initdb.d/create_tables.sql"
  labels:
    - "com.docker.compose.service=public"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=db"
  expose:
    - "5432"
  ports:
    - "5432:5432"
  networks:
    - postgres
{{- end }}
