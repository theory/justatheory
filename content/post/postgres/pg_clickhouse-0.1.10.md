---
title: pg_clickhouse 0.1.10
slug: pg_clickhouse-0.1.10
date: 2026-04-06T21:38:34Z
lastMod: 2026-04-06T21:38:34Z
description: Hi, it's me with another update to pg_clickhouse.
tags: [Postgres, pg_clickhouse, ClickHouse, Release]
---

Hi, it's me, back again with another update to pg_clickhouse, the query
interface for ClickHouse from Postgres. This release, [v0.1.10][GitHub],
maintains binary compatibility with earlier versions but ships a number of
significant improvements that increase compatibility of Postgres features with
ClickHouse. Highlights include:

*   Mappings for the `JSON` and `JSONB` `-> TEXT` and `->> TEXT` operators, as
    well as `jsonb_extract_path_text()` and `jsonb_extract_path()`, to be pushed
    down to ClickHouse using its [sub-column syntax].
*   Mappings to push down the Postgres `statement_timestamp()`,
    `transaction_timestamp()`, and `clock_timestamp()` functions, as well as
    the Postgres "SQL Value Functions", including `CURRENT_TIMESTAMP`,
    `CURRENT_USER`, and `CURRENT_DATABASE`.
*   And the big one: mappings to push down compatible **window functions**,
    including `ROW_NUMBER`, `RANK`, `DENSE_RANK`, `LEAD`,`LAG`, `FIRST_VALUE`,
    `LAST_VALUE`, `NTH_VALUE`, `NTILE`, `CUME_DIST`, `PERCENT_RANK`,  and
    `MIN`/`MAX OVER`.
*   Oh yeah, the other big one: added **result set streaming** to the HTTP
    driver. Rather that load all the results A testing loading a 1GB table
    reduced memory consumption from over 1GB to 73MB peak.

We'll work up a longer post to show off some of these features in the next
week. But in the meantime, git it while it's hot!

*   [PGXN]
*   [GitHub]
*   [Docker]

Thanks to my colleagues, [Kaushik Iska] and [Philip Dubé] for the slew of pull
requests I waded through this past week!

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/
    "pg_clickhouse on PGXN"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.1.10/
    "pg_clickhouse 0.1.10 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.1.10
    "pg_clickhouse 0.1.10 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [sub-column syntax]: https://clickhouse.com/docs/sql-reference/data-types/newjson#reading-json-paths-as-sub-columns
    "ClickHouse Docs: Reading JSON paths as sub-columns"
  [Kaushik Iska]: https://iska.is "Kaushik’s Bits & Pieces"
  [Philip Dubé]: https://serprex.github.io
