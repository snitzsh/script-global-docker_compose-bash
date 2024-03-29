{{- define "pgadmin4" -}}
{{- $component_name := "pgadmin4" -}}
pgadmin4:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "dpage/{{ $component_name }}:latest"
  restart: always
  environment:
    PGADMIN_DEFAULT_EMAIL: {{ .Values.auth.email }}
    PGADMIN_DEFAULT_PASSWORD: {{ .Values.auth.password }}
  volumes:
    - "./volumes/{{ $component_name }}:/var/lib/pgadmin"
  labels:
    - "com.docker.compose.service=public"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=db-ui"
  expose:
    - '80'
  ports:
    - '5050:80'
  networks:
    - postgres
  depends_on:
    - postgres
{{- end }}
