---
title: What's New in pg_clickhouse
slug: pg_clickhouse-0.3.0
date: 2026-05-11T20:24:08Z
lastMod: 2026-05-11T20:24:08Z
description: Bit of a news catchup on the pg_clickhouse project.
tags: [Postgres, pg_clickhouse, ClickHouse, Release, RE2, JSON]
---

Bit of a news catchup on the [pg_clickhouse] project.

What's New
----------

First up, a couple weeks ago the ClickHouse Blog published [What's New in
pg_clickhouse], in which I covered various improvements to the extension:

> We've been gratified by the community reception of [pg_clickhouse][gh], the
> extension to query ClickHouse databases from Postgres. Recent uptake
> generated a ton of feedback, which we've been diligently addressing in the
> last few releases. These changes follow our constant mantra for
> pg_clickhouse: pushdown, pushdown, pushdown! Let's take a quick tour.

It includes working pushdown examples for [JSONB accessors], [SQL value
functions] like `CURRENT_TIMESTAMP`, [array functions] like `array_cat()` and
`array_to_string()`. It wraps with a demonstration of [HTTP result set
streaming], with a nice bar char for the before and after (spoiler:
pg_clickhouse's http driver became **far** more memory-efficient).

v0.3.0
------

But that's not all. Today we released [pg_clickhouse 0.3.0][GitHub]. Nothing
drives improvements like customer issues, and v0.3.0 features a slew of them,
including:

*   Mapping for the [ClickHouse JSON] type to the PostgreSQL JSONB type in the
    binary driver; it was already supported for the HTTP driver.

*   Support for mapping the Postgres JSON type to the [ClickHouse JSON] type.
    In general JSONB better matches ClickHouse JSON semantics, but we wanted
    to support the obvious alternative.

*   Pushdown for the Postgres `to_char(timestamp[tz], fmt)` function to the
    ClickHouse `formatDateTime()` function for formats that map to
    binary-compatible equivalents: `YYYY`, `MM`, `DD`, `DDD`, `HH24`, `HH12`,
    `HH`, `MI`, `SS`, `Q`, `Mon`, `Dy`, `AM`/`PM`, plus lowercase variants.

*   Support for pushing down functions from the new [re2 extension], which
    provides ClickHouse-compatible [RE2]-backed regular expression functions
    in Postgres. This allows one to avoid the mismatch between Postgres POSIX
    and ClickHouse [RE2] regular expressions mentioned in the [v0.2.0 post]:
    Just use the extension for consistent re2 behavior in Postgres or pushed
    down to ClickHouse.

*   pg_clickhouse 0.3.0 also adds support for pushing down the [fuzzystrmatch]
    functions `soundex()` and `levenshtein()`, and documents the existing
    pushdown for the [intarray] `idx` function.

*   Documented the `column_name` option to `CREATE FOREIGN TABLE` to allow the
    Postgres column to have a different name than the ClickHouse column. Also
    fixed its integration with binary driver.

*   Added an upgrade script to remove `EXECUTION` permission on
    `clickhouse_raw_query()` from public, addressing an [SSRF] vulnerability.
    This change required the major version increment and the need to:

    ```sql
    ALTER EXTENSION pg_clickhouse UPDATE TO '0.3';
    ```

*   Fixed a few http driver TSV parsing bugs, a bug using  `EXPLAIN (VERBOSE)`
    with window functions, and switched `length(text)` and `strpos(text,
    text)` to pushdown as `lengthUTF8` and `positionUTF8`.

*   Removed behavior inherited from the original fork from [postgres_fdw] that
    automatically pushed down builtin functions. All builtin functions that
    can be pushed down are explicitly mapped.

Grab the new release from the usual locations:

*   [PGXN]
*   [GitHub]
*   [Docker] (now with the [re2 extension]!)

Thanks once more to my colleagues, [Kaushik Iska] and [Philip Dubé] for the
slew of pull requests, as well as [Andrey Borodin] for the
`clickhouse_raw_query()` vulnerability report.

What's Next
-----------

The pg_clickhouse project provides more than enough fodder for improvements to
keep us busy a good while. But first, I'll be appearing at [PGConf.dev] next
week to present [Building a Foreign Data Wrapper]. Think of it as building on
[Christoph Pettus]'s PGCon 2023 talk, [Writing a Foreign Data Wrapper], in
order to go into detail on the whys and wherefores for pushing down execution
to a remote database. Would be lovely to see you there. If not, look for the
accompanying blog post later this week.

We also plan to write more about the regular expression mismatch issues, and
of course continue improve pushdown overall. I'll link the details [here] in
the coming weeks.

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [gh]: https://github.com/ClickHouse/pg_clickhouse "pg_clickhouse on GitHub"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.3.0/ "pg_clickhouse 0.3.0 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.3.0
    "pg_clickhouse 0.3.0 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [re2 extension]: https://pgxn.org/dist/re2/
    "ClickHouse/pg_re2: ClickHouse-compatible regex functions using RE2"
  [RE2]: https://github.com/google/re2 "RE2, a regular expression library"
  [fuzzystrmatch]: https://www.postgresql.org/docs/current/fuzzystrmatch.html
    "PostgreSQL Docs: fuzzystrmatch"
  [intarray]: https://www.postgresql.org/docs/current/intarray.html 
    "PostgreSQL Docs: intarray"
  [SSRF]: https://en.wikipedia.org/wiki/Server-side_request_forgery
    "Wikipedia: Server-side request forgery"
  [What's New in pg_clickhouse]: https://clickhouse.com/blog/pg_clickhouse-whats-new-april-2026
    "What's New in pg_clickhouse - JSONB Support, SQL value functions,
    Streaming, and more"
  [JSONB accessors]: https://clickhouse.com/blog/pg_clickhouse-whats-new-april-2026#jsonb-accessors
    "What's New in pg_clickhouse - JSONB accessors"
  [SQL value functions]: https://clickhouse.com/blog/pg_clickhouse-whats-new-april-2026#sql-value-functions
    "What's New in pg_clickhouse - SQL value functions"
  [array functions]: https://clickhouse.com/blog/pg_clickhouse-whats-new-april-2026#array-functions
    "What's New in pg_clickhouse - Array functions"
  [HTTP result set streaming]: https://clickhouse.com/blog/pg_clickhouse-whats-new-april-2026#http-result-set-streaming
    "What's New in pg_clickhouse - HTTP result set streaming"
  [ClickHouse JSON]: https://clickhouse.com/docs/sql-reference/data-types/newjson
    "ClickHouse Docs: JSON Data Type"
  [v0.2.0 post]: /post/postgres/pg_clickhouse-0.2.0.md "pg_clickhouse 0.2.0"
  [postgres_fdw]: https://www.postgresql.org/docs/current/postgres-fdw.html
    "PostgreSQL Docs: postgres_fdw — access data stored in external PostgreSQL servers"
  [Philip Dubé]: https://serprex.github.io
  [Kaushik Iska]: https://iska.is "Kaushik’s Bits & Pieces"
  [Andrey Borodin]: https://github.com/x4m "Andrey Borodin on GitHub"
  [PGConf.dev]: https://2026.pgconf.dev "PGConf.dev 2026"
  [Building a Foreign Data Wrapper]: https://2026.pgconf.dev/session/510
    "PGConf.dev 2026 Schedule: Building a Foreign Data Wrapper"
  [Christoph Pettus]: https://thebuild.com/blog/ "The Build by Christoph Pettus"
  [Writing a Foreign Data Wrapper]: https://www.pgcon.org/2023/schedule/session/397-writing-a-foreign-data-wrapper/index.html
    "PGCon 2023 Schedule: Writing a Foreign Data Wrapper"
  [here]: http://justatheory.com/ "Just a Theory"
