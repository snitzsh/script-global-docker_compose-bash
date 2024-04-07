{{- define "pgadmin4" -}}
{{- $component_name := "pgadmin4" -}}
{{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" .Values "depends_on" (list "postgres")) -}}
{{- $networks := include "docker-compose.functions.networks" (dict "global" .Values "networks" (list "postgres") "data_type" "array") -}}
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
  {{- $networks | indent 2 }}
  {{- $depends_on | indent 2 }}
{{- end }}
