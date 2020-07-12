---
title: "{{ replace .Name "-" " " | title }}"
slug: {{ .Name }}
{{ with now.UTC.Format "2006-01-02T15:04:05Z" -}}
date: {{ . }}
lastMod: {{ . }}
{{- end }}
description: ~
tags: []
type: {{ .Type }}
link: ~
# author: {name: David E. Wheeler, email: david@justatheory.com }
# via: {name: Example, href: https://example.com, title: Hello }
# image: {src: hi.png, alt: Hi, caption: Boy Howdy, link: example.com, title: Hi }
draft: true
---

