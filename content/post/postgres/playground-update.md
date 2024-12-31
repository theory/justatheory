---
title: SQL/JSON Path Playground Update
slug: playground-update
date: 2024-12-31T20:40:32Z
lastMod: 2024-12-31T20:40:32Z
description: |
  The Go SQL/JSON Playground has been updated with a fresh design and PostgreSQL
  17 compatibility.
tags: [Postgres, SQL/JSON, JSON Path, Go, Playground]
type: post
link: https://theory.github.io/sqljson/
---

Based on the recently-released Go [JSONPath] and [JSONTree] playgrounds, I've
updated the design and of the [SQL/JSON Playground][play]. It now comes
populated with sample JSON borrowed from [RFC 9535], as well as a selection of
queries that randomly populate the query field on each reload. I believe this
makes the playground nicer to start using, not to mention more pleasing to the
eye.

The playground has also been updated to use the recently-released
[sqljson/path v0.2 package], which replicates a few changes included in the
[PostgreSQL 17 release]. Notably, the `.string()` function no longer uses a
time zone or variable format to for dates and times.

Curious to see it in action? [Check it out!][play]

  [JSONPath]: https://theory.github.io/jsonpath/ "Go JSONPath Playground"
  [JSONTree]: https://theory.github.io/jsontree/ "Go JSONTree Playground"
  [play]: https://theory.github.io/sqljson/ "Go SQL/JSON Playground"
  [RFC 9535]: https://www.rfc-editor.org/rfc/rfc9535.html
    "RFC 9535 JSONPath: Query Expressions for JSON"
  [sqljson/path v0.2 package]: https://pkg.go.dev/github.com/theory/sqljson@v0.2.1/path
  [PostgreSQL 17 release]: https://www.postgresql.org/about/news/postgresql-17-released-2936/
    "PostgreSQL 17 Released!"
