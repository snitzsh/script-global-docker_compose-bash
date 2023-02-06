{{- define "websiteVue" -}}
website_vue:
  container_name: website-vue
  image: website-vue:latest
  restart: always
  stdin_open: true
  tty: true
  environment:
    - HOST=0.0.0.0
    - CHOKIDAR_USEPOLLING=true
  volumes:
    # - ../website-vue/:/app
    - ../website-vue/src:/app/src
    - ../website-vue/package.json:/app/package.json
  expose:
    - "80"
  ports:
    - "8080:80"
  # -- --public 0.0.0.0:8080
  command: npm run serve
{{- end }}
