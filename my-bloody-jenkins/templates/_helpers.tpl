{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "my-bloody-jenkins.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "my-bloody-jenkins.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "my-bloody-jenkins.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create pvc claim names
*/}}
{{- define "my-bloody-jenkins.jenkinsHome.claimName" -}}
{{- printf "%s-jenkins-home" (include "my-bloody-jenkins.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-bloody-jenkins.jenkinsWorkspace.claimName" -}}
{{- printf "%s-jenkins-workspace" (include "my-bloody-jenkins.fullname" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Define default values
*/}}
{{- define "my-bloody-jenkins.httpPort" -}}
{{- 8080 -}}
{{- end -}}

{{- define "my-bloody-jenkins.jnlpPort" -}}
{{- 50000 -}}
{{- end -}}

{{- define "my-bloody-jenkins.sshdPort" -}}
{{- 16022 -}}
{{- end -}}

{{- define "my-bloody-jenkins.persistentVolumeClaimName" -}}
{{- .Values.persistenceExistingClaim | default (include "my-bloody-jenkins.fullname" .) -}}
{{- end -}}

{{- define "my-bloody-jenkins.tlsSecretName" -}}
{{- printf "%s-tls-secret" (include "my-bloody-jenkins.fullname" .) -}}
{{- end -}}
