{{- /*
References:
- https://medium.com/swlh/easy-grafana-and-docker-compose-setup-d0f6f9fcec13
- https://medium.com/javarevisited/monitoring-setup-with-docker-compose-part-2-grafana-2cd2d9ff017b
- https://www.theairtips.com/post/optimize-promql-and-metricsql-queries
- https://prometheus.io/docs/prometheus/latest/installation/
- https://logz.io/blog/prometheus-tutorial-docker-monitoring/#exporters
*/ -}}
{{- /*
# build:
#   context: ./grafana
*/ -}}
{{- /*
  NOTE:
    - Added /grafana/profisioning/datasouces/prometheus_ds.yml manually.
*/ -}}
# Username: admin
# Password: password
# TODO:
#   - findout if we can pass a config file: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#security
{{- define "grafana" -}}
grafana:
  container_name: grafana
  image: grafana/grafana
  restart: unless-stopped
  ports:
    - 9000:3000
  volumes:
    - ./grafana/data:/var/lib/grafana
    - ./grafana/provisioning/datasources:/etc/grafana/provisioning/datasources
{{- end }}