{{/*
Expand the name of the chart.
*/}}
{{- define "spacebar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "spacebar.fullname" -}}
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
{{- define "spacebar.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "spacebar.labels" -}}
helm.sh/chart: {{ include "spacebar.chart" . }}
{{ include "spacebar.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "spacebar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "spacebar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Public API endpoint (for config).
*/}}
{{- define "spacebar.apiEndpointPublic" -}}
{{- if .Values.config.apiEndpointPublic }}
{{- .Values.config.apiEndpointPublic }}
{{- else if .Values.ingress.tls }}
{{- printf "https://%s/api/v9" (index .Values.ingress.tls 0).hosts | first }}
{{- else }}
{{- printf "http://%s/api/v9" .Values.ingress.host }}
{{- end }}
{{- end }}

{{/*
Public CDN endpoint (for config).
*/}}
{{- define "spacebar.cdnEndpointPublic" -}}
{{- if .Values.config.cdnEndpointPublic }}
{{- .Values.config.cdnEndpointPublic }}
{{- else if .Values.ingress.tls }}
{{- printf "https://%s" (index .Values.ingress.tls 0).hosts | first }}
{{- else }}
{{- printf "http://%s" .Values.ingress.host }}
{{- end }}
{{- end }}

{{/*
Public Gateway endpoint (for config).
*/}}
{{- define "spacebar.gatewayEndpointPublic" -}}
{{- if .Values.config.gatewayEndpointPublic }}
{{- .Values.config.gatewayEndpointPublic }}
{{- else if .Values.ingress.tls }}
{{- printf "wss://%s" (index .Values.ingress.tls 0).hosts | first }}
{{- else }}
{{- printf "ws://%s" .Values.ingress.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL Cluster name (for CNPG).
*/}}
{{- define "spacebar.pgClusterName" -}}
{{- include "spacebar.fullname" . }}-pg
{{- end }}
