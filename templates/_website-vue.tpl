{{- define "websiteVue" -}}
{{- $component_name := "website-vue" -}}
website_vue:
  container_name: {{ $component_name }}
  image: "{{ $component_name }}:latest"
  restart: always
  environment: {}
  {{- /*
    stdin_open: true
    tty: true
    environment:
      - HOST=0.0.0.0:3000
      - CHOKIDAR_USEPOLLING=true
  */}}
  volumes:
    {{- /*
      - ../website-vue/:/app
    */}}
    - "./volumes/{{ $component_name }}/src:/app/src"
    - "./volumes/{{ $component_name }}/package.json:/app/package.json"
  labels:
    - "com.docker.compose.service=private"
    - "com.docker.compose.component-name={{ $component_name }}"
    - "com.docker.compose.component-type=ui"
  expose:
    - "8080"
  ports:
    - "8080:8080"
  {{- /*
    -- --public 0.0.0.0:8080
  */}}
  command: npm run serve
{{- end }}
