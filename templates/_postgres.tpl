{{- define "postgres" -}}
postgres:
  container_name: postgres
  hostname: postgres
  image: postgres:latest
  restart: always
  environment:
    POSTGRES_USER: {{ .Values.auth.username }}
    POSTGRES_PASSWORD: {{ .Values.auth.password }}
    {{- /*
      IMPORTANT:
        - Do not quote the database, else it will think it does not exist when ssh
          it thinks "snitzsh_db" instead of snitch

      POSTGRES_DB: snitzsh_db
    */}}
    POSTGRES_DB: snitzsh_db
  expose:
    - "5432"
  ports:
    - "5432:5432"
  volumes:
    - ./volumes/postgres/data:/var/lib/postgresql/data
    {{- /*
      NOTE:
      - use thi belog item to point to our own configurations. in ./configs
    - ./configs/postgres/postgresql.conf:/etc/postgresql/postgresql.conf
    */}}
    - ./volumes/postgres/init.sql:/docker-entrypoint-initdb.d/create_tables.sql
  networks:
    - postgres
{{- end }}
