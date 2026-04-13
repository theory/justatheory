---
title: pg_clickhouse 0.2.0
slug: pg_clickhouse-0.2.0
date: 2026-04-13T22:22:53Z
lastMod: 2026-04-13T22:22:53Z
description: I guess this is a pg_clickhouse announcement blog, now.
tags: [Postgres, pg_clickhouse, ClickHouse, Release, Regular Expressions]
---

In response to a generous corpus of real-world user feedback, we've been hard
at work the past week adding a slew of updates to [pg_clickhouse], the query
interface for ClickHouse from Postgres. As usual, we focused on improving
pushdown, especially for various date and time, array, and regular expression
functions.

Regular expressions prove to be a particular challenge, because while Postgres
supports [POSIX Regular Expressions], ClickHouse relies on [RE2][re2]. For
simple regular expressions that no doubt make up a huge number of use cases,
the differences matter little or not at all. But these two engines take quite
different approaches to regular expression evaluation, so issues will come up.

To address this, the new regular expression pushdown code examines the flags
passed to the Postgres regular expression functions and refuses to push down
in the presence of incompatible flags. It will push down compatible flags,
though it takes pains to also pass `(?-s)` to disable the `s` flag, because
ClickHouse [enables `s`] by default, contrary to the expectations of the
Postgres regular expression user.

pg_clickhouse does not (yet?) examine the flags embedded in the regular
expression, but v0.2.0 now provides the `pg_clickhouse.pushdown_regex`
setting, which can disable regular expression pushdown:

``` sql
SET pg_clickhouse.pushdown_regex = 'false';
```

My colleague [Philip Dubé] has also started work embedding
ClickHouse-compatible regular expression functions that use [re2] directly, to
provide more options soon --- not to mention a standalone extension with just
those functions.

As with all pg_clickhouse releases to date, v0.2.0 does not break
compatibility with previous versions at all: once the new library has been
installed and reloaded, existing v0.1 releases get all the benefits. There is,
however, a new function, `pgch_version()`, which requires an upgrade to
use:

```pgsql
try=# ALTER EXTENSION pg_clickhouse UPDATE TO '0.2';
ALTER EXTENSION

try=# select pgch_version();
 pgch_version 
--------------
 0.2.0
(1 row)
```

We plan for a lot more to come, including improved subquery pushdown, more
function pushdown, string and date formatting pushdown, and more. Watch [this
space] for further announcements and the [ClickHouse Blog] for a forthcoming
post covering the pg_clickhouse features and improvements in detail.
Meanwhile, here's where to get the new release:

*   [PGXN]
*   [GitHub]
*   [Docker]

Thanks again my colleagues, [Kaushik Iska] and [Philip Dubé] for the slew of
pull requests and feature brainstorming.

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [POSIX Regular Expressions]: https://www.postgresql.org/docs/18/functions-matching.html#FUNCTIONS-POSIX-REGEXP
    "PostgreSQL Docs: POSIX Regular Expressions"
  [Postgres flags]: https://www.postgresql.org/docs/18/functions-matching.html#POSIX-EMBEDDED-OPTIONS-TABLE
    "PostgreSQL Docs: ARE Embedded-Option Letters"
  [re2]: https://github.com/google/re2/wiki/Syntax "RE2 Syntax"
  [enables `s`]: https://clickhouse.com/docs/sql-reference/functions/string-search-functions#match
    "ClickHouse Docs: match"
  [Philip Dubé]: https://serprex.github.io
  [this space]: http://justatheory.com/ "Just a Theory"
  [ClickHouse Blog]: https://clickhouse.com/blog
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.2.0/
    "pg_clickhouse 0.2.0 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.2.0
    "pg_clickhouse 0.2.0 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [Kaushik Iska]: https://iska.is "Kaushik’s Bits & Pieces"
