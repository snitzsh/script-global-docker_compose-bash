{{- define "postgres" -}}
postgres:
  container_name: postgres
  image: postgres:14.5-alpine
  restart: always
  environment:
    - POSTGRES_USER=postgres
    - POSTGRES_PASSWORD=postgres
  ports:
    - '5432:5432'
  volumes:
    - postgres:/var/lib/postgresql/data
    - ./postgres/init.sql:/docker-entrypoint-initdb.d/create_tables.sql
{{- end }}
