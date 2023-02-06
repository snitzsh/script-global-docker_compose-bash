{{- define "postgres" -}}
postgres:
  container_name: postgres
  image: postgres
  restart: always
  environment:
    - POSTGRES_USER={{ .Values.auth.username }}
    - POSTGRES_PASSWORD={{ .Values.auth.password }}
    - POSTGRES_DB="snitch_db"
  expose:
    - "5432"
  ports:
    - "5432:5432"
  volumes:
    - ./postgres/data:/var/lib/postgresql/data
    - ./postgres/init.sql:/docker-entrypoint-initdb.d/create_tables.sql
{{- end }}
