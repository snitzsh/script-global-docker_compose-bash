{{- define "apisFastify" -}}
apis:
  {{- /*
    # build:
    #   context: . # Directory of where the docker file is.
    #   dockerfile: Dockerfile # name of the docker file
    #   target: base # look at the Dockerfile for `as local`, that way we can configure dev | qa | prod differently if needed
  */}}
  container_name: apis-fastify
  hostname: apis-fastify
  image: apis-fastify:latest
  restart: always
  volumes:
    - ../apis-fastify/src:/app/src
    - ../apis-fastify/nodemon.json:/app/nodemon.json
    - ../apis-fastify/server.js:/app/server.js
  expose:
    - '3000'
  ports:
    - '3000:3000'
  command: npm run local
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
  depends_on:
    - postgres
    - redis
  links:
    - postgres
    - redis
{{- end }}
