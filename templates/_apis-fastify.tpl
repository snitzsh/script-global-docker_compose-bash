{{- define "apisFastify" -}}
apis:
  # build:
  #   context: . # Directory of where the docker file is.
  #   dockerfile: Dockerfile # name of the docker file
  #   target: base # look at the Dockerfile for `as local`, that way we can configure dev | qa | prod differently if needed
  container_name: apis-fastify
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
    NODE_ENV: 'local' # local | dev | qa | prod
    DB_HOST: db
    DB_PORT: 5432
    DB_USER: postgres
    DB_PASSWORD: postgres
    DB_NAME: postgres
    REDIS_HOST: cache
    REDIS_PORT: 6379
    REDIS_PASSWORD: eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81
  depends_on:
    - postgres
    - redis
  links:
    - postgres
    - redis
{{- end }}
