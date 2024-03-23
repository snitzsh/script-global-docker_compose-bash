
{{- /*
https://collabnix.com/running-redisinsight-using-docker-compose/#:~:text=RedisInsight%20is%20an%20intuitive%20and,Docker%20container%20and%20Kubernetes%20Pods.
  expose:
    - "8001"
*/}}
{{- define "redisinsight" -}}
redisinsight:
  container_name: redisinsight
  hostname: redisinsight
  image: redislabs/redisinsight:latest
  ports:
    - 5540:5540
  volumes:
    - ./volumes/redisinsight:/db
  networks:
    - redis
  depends_on:
    - redis
{{- end }}