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
  - null
*/}}
{{- define "docker-compose.functions.apps" -}}
{{- end }}

{{- define "docker-compose.functions.services" -}}
  {{- $globals := . }}
  {{- $values := $globals.Values}}
  {{- $apps := $values.apps }}
  {{- $merge_apps := $values.merge_apps }}
  {{- $default_app_name := $values.default_app_name }}
  {{- $image_only := $values.image_only }}
  {{- $components := $values.components }}
  {{- $docker := $values.docker }}
  {{- $services_per_app := dict }}
  {{- $merged_app_services := dict }}

  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_obj := $components }}
    {{- /* loops components (inside components main_object) */}}
    {{- range $utility_name, $utility_obj := $software_type_obj }}
      {{- $app_services := dict }}
      {{- /* loops: apps */}}
      {{- range $app_name, $app_obj := $utility_obj }}
        {{- if has $app_name $apps }}
          {{- /* loops: projects */}}
          {{- range $project_name, $project_obj := $app_obj }}
            {{- if $project_obj.enabled }}
              {{- /* creates key/obj: { app_1: {}, app_2: {}} */}}
              {{- if not (hasKey $services_per_app $app_name) }}
                {{- $services_per_app = set $services_per_app $app_name dict }}
              {{- end }}

              {{- $app_yaml := include (printf "%s.%s" $globals.Chart.Name $project_name) (
                    dict
                      "globals" $globals
                      "software_type" $software_type
                      "component_name" $utility_name
                      "app_name" $app_name
                      "project_name" $project_name
                      "project_obj" $project_obj
                  ) | fromYaml
              }}

              {{- $app_services = merge $app_services $app_yaml }}
              {{- if hasKey $services_per_app $app_name }}
                {{- $service_per_app_2 := get $services_per_app $app_name }}
                {{- range $key_name, $item := $app_yaml }}
                {{- $service_per_app_2 = set $service_per_app_2 $key_name $item }}
                {{- end }}
              {{- end }}

              {{- $merged_app_services = merge $merged_app_services $app_services }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- /* Merged multiple apps. */}}
  {{- if $merge_apps }}
    {{- if gt (len $merged_app_services) 0 }}
name: {{ $default_app_name }}
services:
{{- $merged_app_services | toYaml | nindent 2 }}
      {{- if not $image_only }}
        {{- if $docker.volumes }}
{{- include "docker-compose.volumes" (
      dict
        "globals" $globals
        "services_name" (keys $merged_app_services)
    ) | fromJson | toYaml | nindent 0
}}
        {{- end }}
        {{- if $docker.networks }}
{{- include "docker-compose.functions.normalize-networks" (
      dict
        "globals" $
        "data_type" "dict"
    ) | fromJson | toYaml | nindent 0
}}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- /* Multiple apps on its own docker image */}}
  {{- else }}
    {{- range $app_name_2, $app_services_2 := $services_per_app }}
name: {{ $app_name_2 }}
services:
{{- $app_services_2 | toYaml | nindent 2 }}
      {{- if not $image_only }}
        {{- if $docker.volumes }}

{{- include "docker-compose.volumes" (
      dict
        "globals" $globals
        "services_name" (keys $app_services_2)
    ) | fromJson | toYaml | nindent 0
}}
        {{- end }}
        {{- if $docker.networks }}
{{- include "docker-compose.functions.normalize-networks" (
      dict
        "globals" $
        "app_name" $app_name_2
        "data_type" "dict"
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
{"depends_on": [..., "b-c-d",...]}

*/}}
{{- define "docker-compose.functions.depends-on" -}}
  {{- $globals := .globals }}
  {{- $values := $globals.Values }}
  {{- $apps := $values.apps }}
  {{- $depends_on := default list .depends_on }}
  {{- $obj := dict "depends_on" (list) }}
  {{- if gt (len $depends_on) 0 }}
    {{- range $_, $item := $depends_on }}
      {{- $splitted := split "." $item }}
      {{- $software_type := default "<[project_type_placeholder]>" $splitted._0 }}
      {{- $utility_name := default "<[utility_name_placeholder]>" $splitted._1 }}
      {{- $app_name := default "<[app_name_placeholder]>" $splitted._2 }}
      {{- $project_name := default "<[project_name_placeholder]>" $splitted._3 }}
      {{- $dependency := (
            dict
              "software_type" $software_type
              "utility_name" $utility_name
              "app_name" $app_name
              "project_name" $project_name
          )
      }}
      {{- if has $app_name $apps }}
        {{- $is_found := include "docker-compose.functions.project-exist" (
              dict
                "globals" $globals
                "dependency" $dependency
            ) | fromJson
        }}
          {{- $obj = merge $obj (
                dict
                  "depends_on" (
                    append $obj.depends_on (
                      printf "%s-%s-%s" $utility_name $app_name $project_name
                    )
                  )
              )
          }}
        {{- if $is_found.found }}
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
  - checks if a service's depends on are enabled. if enabled it returns
    `.found=true`, else `.found=true`.

ARGS:
  - global     : dict
  - dependency : dict

RETURN:
  - dict

OUTPUT
  - {found: (true | false)}

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

{{- /*
TODO:
  - null

NOTE:
  - null

DESCRIPTION:
  - Creates a `volume` for a component.

ARGS:
  - $global
      data-type   : dict
      description : helm's global dict
      example: {.<[values.yaml's object]>}
  - $services_name  : list  : list of names of each service name 

RETURN:
  - `{volumes: {<[component-name]>: driver: <[name]> }}`

OUTPUT EXAMPLE:
  volumes:
    cache-db-uis-<[app_name]>-<image_name>:
      driver: local
*/}}
{{- define "docker-compose.functions.volumes" -}}
  {{- $globals := .globals }}
  {{- $services_name := .services_name }}
  {{- $values := $globals.Values }}
  {{- $components := $values.components }}
  {{- $volumes := dict "volumes" (dict) }}
  {{- /* loops: public, private */}}
  {{- range $software_type, $software_type_obj := $components }}
    {{- /* loops components (inside components main_object) */}}
    {{- range $utility_name, $utility_obj := $software_type_obj }}
      {{- /* loops apps */}}
      {{- range $app_name, $app_obj := $utility_obj }}
        {{- /* loops: projects */}}
        {{- range $project_name, $project_obj := $app_obj }}
          {{- $service_name := printf "%s-%s-%s" $utility_name $app_name $project_name }}
          {{- if has $service_name $services_name }}
            {{- if $project_obj.enabled }}
              {{- $volume := dict
                    $service_name (
                      dict
                        "driver" "local"
                    )
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
  {{ $volumes | toJson }}
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
  - Returns 2 different outpus depending on data_type
    1) When data_type is dict, it creates a `network` per app if
      `merge_apps=true` else, it creates a single network for all apps.
    2) When data_type is list it create list of service nerwork(s).

ARGS:
  - $global: dict
  - networks: list
  - data_type: string
  - service_name: string

RETURN:
  - dict | list

OUTPUT EXAMPLE:
  data_type = dict
  {"networks":{"cache-dbs-snitzsh-redis": {"driver": bridge}}}

  data_type = list
  [dbcache-dbs-snitzsh-redis]
*/}}
{{- define "docker-compose.functions.normalize-networks" -}}
  {{- $globals := .globals }}
  {{- $values := $globals.Values }}
  {{- $apps := $values.apps }}
  {{- $merge_apps := $values.merge_apps }}
  {{- $default_app_name := $values.default_app_name }}
  {{- $app_name_2 := default nil .app_name }}
  {{- $obj := dict "networks" (dict) }}
  {{- $data_type := default "list" .data_type }}
  {{- if $merge_apps }}
    {{- $network :=  dict
        (printf "%s" $default_app_name ) (dict "driver" "bridge")
    }}
    {{- $obj = merge $obj (
          dict
            "networks" $network
        )
    }}
  {{- else }}
    {{- range $_, $app_name := $apps }}
      {{- if eq $app_name $app_name_2  }}
        {{- $network :=  dict
            (printf "%s" $app_name) (dict "driver" "bridge")
        }}
        {{- $obj = merge $obj (
              dict
                "networks" $network
            )
        }}
      {{- end }}
    {{- end }}
  {{- end }}

  {{- if gt (len (keys $obj.networks)) 0 }}
    {{- if eq $data_type "dict" }}
      {{ $obj | toJson }}
    {{- else if eq $data_type "list" }}
      {{- /**/}}
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
