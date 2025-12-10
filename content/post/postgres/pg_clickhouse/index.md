---
title: Introducing pg_clickhouse
slug: pg_clickhouse
date: 2025-12-10T16:34:06Z
lastMod: 2025-12-10T16:34:06Z
description: |
  Introducing pg_clickhouse, a PostgreSQL extension that runs your analytics
  queries on ClickHouse right from PostgreSQL without rewriting any SQL.
tags: [Postgres, pg_clickhouse, ClickHouse]
type: post
link: https://clickhouse.com/blog/introducing-pg_clickhouse
image:
  src: pg_clickhouse.png
  alt: PostgreSQL Logo ⇔ pg_clickhouse ⇔ ClickHouse Logo
  class: clear
  title: "pg_clickhouse: a PostgreSQL extension to run ClickHouse queries from
PostgreSQL"
---

The [ClickHouse blog] has a [posted] a piece by yours truly introducing
[pg_clickhouse], a PostgreSQL extension to run ClickHouse queries from
PostgreSQL:

> While [clickhouse_fdw] and its predecessor, [postgres_fdw], provided the
> foundation for our FDW, we set out to modernize the code & build process, to
> fix bugs & address shortcomings, and to engineer into a complete product
> featuring near universal [pushdown] for analytics queries and aggregations.
>
> Such advances include:
>
> *   Adopting standard [PGXS] build pipeline for PostgreSQL extensions
> *   Adding prepared INSERT support to and adopting the latest supported
> *   release of the [ClickHouse C++ library]
> *   Creating test cases and CI [workflows] to ensure it works on PostgreSQL
>     versions 13-18 and ClickHouse versions 22-25
> *   Support for TLS-based connections for both the [binary protocol] and the
>     [HTTP API], required for [ClickHouse Cloud]
> *   Bool, Decimal, and JSON support
> *   Transparent aggregate function pushdown, including for [ordered-set
>     aggregates] like `percentile_cont()`
> *   [SEMI JOIN] pushdown

I've spent most of the last couple months working on this project, learning a
ton about [ClickHouse], [foreign data wrappers], C and C++, and query
pushdown. Interested? Try ou the Docker image:

```sh
docker run --name pg_clickhouse -e POSTGRES_PASSWORD=my_pass \
       -d ghcr.io/clickhouse/pg_clickhouse:18
docker exec -it pg_clickhouse psql -U postgres -c 'CREATE EXTENSION pg_clickhouse'
```

Or install it from [PGXN] (requires C and C++ build tools, `cmake`, and the
openssl libs, libcurl, and libuuid):

```sh
pgxn install pg_clickhouse
```

Or download it and build it yourself from:

*   [PGXN]
*   [GitHub][pg_clickhouse]

Let me know what you think!

  [ClickHouse blog]: https://clickhouse.com/blog/
  [posted]: https://clickhouse.com/blog/introducing-pg_clickhouse
    "Introducing pg_clickhouse: A Postgres extension for querying ClickHouse"
  [pg_clickhouse]: https://github.com/clickHouse/pg_clickhouse
    "pg_clickhouse on GitHub"
  [clickhouse_fdw]: https://github.com/ildus/clickhouse_fdw
  [postgres_fdw]: https://www.postgresql.org/docs/current/postgres-fdw.html
    "PostgreSQL Docs: postgres_fdw — access data stored in external PostgreSQL servers"
  [pushdown]: https://www.postgresql.org/about/featurematrix/detail/postgres_fdw-pushdown/
    "PostgreSQL Features: postgres_fdw pushdown"
  [ClickHouse C++ library]: https://github.com/clickHouse/clickhouse-cpp/
  [workflows]: https://github.com/ClickHouse/pg_clickhouse/actions
  [binary protocol]: https://clickhouse.com/docs/native-protocol/basics
    "ClickHouse Docs: Native Protocol"
  [HTTP API]: https://clickhouse.com/docs/interfaces/http
    "ClickHouse Docs: HTTP Interface"
  [ClickHouse Cloud]: https://clickhouse.com/cloud "Serverless. Simple. ClickHouse Cloud."
  [ordered-set aggregates]: https://www.postgresql.org/docs/current/functions-aggregate.html#FUNCTIONS-ORDEREDSET-TABLE
    "PostgreSQL Docs: Ordered-Set Aggregate Functions"
  [SEMI JOIN]: https://clickhouse.com/blog/clickhouse-fully-supports-joins-part1#left--right-semi-join
    "ClickHouse Blog: (LEFT / RIGHT) SEMI JOIN"
  [ClickHouse]: https://clickhouse.com/clickhouse "ClickHouse: The fastest open-source analytical database"
  [foreign data wrappers]: https://www.postgresql.org/docs/current/fdw-callbacks.html
    "PostgreSQL Docs: Foreign Data Wrapper Callback Routines"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [PGXS]: https://www.postgresql.org/docs/current/extend-pgxs.html
    "PostgreSQL Extension Building Infrastructure"


  [search_path]: https://www.postgresql.org/docs/current/ddl-schemas.html#DDL-SCHEMAS-PATH
    "PostgreSQL Docs: The Schema Search Path"
