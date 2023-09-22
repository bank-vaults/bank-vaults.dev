{{- define "type" -}}
{{- $type := . -}}
{{- if markdownShouldRenderType $type -}}

### {{ $type.Name }}

{{ if $type.IsAlias }}_Underlying type:_ `{{ markdownRenderTypeLink $type.UnderlyingType  }}`{{ end }}

{{ $type.Doc }}

{{ if $type.References -}}
_Appears in:_
{{- range $type.SortedReferences }}
- {{ markdownRenderTypeLink . }}
{{- end }}
{{- end }}

{{ if $type.Members -}}
{{ if $type.GVK -}}
<b> `apiVersion` _string_ </b><b> `{{ $type.GVK.Group }}/{{ $type.GVK.Version }}`</b>

<b> `kind` _string_ </b><b> `{{ $type.GVK.Kind }}` </b>
{{ end -}}

{{ range $type.Members -}}
#### `{{ .Name  }}` (_{{ markdownRenderType .Type }}_)

{{ template "type_members" . }}
{{ end -}}

{{ end -}}

{{- end -}}
{{- end -}}
