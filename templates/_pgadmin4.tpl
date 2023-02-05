{{- define "pgadmin4" -}}
pgadmin4:
  container_name: postgres-ui
  image: dpage/pgadmin4
  restart: always
  environment:
    - PGADMIN_DEFAULT_EMAIL=user@domain.com
    - PGADMIN_DEFAULT_PASSWORD=secret
  expose:
    - '80'
  ports:
    - '3001:80'
  links:
    - postgres
  depends_on:
    - postgres
{{- end }}
