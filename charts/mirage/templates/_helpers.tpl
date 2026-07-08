{{/*
Expand the name of the chart.
*/}}
{{- define "mirage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mirage.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "mirage.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
app.kubernetes.io/name: {{ include "mirage.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/*
Validate that sku, odm and network are one of the supported enum values.
Belt-and-suspenders alongside values.schema.json, since --disable-openapi-validation skips schema checks.
*/}}
{{- define "mirage.validateValues" -}}
{{- $skus := list "a100" "h100" "gb200" "gb300" }}
{{- if not (has .Values.hardware.sku $skus) }}
{{- fail (printf "mirage: values.hardware.sku must be one of %v, got %q" $skus .Values.hardware.sku) }}
{{- end }}
{{- $odms := list "supermicro" "dell" "asus" }}
{{- if not (has .Values.hardware.odm $odms) }}
{{- fail (printf "mirage: values.hardware.odm must be one of %v, got %q" $odms .Values.hardware.odm) }}
{{- end }}
{{- $networks := list "ib" "roce" }}
{{- if not (has .Values.cluster.network $networks) }}
{{- fail (printf "mirage: values.cluster.network must be one of %v, got %q" $networks .Values.cluster.network) }}
{{- end }}
{{- if lt (.Values.cluster.nodeCount | int) 1 }}
{{- fail (printf "mirage: values.cluster.nodeCount must be >= 1, got %v" .Values.cluster.nodeCount) }}
{{- end }}
{{- end }}
