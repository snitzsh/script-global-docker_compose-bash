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
{{- define "docker-compose.functions.services" -}}
  {{- $apps := .Values.apps -}}
  {{- $merge_apps := .Values.merge_apps -}}
  {{- $default_app_name := .Values.default_app_name -}}
  {{- $image_only := .Values.image_only -}}
  {{- $components := .Values.components -}}
  {{- $docker := .Values.docker -}}
  {{- $all_app_services := dict -}}
  {{- $merged_app_services := dict -}}
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
        {{- /* loops: projects */}}
        {{- range $project_name, $project_obj := $app_obj }}
          {{- if $project_obj.enabled }}
            {{- $app_services = merge $app_services (
                  include $project_name (
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
  {{- /* Multiple apps on its own docker image */}}
  {{- if not $merge_apps }}
    {{- range $key, $services := $all_app_services }}
name: {{ $key }}
services:
  {{- $services | toYaml | nindent 2 }}
      {{- if not $image_only }}
        {{- if $docker.volumes }}
{{- include "volumes" $ }}
        {{- end }}
        {{- if $docker.networks }}
{{- include "networks" (dict "globals" $ "service_name" (first (keys $services) )) }}
        {{- end }}
      {{- end }}
---
    {{- end }}
  {{- /* Merged multiple apps. */}}
  {{- else }}
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
{{- include "volumes" $ }}
        {{- end }}
        {{- if $docker.networks }}
{{- include "networks" (dict "globals" $ "service_name" "all") }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}

{{- /*
TODO:
  - find out how to return `depends_on: []` without needing to indent when
    calling the function.

NOTE:
  - Read `IMPORTANT` comment (inside the function) to prevent issues.

DESCRIPTION:
  - Handles `depends_on` for a component.

ARGS:
  - $global = .Values
  - $depends_on = [..., component_1, component_2, ...]

RETURN:
  - `{ depends_on: [ ..., component_1, component_2, ... ] }` or `Null`

OUTPUT EXAMPLE:
depends_on:
- dbs-snitzsh-postgres
*/}}
{{- define "docker-compose.functions.depends_on" -}}
  {{- $global := .global -}}
  {{- $components := $global.components -}}
  {{- $app_name := .app_name -}}
  {{- $depends_on := .depends_on -}}
  {{- $obj := dict "depends_on" (list) -}}

  {{- if gt (len $depends_on) 0 }}
    {{- range $item := $depends_on }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_obj := $components }}
        {{- /* loops components (inside components main_object) */}}
        {{- range $component_name, $component_obj := $software_type_obj }}
          {{- /* loops apps */}}
          {{- range $app_name, $app_obj := $component_obj }}
            {{- /* loops: projects */}}
            {{- range $project_name, $project_obj := $app_obj }}
              {{- if and ($project_obj.enabled) (eq $item $project_name) }}
                {{- $obj = merge $obj (
                      dict
                        "depends_on" (
                          append $obj.depends_on (
                            printf "%s-%s-%s" $component_name $app_name $project_name
                          )
                        )
                    )
                -}}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- /*
  IMPORTANT:
    - Do not indent the below code. You must assign it to a variable when calling
      the function, else indent.
  */}}
  {{- if gt (len $obj.depends_on) 0 }}
{{ $obj | toYaml }}
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
  {{- $global := .global -}}
  {{- $components := $global.components -}}
  {{- $apps := $global.apps -}}
  {{- $volumes := dict "volumes" (dict) -}}

  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_obj := $components }}
    {{- /* loops components (inside components main_object) */}}
    {{- range $component_name, $component_obj := $software_type_obj }}
      {{- /* loops apps */}}
      {{- range $app_name, $app_obj := $component_obj }}
        {{- /* loops: projects */}}
        {{- range $project_name, $project_obj := $app_obj }}
          {{- if $project_obj.enabled }}
            {{- $volume :=  dict
                  (printf "%s-%s-%s" $component_name $app_name $project_name) (dict "driver" "local")
            -}}
            {{- $volumes = merge $volumes (
                  dict "volumes" $volume
                )
            -}}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- if gt (len (keys $volumes.volumes)) 0 }}
{{ $volumes | toYaml }}
  {{- end }}
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
  - $global = .Values

RETURN:
  - `{volumes: {component-name: driver: <[name]> }}` or `Null`

OUTPUT EXAMPLE:
  networks:
    cache-dbs-snitzsh-redis:
      driver: bridge
    dbs-snitzsh-postgres:
      driver: bridge
*/}}
{{- define "docker-compose.functions.networks" -}}
  {{- /* args */}}
  {{- $global := .global -}}
  {{- $networks := .networks -}}
  {{- $data_type := .data_type -}}
  {{- $service_name := .service_name -}}
  {{- /* local variables */}}
  {{- $apps := $global.apps -}}
  {{- $components := $global.components -}}
  {{- $obj := dict "networks" (dict) -}}

  {{- if gt (len $networks) 0 }}
    {{- range $item := $networks }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_obj := $components }}
        {{- /* loops components (inside components main_object) */}}
        {{- range $component_name, $component_obj := $software_type_obj }}
          {{- /* loops apps */}}
          {{- range $app_name, $app_obj := $component_obj }}
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

  {{- if gt (len (keys $obj.networks)) 0 }}
    {{- if eq $data_type "object" }}
      {{ if not (eq $service_name "all") }}
      {{- end }}
{{ $obj | toYaml }}
    {{- else if eq $data_type "array" }}
      {{- $arr := keys $obj.networks }}
      {{- $obj = dict "networks" $arr }}
{{ $obj | toYaml }}
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
  {{- $globals := .globals -}}
  {{- $software_type := .software_type -}}
  {{- $component_name := .component_name -}}
  {{- $app_name := .app_name -}}
  {{- $project_name := .project_name -}}
  {{- $project_obj := .project_obj }}
  {{- /* globals */}}
  {{- $values := $globals.Values -}}
  {{- $platform := $values.platform -}}
  {{- $domain := $values.domain -}}

  {{- /* local variables */}}
  {{- $service_name := printf "%s-%s-%s" $component_name $app_name $project_name -}}
  {{- $labels := list
        (printf "%s.software-type=%s" $domain $software_type)
        (printf "%s.component-name=%s" $domain $component_name)
        (printf "%s.app-name=%s" $domain $app_name)
        (printf "%s.project-name=%s" $domain $project_name)
        (printf "%s.service-name=%s" $domain $service_name)
        (printf "%s.platform=%s" $domain $platform)
  -}}
  {{- if eq $software_type "private" -}}
    {{- /*
      TODO:
        - Do we need to implement .env[cluster_type & cluster_cluster] labels?
    */}}
    {{- $private_labels := list
          (printf "%s.docker-stage=%s" $domain $project_obj.target)
          (printf "%s.target-script=%s" $domain $project_obj.target_script)
    -}}
    {{- $labels = concat $labels $private_labels -}}
  {{- end -}}

labels:
  {{- $labels | toYaml | nindent 2 }}
{{- end }}
