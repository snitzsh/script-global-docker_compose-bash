{{- define "volumes" -}}
volumes:
  postgres:
    driver: local
  redis:
    driver: local
{{- end }}