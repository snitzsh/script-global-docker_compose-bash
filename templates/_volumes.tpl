{{- define "volumes" -}}
volumes:
  postgres:
    driver: local
  redis:
    driver: local
  redisinsight:
    driver: local
{{- end }}