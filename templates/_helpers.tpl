{{- /*
TODO:
  - null

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
  {{- $components := .Values.components -}}
  {{- $public := $components.public -}}
  {{- $private := $components.private -}}
  {{- range $apps }}
    {{- $app_name := . -}}
    {{- /* loops: public, private */}}
    {{- range $software_type, $software_type_components := $components }}
      {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
      {{- range $component_type, $component_type_obj := $software_type_components }}
        {{- range $component_name, $component_configs := $component_type_obj }}
          {{- if $component_configs.enabled }}
            {{- include $component_name (
                  dict
                    "globals" $
                    "app_name" $app_name
                    "software_type" $software_type
                    "component_type" $component_type
                    "component_name" $component_name
                    "component_configs" $component_configs
                ) | nindent 2
            }}
          {{- end }}
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
*/}}
{{- define "docker-compose.functions.depends_on" -}}
  {{- $global := .global }}
  {{- $components := $global.components }}
  {{- $depends_on := .depends_on }}
  {{- $obj := dict "depends_on" (list) }}

  {{- if gt (len $depends_on) 0 }}
    {{- range $item := $depends_on }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_components := $components }}
        {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
        {{- range $component_type, $component_type_obj := $software_type_components }}
          {{- range $component_name, $component_configs := $component_type_obj }}
            {{- if and ($component_configs.enabled) (eq $item $component_name) }}
              {{- $obj = merge $obj (
                    dict
                      "depends_on" (append $obj.depends_on $component_name)
                  )
              -}}
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
*/}}
{{- define "docker-compose.functions.volumes" -}}
  {{- $global := .global }}
  {{- $components := $global.components }}
  {{- $volumes := dict "volumes" (dict) }}

  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_components := $components }}
    {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
    {{- range $component_type, $component_type_obj := $software_type_components }}
      {{- range $component_name, $component_configs := $component_type_obj }}
        {{- if $component_configs.enabled }}
          {{- $volume :=  dict $component_name (dict "driver" "local") }}
          {{- $volumes = merge $volumes (dict "volumes" $volume) }}
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
*/}}
{{- define "docker-compose.functions.networks" -}}
  {{- $global := .global }}
  {{- $components := $global.components }}
  {{- $networks := .networks }}
  {{- $data_type := .data_type }}
  {{- $obj := dict "networks" (dict) }}

  {{- if gt (len $networks) 0 }}
    {{- range $item := $networks }}
      {{- /* loops: public, private */}}
      {{- range $software_type, $software_type_components := $components }}
        {{- /* loops: dbs, db-uis, apis, uis, etc. */}}
        {{- range $component_type, $component_type_obj := $software_type_components }}
          {{- range $component_name, $component_configs := $component_type_obj }}
            {{- if and ($component_configs.enabled) (eq $item $component_name) }}
              {{- $network :=  dict $component_name (dict "driver" "bridge") }}
              {{- $obj = merge $obj (dict "networks" $network) }}
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
  {{- $globals := .globals  -}}
  {{- $app_name := .app_name  -}}
  {{- $software_type := .software_type -}}
  {{- $component_type := .component_type -}}
  {{- $component_name := .component_name -}}
  {{- $values := $globals.Values -}}
  {{- $service_name := printf "%s-%s-%s" $component_type $app_name $component_name -}}
  {{- $image_env := index $values $service_name -}}
  {{- $platform := $values.platform -}}
  {{- $domain := "com.docker.compose" -}}
  {{- $labels := list
        (printf "%s.app-name=%s" $domain $app_name)
        (printf "%s.software-type=%s" $domain $software_type)
        (printf "%s.component-type=%s" $domain $component_type)
        (printf "%s.service-name=%s" $domain $service_name)
        (printf "%s.platform=%s" $domain $platform)
  -}}
  {{- if eq $software_type "private" -}}
    {{- $private_labels := list
          (printf "%s.docker-stage=%s" $domain $image_env.target)
          (printf "%s.target-script=%s" $domain $image_env.target_script)
    -}}
    {{- $labels = concat $labels $private_labels -}}
  {{- end -}}

labels:
  {{- $labels | toYaml | nindent 2 }}
{{- end }}
