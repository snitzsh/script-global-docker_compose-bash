{{- define "networks" -}}
networks:
  redis:
    driver: bridge
  postgres:
    driver: bridge
{{- end }}
