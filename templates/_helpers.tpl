{{- /*
TODO:
  - do port generator

NOTE:
  - null

DESCRIPTION:
  - Creates services

ARGS:
  - .

RETURN:
  - `yaml`
*/}}
{{- define "docker-compose.functions.services" }}
  {{- $apps := .Values.apps }}
  {{- $merge_apps := .Values.merge_apps }}
  {{- $default_app_name := .Values.default_app_name }}
  {{- $image_only := .Values.image_only }}
  {{- $components := .Values.components }}
  {{- $docker := .Values.docker }}
  {{- $all_app_services := dict }}
  {{- $merged_app_services := dict }}
  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_obj := $components }}
    {{- /* loops components (inside components main_object) */}}
    {{- range $component_name, $component_obj := $software_type_obj }}
      {{- $app_services := dict }}
      {{- $all_app_services = merge $all_app_services (
            dict
              $component_name dict
          )
      }}
      {{- /* loops: apps */}}
      {{- range $app_name, $app_obj := $component_obj }}
        {{- if has $app_name $apps }}
          {{- /* loops: projects */}}
          {{- range $project_name, $project_obj := $app_obj }}
            {{- if $project_obj.enabled }}
              {{- $app_services = merge $app_services (
                    include (printf "%s.%s" $.Chart.Name $project_name) (
                      dict
                        "globals" $
                        "software_type" $software_type
                        "component_name" $component_name
                        "app_name" $app_name
                        "project_name" $project_name
                        "project_obj" $project_obj
                    ) | fromYaml
                  )
              }}
              {{- $all_app_services = merge $all_app_services (
                    dict
                      $component_name $app_services
                  )
              }}
              {{- $merged_app_services = merge $merged_app_services (
                    dict
                      $component_name $app_services
                  )
              }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- /* Merged multiple apps. */}}
  {{- if $merge_apps }}
    {{- if gt (len $merged_app_services) 0 }}
{{- /*
TODO:
  - If there are NO components enabled for an applications default back to the
    `$app_name` not the `.default_app_name`
*/}}
name: {{ $default_app_name }}
services:
      {{- range $key, $value := $merged_app_services }}
{{- $value | toYaml | nindent 2 }}
      {{- end }}
      {{- if not $image_only }}
        {{- if $docker.volumes }}
{{- include "docker-compose.volumes" $ | fromJson | toYaml | nindent 0 }}
        {{- end }}
        {{- if $docker.networks }}
{{- include "docker-compose.networks" (
      dict
        "globals" $
        "service_name" "all"
    ) | fromJson | toYaml | nindent 0
}}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- /* Multiple apps on its own docker image */}}
  {{- else }}
    {{- range $key, $services := $all_app_services }}
name: {{ $key }}
services:
  {{- $services | toYaml | nindent 2 }}
      {{- if not $image_only }}
        {{- if $docker.volumes }}
{{- include "docker-compose.volumes" $ | fromJson | toYaml | nindent 0 }}
        {{- end }}
        {{- if $docker.networks }}
{{- include "docker-compose.networks" (
      dict
        "globals" $
        "service_name" (first (keys $services))
    ) | fromJson | toYaml | nindent 0
}}
        {{- end }}
      {{- end }}
---
    {{- end }}
  {{- end }}
{{- end }}

{{- /*
TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - Creates a `volume` for a component.

ARGS:
  - $global = .Values

RETURN:
  - `{volumes: {<[component-name]>: driver: <[name]> }}` or `Null`

OUTPUT EXAMPLE:
  volumes:
    cache-db-uis-<[app_name]>-<image_name>:
      driver: local
*/}}
{{- define "docker-compose.functions.volumes" -}}
  {{- $global := .global }}
  {{- $components := $global.components }}
  {{- $apps := $global.apps }}
  {{- $volumes := dict "volumes" (dict) }}
  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_obj := $components }}
    {{- /* loops components (inside components main_object) */}}
    {{- range $component_name, $component_obj := $software_type_obj }}
      {{- /* loops apps */}}
      {{- range $app_name, $app_obj := $component_obj }}
        {{- if has $app_name $apps }}
          {{- /* loops: projects */}}
          {{- range $project_name, $project_obj := $app_obj }}
            {{- if $project_obj.enabled }}
              {{- $volume :=  dict
                    (printf "%s-%s-%s" $component_name $app_name $project_name) (dict "driver" "local")
              }}
              {{- $volumes = merge $volumes (
                    dict "volumes" $volume
                  )
              }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if gt (len (keys $volumes.volumes)) 0 }}
    {{ $volumes | toJson }}
  {{- end }}
{{- end }}

{{- define "docker-compose.functions.normalize-networks" -}}
  
{{- end }}

{{- /*
TODO:
  - Find out how to fix the issue where it creates all volumes when
    `merge_apps=false` it should create a network per
    `<[component_name]-<[app_name]>-<[project_name]>`.
    It already create all when `merge_apps=true`.

NOTE:
  - null

DESCRIPTION:
  - Creates a `networks` for a component.

ARGS:
  - $global: dict
  - networks: list
  - data_type: string
  - service_name: string

RETURN:
  - Json or Yaml or `Null`

OUTPUT EXAMPLE:
  json:
  {"networks":{"cache-dbs-snitzsh-redis": {"driver": bridge}}}
  yaml:
  networks:
  - dbcache-dbs-snitzsh-redis
*/}}
{{- define "docker-compose.functions.networks" -}}
  {{- /* args */}}
  {{- $global := .global }}
  {{- $networks := .networks }}
  {{- $data_type := .data_type }}
  {{- $service_name := .service_name }}
  {{- /* local variables */}}
  {{- $apps := $global.apps }}
  {{- $components := $global.components }}
  {{- $obj := dict "networks" (dict) }}

  {{- if gt (len $networks) 0 }}
    {{- range $item := $networks }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_obj := $components }}
        {{- /* loops components (inside components main_object) */}}
        {{- range $component_name, $component_obj := $software_type_obj }}
          {{- /* loops apps */}}
          {{- range $app_name, $app_obj := $component_obj }}
            {{- if has $app_name $apps }}
              {{- /* loops: projects */}}
              {{- range $project_name, $project_obj := $app_obj }}
                {{- if and ($project_obj.enabled) (eq $item $project_name) }}
                  {{- $network :=  dict
                        (printf "%s-%s-%s" $component_name $app_name $project_name) (dict "driver" "bridge")
                  }}
                  {{- $obj = merge $obj (
                        dict
                          "networks" $network
                      )
                  }}
                {{- end }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if gt (len (keys $obj.networks)) 0 }}
    {{- if eq $data_type "object" }}
      {{- /* TODO: figureout why this if-statement is for */}}
      {{ if not (eq $service_name "all") }}
      {{- end }}
      {{ $obj | toJson }}
    {{- else if eq $data_type "array" }}
      {{- $arr := keys $obj.networks }}
      {{- $obj = dict "networks" $arr }}
      {{ $obj | toJson }}
    {{- end }}
  {{- end }}
{{- end }}

{{- /*
TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - Creates labels for private and public components

ARGS:
  - .

RETURN:
  - `yaml`
*/}}
{{- define "docker-compose.functions.service-labels" -}}
  {{- /* args */}}
  {{- $globals := .globals }}
  {{- $software_type := .software_type }}
  {{- $component_name := .component_name }}
  {{- $app_name := .app_name }}
  {{- $project_name := .project_name }}
  {{- $project_obj := .project_obj }}
  {{- /* globals */}}
  {{- $values := $globals.Values }}
  {{- $platform := $values.platform }}
  {{- $domain := $values.domain }}

  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name }}
  {{- $labels := list
        (printf "%s.software-type=%s" $domain $software_type)
        (printf "%s.component-name=%s" $domain $component_name)
        (printf "%s.app-name=%s" $domain $app_name)
        (printf "%s.project-name=%s" $domain $project_name)
        (printf "%s.service-name=%s" $domain $service_name)
        (printf "%s.platform=%s" $domain $platform)
  }}
  {{- if eq $software_type "private" }}
    {{- /*
      TODO:
        - Do we need to implement .env[cluster_type & cluster_cluster] labels?
    */}}
    {{- $private_labels := list
          (printf "%s.docker-stage=%s" $domain $project_obj.target)
          (printf "%s.target-script=%s" $domain $project_obj.target_script)
    }}
    {{- $labels = concat $labels $private_labels }}
  {{- end }}
  {{ (dict "labels" $labels) | toJson }}
{{- end }}

{{- /*
TODO:
  - null

NOTE:
  - `item.software_type` is not returned as part of string in array's item.

DESCRIPTION:
  - Sanitizes the each item object [..., {"software_type": "a", utility_name: "b", app_name: "c", project_name: "d"}, ...]
    to return [..., "", ...]

ARGS:
  - .globals
  - .depends_on = [{}, {}]

RETURN:
  - array

OUTPUT
[..., "b-c-d",...]

*/}}
{{- define "docker-compose.functions.depends-on" -}}
  {{- $globals := .globals }}
  {{- $values := $globals.values }}
  {{- $apps := $values.apps }}
  {{- $depends_on := default list .depends_on }}
  {{- $obj := dict "depends_on" (list) }}
  {{- if gt (len $depends_on) 0 }}
    {{- range $_, $dependency := $depends_on }}
      {{- $software_type := default "<[project_type_placeholder]>" $dependency.software_type }}
      {{- $utility_name := default "<[utility_name_placeholder]>" $dependency.utility_name }}
      {{- $app_name := default "<[app_name_placeholder]>" $dependency.app_name }}
      {{- if has $app_name $apps }}
        {{- $project_name := default "<[project_name_placeholder]>" $dependency.project_name }}
        {{- $is_found := include "docker-compose.functions.project-exist" (
              dict
                "globals" $globals
                "dependency" $dependency
            ) | fromJson
        }}
        {{- if $is_found.found }}
          {{- $obj = merge $obj (
                dict
                  "depends_on" (
                    append $obj.depends_on (
                      printf "%s-%s-%s" $utility_name $app_name $project_name
                    )
                  )
              )
          }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{ $obj | toJson }}
{{- end }}

{{- /*
TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - null

ARGS:
  - global = {}
  - dependency = {}

RETURN:
  - boolean

OUTPUT
  - true | false
*/}}
{{- define "docker-compose.functions.project-exist" -}}
  {{- $globals := .globals }}
  {{- $values := $globals.Values }}
  {{- $components := $values.components }}
  {{- $dependency := .dependency  }}
  {{- $software_type := $dependency.software_type }}
  {{- $utility_name := $dependency.utility_name }}
  {{- $app_name := $dependency.app_name }}
  {{- $project_name := $dependency.project_name }}
  {{- $found := dict "found" false }}

  {{- $software_exit := hasKey $components $software_type }}
  {{- if $software_exit }}
    {{- $software_obj := get $components $software_type }}
    {{- $utility_exit := hasKey $software_obj $utility_name }}
    {{- if $utility_exit }}
      {{- $utility_obj := get $software_obj $utility_name }}
      {{- $app_exist := hasKey $utility_obj $app_name }}
      {{- if $app_exist }}
        {{- $app_obj := get $utility_obj $app_name }}
        {{- $project_exit := hasKey $app_obj $project_name }}
        {{- if $project_exit }}
          {{- $project_obj := get $app_obj $project_name}}
          {{- $is_enabled := $project_obj.enabled }}
          {{- if $is_enabled }}
            {{- $found = merge $found (
                  dict
                    "found" true
                )
            }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{ $found | toJson }}
{{- end }}