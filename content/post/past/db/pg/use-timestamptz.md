--- 
date: 2012-04-16T22:08:26Z
slug: postgres-use-timestamptz
title: Always Use TIMESTAMP WITH TIME ZONE
aliases: [/computers/databases/postgresql/use-timestamptz.html]
tags: [Postgres, Time Zones, Databases, Best Practices, Recommendations]
type: post
---

My recommendations for sane time zone management in PostgreSQL:

-   Set `timezone = 'UTC'` in `postgresq.conf`. This makes UTC the default time
    zone for all connections.
-   Use [`timestamp with time zone` (aka `timestamptz`) and
    `time with time zone` (aka `timetz`)]. They store values as UTC, but convert
    them on selection to whatever your time zone setting is.
-   Avoid `timestamp without time zone` (aka `timestamp`) and
    `time without time zone` (aka `time`). These columns do not know the time
    zone of a value, so different apps can insert values in different zones no
    one would ever know.
-   Always specify a time zone when inserting into a `timestamptz` or `timetz`
    column. Unless the zone is UTC. But even then, append a "Z" to your value:
    it's more explicit, and will keep you sane.
-   If you need to get `timestamptz` or `timetz` values in a zone other than
    UTC, use the [`AT TIME ZONE` expression in your query]. But be aware that
    the returned value will be a `timestamp` or `time` value, with no more time
    zone. Good for reporting and queries, bad for storage.
-   If your app *always* needs data in some other time zone, have it
    [`SET timezone = 'UTC'`] on connection. All values then retrieved from the
    database will be in the configured time zone. The app should still include
    the time zone in values sent to the database.

The one exception to the rule preferring `timestamptz` and `timetz` is a special
case: partitioning. When partitioning data on timestamps, you *must not* use
`timestamptz`. Why? Because almost no expression involving `timestamptz`
comparison is immutable. Use one in a `WHERE` clause, and [constraint exclusion]
may well [be ignored] and all partitions scanned. This is usually something you
want to avoid.

So in **this one case** and **only in this one case**, use a
`timestamp without time zone` column, but *always insert data in UTC*. This will
keep things consistent with the `timestamptz` columns you have everywhere else
in your database. Unless your app changes the value of the [`timestamp`
GUC][`SET timezone = 'UTC'`] when it connects, it can just assume that
everything is always UTC, and should always send updates as UTC.

  [`timestamp with time zone` (aka `timestamptz`) and `time with time zone` (aka `timetz`)]: https://www.postgresql.org/docs/current/datatype-datetime.html
  [`AT TIME ZONE` expression in your query]: https://www.postgresql.org/docs/current/functions-datetime.html#FUNCTIONS-DATETIME-ZONECONVERT
  [`SET timezone = 'UTC'`]: https://www.postgresql.org/docs/9.1/static/runtime-config-client.html#GUC-TIMEZONE
  [constraint exclusion]: https://www.postgresql.org/docs/9.1/static/ddl-partitioning.html#DDL-PARTITIONING-CONSTRAINT-EXCLUSION
  [be ignored]: https://web.archive.org/web/20160321063108/http://comments.gmane.org/gmane.comp.db.postgresql.performance/29681
