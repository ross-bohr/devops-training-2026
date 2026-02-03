{{- define "hello-web.name" -}}
hello-web
{{- end -}}

{{- define "hello-web.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "hello-web.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "hello-web.labels" -}}
app.kubernetes.io/name: {{ include "hello-web.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
{{- end -}}
