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
      {{- range $key, $value := $components }}
        {{- if and ($value) (eq $item $key) }}
        {{- $obj = merge $obj (dict "depends_on" (append $obj.depends_on $key)) }}
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
  {{- range $key, $value := $components }}
    {{- if $value }}
      {{- $volume :=  dict $key (dict "driver" "local") }}
      {{- $volumes = merge $volumes (dict "volumes" $volume) }}
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
      {{- range $key, $value := $components }}
        {{- if and ($value) (eq $item $key) }}
          {{- $network :=  dict $key (dict "driver" "bridge") }}
          {{- $obj = merge $obj (dict "networks" $network) }}
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
