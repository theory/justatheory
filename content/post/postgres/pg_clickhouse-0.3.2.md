---
title: "pg_clickhouse 0.3.2: Ready For Postgres 19"
slug: pg_clickhouse-0.3.2
date: 2026-06-23T16:14:35Z
lastMod: 2026-06-23T16:14:35Z
description: |
  What's new in the latest release of the pg_clickhouse, the interface for querying
  ClickHouse from Postgres.
tags: [Postgres, pg_clickhouse, ClickHouse, Release]
type: post
link: https://clickhouse.com/blog/pg_clickhouse-whats-new-june-2026
---

I've got a new post over on the ClickHouse blog today: [What's New in
pg_clickhouse v0.3.2: Postgres 19, TLS, Regex, and Memory][post]. The big news
is Postgres 19 support:

> The topline change? Support for [PostgreSQL 19 Beta1]. The new Postgres
> version required relatively minor revisions to the pg_clickhouse source code
> to take advantage of tuple and array optimizations, remove old typedefs, add
> new headers, and some test outputs. And with that, we'll be ready for the
> final Postgres release this fall and ship day one on Manged Postgres for
> ClickHouse.

Other new stuff in this release of [pg_clickhouse], the interface for querying
[ClickHouse] from [Postgres], includes regular expression pushdown
improvements TLS connection and binary protocol compression parameters, and
various bug fixes. Get it from the usual sources:

*   [PGXN]
*   [GitHub]
*   [Docker]

  [post]: https://clickhouse.com/blog/pg_clickhouse-whats-new-june-2026
  [PostgreSQL 19 Beta1]: https://www.postgresql.org/about/news/postgresql-19-beta-1-released-3313/
    "PostgreSQL News: PostgreSQL 19 Beta 1 Released!"
  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [ClickHouse]: https://clickhouse.com/clickhouse "ClickHouse: The fastest open-source analytical database"
  [Postgres]: https://www.postgresql.org/
    "PostgreSQL: The World's Most Advanced Open Source Relational Database"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.3.2/ "pg_clickhouse 0.3.2 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.3.2
    "pg_clickhouse 0.3.2 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"
