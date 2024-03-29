{{- /*
  References:
  - https://medium.com/swlh/easy-grafana-and-docker-compose-setup-d0f6f9fcec13
  - https://medium.com/javarevisited/monitoring-setup-with-docker-compose-part-2-grafana-2cd2d9ff017b
  - https://www.theairtips.com/post/optimize-promql-and-metricsql-queries
  - https://prometheus.io/docs/prometheus/latest/installation/
  - https://logz.io/blog/prometheus-tutorial-docker-monitoring/#exporters
*/}}
{{- /*
  build:
    context: ./grafana
*/}}
{{- /*
  NOTE:
    - Added /grafana/profisioning/datasouces/prometheus_ds.yml manually.

  Username: admin
  Password: password
  TODO:
    - findout if we can pass a config file: https://grafana.com/docs/grafana/latest/setup-grafana/configure-grafana/#security
*/}}
{{- define "grafana" -}}
{{- $component_name := "grafana" -}}
grafana:
  container_name: {{ $component_name }}
  hostname: {{ $component_name }}
  image: "grafana/{{ $component_name }}:latest"
  restart: unless-stopped
  environments: {}
  volumes:
    - "./volumes/{{ $component_name }}/data:/var/lib/grafana"
    - "./volumes/{{ $component_name }}/provisioning/datasources:/etc/grafana/provisioning/datasources"
  labels:
    - "com.docker.compose.service=public"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=monitor"
  ports:
    - 9000:3000
{{- end }}
