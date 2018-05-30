---
title: "{{ replace .TranslationBaseName "-" " " | title }}"
{{- $now := now }}
date: {{ $now.UTC.Format "2006-01-02T15:04:05Z" }}
lastMod: {{ $now.UTC.Format "2006-01-02T15:04:05Z" }}
description: ~
tags: []
type: post
link: ~
# author: {name: David E. Wheeler, email: david@justatheory.com }
# via: {name: Example, href: https://example.com, title: Hello }
# image: {src: hi.png, alt: Hi, caption: Boy Howdy, link: example.com, title: Hi }
draft: true
---

