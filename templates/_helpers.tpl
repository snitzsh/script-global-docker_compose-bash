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
  {{- $components := .Values.components -}}
  {{- $docker := .Values.docker -}}
  {{- $all_app_services := dict -}}
  {{- $merged_app_services := dict -}}
  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_apps_obj := $components }}
    {{- /* loops applications */}}
    {{- range $software_type_app_name, $software_type_app_obj := $software_type_apps_obj }}
      {{- $app_services := dict }}
      {{- $all_app_services = merge $all_app_services (dict $software_type_app_name dict) }}
      {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
      {{- range $component_type, $software_type_app_project_obj := $software_type_app_obj }}
        {{- range $component_name, $image_configs := $software_type_app_project_obj }}
          {{- if $image_configs.enabled }}
            {{- $app_services = merge $app_services (include $component_name (
                  dict
                    "globals" $
                    "app_name" $software_type_app_name
                    "software_type" $software_type
                    "component_type" $component_type
                    "component_name" $component_name
                    "image_configs" $image_configs
                ) | fromYaml)
            }}
            {{- $all_app_services = merge $all_app_services (dict $software_type_app_name $app_services) }}
            {{- $merged_app_services = merge $merged_app_services (dict $software_type_app_name $app_services) }}
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
      {{- if $docker.volumes }}
{{- include "volumes" $ }}
      {{- end }}
      {{- if $docker.networks }}
{{- include "networks" $ }}
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
      {{- if $docker.volumes }}
{{- include "volumes" $ }}
      {{- end }}
      {{- if $docker.networks }}
{{- include "networks" $ }}
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
      {{- range $software_type, $software_type_apps_obj := $components }}
        {{- /* loops applications */}}
        {{- range $software_type_app_name, $software_type_app_obj := $software_type_apps_obj }}
          {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
          {{- range $component_type, $software_type_app_project_obj := $software_type_app_obj }}
            {{- range $component_name, $image_configs := $software_type_app_project_obj }}
              {{- if and ($image_configs.enabled) (eq $item $component_name) }}
                {{- $obj = merge $obj (
                      dict
                        "depends_on" (append $obj.depends_on (printf "%s-%s-%s" $component_type $software_type_app_name $component_name))
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
  - `{volumes: {component-name: driver: <[name]> }}` or `Null`

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
  {{- range $software_type, $software_type_apps_obj := $components }}
    {{- /* loops applications */}}
    {{- range $software_type_app_name, $software_type_app_obj := $software_type_apps_obj }}
      {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
      {{- range $component_type, $software_type_app_project_obj := $software_type_app_obj }}
        {{- range $component_name, $image_configs := $software_type_app_project_obj }}
          {{- if $image_configs.enabled }}
            {{- $volume :=  dict (printf "%s-%s-%s" $component_type $software_type_app_name $component_name) (dict "driver" "local") -}}
            {{- $volumes = merge $volumes (dict "volumes" $volume) -}}
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
  - null

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
  {{- $global := .global -}}
  {{- $apps := $global.apps -}}
  {{- $components := $global.components -}}
  {{- $networks := .networks -}}
  {{- $data_type := .data_type -}}
  {{- $obj := dict "networks" (dict) -}}

  {{- if gt (len $networks) 0 }}
    {{- range $item := $networks }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_apps_obj := $components }}
        {{- /* loops applications */}}
        {{- range $software_type_app_name, $software_type_app_obj := $software_type_apps_obj }}
          {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
          {{- range $component_type, $software_type_app_project_obj := $software_type_app_obj }}
            {{- range $component_name, $image_configs := $software_type_app_project_obj }}
              {{- if and ($image_configs.enabled) (eq $item $component_name) }}
                {{- $network :=  dict (printf "%s-%s-%s" $component_type $software_type_app_name $component_name) (dict "driver" "bridge") }}
                {{- $obj = merge $obj (dict "networks" $network) }}
              {{- end }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if gt (len (keys $obj.networks)) 0 }}
    {{- if eq $data_type "object" }}
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
  {{- $globals := .globals -}}
  {{- $app_name := .app_name -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $image_configs := .image_configs }}
  {{- $values := $globals.Values -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $platform := $values.platform -}}
  {{- $domain := $values.domain -}}

  {{- $labels := list
        (printf "%s.app-name=%s" $domain $app_name)
        (printf "%s.software-type=%s" $domain $software_type)
        (printf "%s.component-type=%s" $domain $component_type)
        (printf "%s.service-name=%s" $domain $service_name)
        (printf "%s.platform=%s" $domain $platform)
  -}}
  {{- if eq $software_type "private" -}}
    {{- /*
      TODO:
        - Do we need to implement .env[cluster_type & cluster_cluster] labels?
    */}}
    {{- $private_labels := list
          (printf "%s.docker-stage=%s" $domain $image_configs.target)
          (printf "%s.target-script=%s" $domain $image_configs.target_script)
    -}}
    {{- $labels = concat $labels $private_labels -}}
  {{- end -}}

labels:
  {{- $labels | toYaml | nindent 2 }}
{{- end }}
