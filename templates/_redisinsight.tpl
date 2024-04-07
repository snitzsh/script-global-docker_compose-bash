{{- /*
https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.
  expose:
    - "8001"
*/}}

{{- define "redisinsight" -}}
{{- $component_name := "redisinsight" -}}
{{- $depends_on := include "docker-compose.functions.depends_on" (dict "global" .Values "depends_on" (list "redis")) }}
{{- $networks := include "docker-compose.functions.networks" (dict "global" .Values "networks" (list "redis") "data_type" "array") -}}
redisinsight:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "redislabs/{{ $component_name }}:latest"
  restart: always
  environment: {}
  volumes:
    - "./volumes/{{ $component_name }}:/db"
  labels:
    - "com.docker.compose.service=public"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=in-memory-data-storage-ui"
  ports:
    - 5540:5540
  {{- $networks | indent 2 }}
  {{- $depends_on | indent 2 }}
{{- end }}
