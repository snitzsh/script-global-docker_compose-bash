{{- define "volumes" -}}
volumes:
  postgres:
    driver: local
  redis:
    driver: local
  redisinsight:
    driver: local
  grafana:
    driver: local
{{- end }}