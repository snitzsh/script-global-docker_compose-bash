# https://github.com/redis/redis/blob/unstable/redis.conf
# https://www.docker.com/blog/how-to-use-the-redis-docker-official-image/
{{- define "redis" -}}
redis:
  container_name: redis
  image: redis
  restart: always
  expose:
    - "6379"
  ports:
    - "6379:6379"
  command: redis-server --save 20 1 --loglevel warning --requirepass {{ .Values.auth.password }}
  volumes:
    - ./volumes/redis/data:/data
    # - ./redis/config:/user/local/etc/redis
{{- end }}
