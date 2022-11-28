{{/*
Expand the name of the chart.
*/}}
{{- define "sgw.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sgw.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "sgw.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "sgw.labels" -}}
helm.sh/chart: {{ include "sgw.chart" . }}
{{ include "sgw.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "sgw.selectorLabels" -}}
app.kubernetes.io/name: {{ include "sgw.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Replicas
*/}}
{{- define "sgw.replicas" -}}
{{- if or (.Values.replicaCount) (eq (toString .Values.replicaCount) "0") }}
replicas: {{ .Values.replicaCount }}
{{- end }}
{{- end }}

{{/*
envValues
use | indent 12
*/}}
{{- define "sgw.envValues" -}}
{{- $top := first . }}
{{- $env := index . 1 }}
{{- $totalDict := dict }}
{{- $_ := mergeOverwrite $totalDict $top.Values.envPlain }}
{{- include "sgw.addNewEnvValues" (list $totalDict $top.Values.env) }}
{{- include "sgw.addNewEnvValues" (list $totalDict $env.env) }}
{{- range $key, $value := $totalDict }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
{{- end }}

{{- define "sgw.addNewEnvValues" -}}
{{- $totalDict := index . 0 }}
{{- $envObjectList := index . 1 }}
{{- range $pair := $envObjectList }}
{{- if (not (hasKey $totalDict $pair.name)) }}
{{- $_ := set $totalDict $pair.name $pair.value }}
{{- end }}
{{- end }}
{{- end }}
