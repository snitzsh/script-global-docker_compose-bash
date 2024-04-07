{{- define "main-fastify" -}}
{{- $component_name := "main-fastify" -}}
{{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" .Values "depends_on" (list "postgres" "redis")) -}}
main-fastify:
  {{- /*
    # build:
    #   context: . # Directory of where the docker file is.
    #   dockerfile: Dockerfile # name of the docker file
    #   target: base # look at the Dockerfile for `as local`, that way we can configure dev | qa | prod differently if needed
  */}}
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: {{ $component_name }}:latest
  restart: always
  environment:
    {{- /*
      # local | dev | qa | prod
    */}}
    NODE_ENV: 'local'
    POSTGRES_DB_HOST: postgres
    POSTGRES_DB_PORT: 5432
    POSTGRES_DB_USER: {{ .Values.auth.username }}
    POSTGRES_DB_PASSWORD: {{ .Values.auth.password }}
    POSTGRES_DB_NAME: snitch_db
    REDIS_DB_HOST: cache
    REDIS_DB_PORT: 6379
    REDIS_DB_PASSWORD: {{.Values.auth.password}}
  volumes:
    - "./volumes/{{ $component_name }}/src:/app/src"
    - "./volumes/{{ $component_name }}/nodemon.json:/app/nodemon.json"
    - "./volumes/{{ $component_name }}/server.js:/app/server.js"
  labels:
    - "com.docker.compose.service=private"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=apis"
  expose:
    - '3000'
  ports:
    - '3000:3000'
  command: npm run local
  {{- $depends_on }}
{{- end }}
