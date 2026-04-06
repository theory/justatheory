---
title: pg_clickhouse 0.1.6
slug: pg_clickhouse-0.1.6
date: 2026-04-02T15:21:13Z
lastMod: 2026-04-06T20:44:26Z
description: Another bug fix and pushdown-improving release of the foreign data wrapper.
tags: [Postgres, pg_clickhouse, ClickHouse, Release]
type: post
---

We fixed a few bugs this week in [pg_clickhouse], the query interface for
ClickHouse from Postgres. It features improved query cancellation and function
& operator pushdown, including `to_timestamp(float8)`, `ILIKE`, `LIKE`, and
regex operators. Get the new v0.1.6 release from the usual places:

*   [PGXN]
*   [GitHub]
*   [Docker]

Thanks to my colleague, [Kaushik Iska], for most of these fixes!

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/
    "pg_clickhouse on PGXN"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.1.6/
    "pg_clickhouse 0.1.6 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.1.6
    "pg_clickhouse 0.1.6 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [Kaushik Iska]: https://iska.is "Kaushik’s Bits & Pieces"
