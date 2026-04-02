---
title: pg_clickhouse v0.1.4
slug: pg_clickhouse-0.1.4
date: 2026-02-17T22:24:08Z
lastMod: 2026-02-17T22:24:08Z
description: A quick note on the release of pg_clickhouse v0.1.4.
tags: [Postgres, pg_clickhouse, Release]
type: post
---

Just a quick post to note the release of [pg_clickhouse] v0.1.4. This v0.1
maintenance release can be upgraded in-place and requires no
`ALTER EXTENSION UPDATE` command; as soon as sessions reload the shared
library they'll be good to go.

Thanks in part to reports from attentive users, v0.1.4's most significant
changes improve the following:

*   The binary driver now properly inserts `NULL` into a [Nullable(T)] column.
    Previously it would raise an error.
*   The http driver now properly parses arrays. Previously it improperly
    included single quotes in string items and would choke on brackets (`[]`)
    in values.
*   Both drivers now support mapping a ClickHouse [String] types to Postgres
    [BYTEA] columns. Previously the worked only with [text types], which is
    generally preferred. But since ClickHouse explicitly supports binary data
    in [String] values (notably [hash function] return values), pg_clickhouse
    needs to support it, as well.

Get it in all the usual places:

*   [PGXN]
*   [GitHub]
*   [Docker]

My thanks to pg_clickhouse users like [Rahul Mehta] for reporting issues, and
to my employer, [ClickHouse], for championing this extension. Next up: more
aggregate function mapping, hash function pushdown, and improved subquery
(specifically, `SubPlan`) pushdown.

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/
    "pg_clickhouse on PGXN"
  [Nullable(T)]: https://clickhouse.com/docs/sql-reference/data-types/nullable
    "ClickHouse Docs: Nullable(T)"
  [String]: https://clickhouse.com/docs/sql-reference/data-types/string
    "ClickHouse Docs: String"
  [BYTEA]: https://www.postgresql.org/docs/current/datatype-binary.html
    "Postgres Docs: Binary Data Types"
  [text types]: https://www.postgresql.org/docs/current/datatype-character.html
    "Postgres Docs: Character Types"
  [hash function]: https://clickhouse.com/docs/sql-reference/functions/hash-functions
    "ClickHouse Docs: Hash functions"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.1.4/
    "pg_clickhouse 0.1.4 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.1.4
    "pg_clickhouse 0.1.4 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [Rahul Mehta]: https://github.com/ClickHouse/pg_clickhouse/issues/140
    "ClickHouse/pg_clickhouse#140 Connection Terminates Unexpectedly When Using NULL Value for UUID"
  [ClickHouse]: https://clickhouse.com/clickhouse "ClickHouse: The fastest open-source analytical database"
