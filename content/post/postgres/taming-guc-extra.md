---
title: 🐏 Taming PostgreSQL GUC “extra” Data
slug: taming-guc-extra
date: 2025-12-18T18:04:50Z
lastMod: 2025-12-18T18:04:50Z
description: |
  For the ClickHouse blog I wrote up learning how to work with C data structures
  and memory allocation within the tight constraints of the Postgres "GUC" API.
tags: [Postgres, GUC, pg_clickhouse]
type: post
link: https://clickhouse.com/blog/taming-postgres-guc-extra-data
---

New [post] up on on the ClickHouse blog:

> I wanted to optimize away parsing the key/value pairs from the
> [pg_clickhouse] `pg_clickhouse.session_settings` GUC for every query by
> pre-parsing it on assignment and assigning it to a separate variable. It
> took a few tries, as the GUC API requires quite specific memory allocation
> for extra data to work properly. It took me a few tries to land on a
> workable and correct solution.

Struggling to understand, making missteps, and ultimately coming to a
reasonable design and solution satisfies me so immensely that I always want to
share. This piece gets down in the C coding weeds; my fellow extension coders
might enjoy it.

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [post]: https://clickhouse.com/blog/taming-postgres-guc-extra-data]
    "Taming PostgreSQL GUC “extra” Data"
