{{- define "pgadmin4" -}}
pgadmin4:
  container_name: pgadmin4
  image: dpage/pgadmin4
  restart: always
  environment:
    - PGADMIN_DEFAULT_EMAIL={{ .Values.auth.email }}
    - PGADMIN_DEFAULT_PASSWORD={{ .Values.auth.password }}
  expose:
    - '80'
  ports:
    - '5050:80'
  volumes:
    - ./volumes/pgadmin4:/var/lib/pgadmin
  links:
    - postgres
  depends_on:
    - postgres
{{- end }}
