{{- define "redis" -}}
redis:
  container_name: redis
  image: redis:7.0.4-alpine
  restart: always
  ports:
    - '6379:6379'
  command: redis-server --save 20 1 --loglevel warning --requirepass eYVX7EwVmmxKPCDmwMtyKVge8oLd2t81
  volumes:
    - redis:/data
{{- end }}