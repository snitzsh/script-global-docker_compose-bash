{{- define "volumes" -}}
volumes:
  apis-fastify:
    driver: local
  apis-rust:
    driver: local
  grafana:
    driver: local
  pgadmin4:
    driver: local
  postgres:
    driver: local
  redis:
    driver: local
  redisinsight:
    driver: local
  website-vue:
    driver: local
{{- end }}
