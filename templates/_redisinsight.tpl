
{{- /*
https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.
*/}}
{{- define "redisinsight" -}}
redisinsight:
  image: redislabs/redisinsight:latest
  expose:
    - "8001"
  ports:
    - '8001:8001'
  volumes:
    - ./volumes/redisinsight:/db
  links:
    - redis
  depends_on:
    - redis
{{- end }}
