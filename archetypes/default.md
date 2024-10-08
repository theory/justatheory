---
title: {{ replace .Name "-" " " | title }}
slug: {{ .Name }}
{{ with now.UTC.Format "2006-01-02T15:04:05Z" -}}
date: {{ . }}
lastMod: {{ . }}
{{- end }}
description: ~
tags: []
type: {{ .Type }}
link: ~
# draft: true
# author:
#   name: {{ .Site.Params.Author.name }}
#   email: {{ .Site.Params.Author.email }}
# via:
#   name: Example
#   href: https://example.com
#   title: Hello
# image:
#   src: image.png
#   link: https://example.com
#   class: left # frame, left, right, center, clear, dark
#   title: tooltip *text*
#   alt: alt text for *image*
#   target: target
#   rel: rel
#   width: 100
#   height: 100
#   heading: heading in `<h4>`
#   caption: caption `text`
#   attr: Image by [attribution](https://example.com)
#   copyright: {{ now.Format "2006" }} David E. Wheeler
#   metaOnly: false
---

