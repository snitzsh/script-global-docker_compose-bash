{{- /*
Docs:
  - https://github.com/redis/redis/blob/unstable/redis.conf
  - https://www.docker.com/blog/how-to-use-the-redis-docker-official-image/

TODO:
  - Support configs volume.
*/}}
{{- define "redis" -}}
{{- $component_name := "redis" -}}
redis:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "{{ $component_name }}:latest"
  restart: always
  environment:
    REDIS_USERNAME: {{ .Values.auth.username }}
  volumes:
    - "./volumes/{{ $component_name }}/data:/data"
    {{- /*
      - "./configs/{{ $component_name }}/config:/user/local/etc/redis"
    */}}
  labels:
    - "com.docker.compose.service=public"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=in-memory-data-storage"
  expose:
    - "6379"
  ports:
    - "6379:6379"
  command: redis-server --save 20 1 --loglevel warning --requirepass {{ .Values.auth.password }}
  networks:
    - redis
{{- end }}
