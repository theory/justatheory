---
title: "pg_clickhouse 0.3.1: Now With More C"
slug: pg_clickhouse-0.3.1
date: 2026-06-03T20:13:28Z
lastMod: 2026-06-03T20:13:28Z
description: Big changes for a minor release.
tags: [Postgres, pg_clickhouse, ClickHouse, Release, C, clickhouse-c]
type: post
---

Hello listeners!

Yesterday, with little fanfare (yay 🎉) we pushed out a minor release to
[pg_clickhouse], the interface for querying [ClickHouse] from [Postgres].
As with previous minor releases, yesterday's [v0.3.0][gh] release requires no
reload, restart, or `ALTER EXTENSION UPDATE`, just reload your session when
you're ready and you're good to go.

But don't let the minor version increment deceive you: we made a significant
change to pg_clickhouse in this version. What change, you ask? Here it is:

We replaced the [clickhouse-cpp] library powering the binary driver with the
new [clickhouse-c] library written by my colleague Philip Dubé (a.k.a.,
[serprex]). This header-only client library provides a number of substantial
benefits vs. the [clickhouse-cpp] library we previously vendored:

*   Eliminates incompatibility between C++ `raise`/`throw` & [RAII] and
    Postgres `PG_TRY` & [setjmp/longjmp]. The result is much more stable code
    paths with susceptibility to crashes.
*   Allows us to strictly use Postgres [memory contexts], rather than having
    to deal with both Postgres and C++ allocation patterns, thanks to the
    library's support for specifying the memory allocation functions to use.
*   Eliminates the overhead of vendored code, notably [absl] and [cityhash].
    It does now require [liblz4] and [libzstd] packages, in addition to the
    previously-required [libcurl], uuid, and [libssl], but this pattern makes
    it far more friendly to packager.
*   Far faster compile times and resulting binary. On my M4 MacBook Pro,
    compiling, installing, and running all the tests now takes around 2
    seconds! Meanwhile, the binary size has dropped from 1.8 MB to around 400
    KB; on x8664 Linux it went from 4.9 MB to 1.4 MB!

Big change under the hood! Plus a bug fix to properly convert `UInt16` values
to `int32` instead of `int16`. This is a good one. Get it from the usual
suspects:

*   [PGXN]
*   [GitHub]
*   [Docker]

  [pg_clickhouse]: https://pgxn.org/dist/pg_clickhouse/ "pg_clickhouse on PGXN"
  [ClickHouse]: https://clickhouse.com/clickhouse "ClickHouse: The fastest open-source analytical database"
  [Postgres]: https://www.postgresql.org/
    "PostgreSQL: The World's Most Advanced Open Source Relational Database"
  [clickhouse-cpp]: https://github.com/ClickHouse/clickhouse-cpp
    "clickhouse-cpp - C++ client library for ClickHouse"
  [clickhouse-c]: https://github.com/ClickHouse/clickhouse-c
    "clickhouse-c - minimalist header-only library for embedded contexts"
  [gh]: https://github.com/ClickHouse/pg_clickhouse "pg_clickhouse on GitHub"
  [PGXN]: https://pgxn.org/dist/pg_clickhouse/0.3.1/ "pg_clickhouse 0.3.1 on PGXN"
  [GitHub]: https://github.com/ClickHouse/pg_clickhouse/releases/tag/v0.3.1
    "pg_clickhouse 0.3.1 on GitHub"
  [Docker]: https://github.com/ClickHouse/pg_clickhouse/pkgs/container/pg_clickhouse
    "pg_clickhouse OCI Images"  
  [serprex]: https://serprex.github.io
  [RAII]: https://en.wikipedia.org/wiki/Resource_acquisition_is_initialization
    "Wikipedia: Resource acquisition is initialization"
  [setjmp/longjmp]: https://en.wikipedia.org/wiki/Setjmp.h "Wikipedia: setjmp.h"
  [memory contexts]: https://github.com/postgres/postgres/blob/master/src/backend/utils/mmgr/README
    "PostgreSQL Source: Memory Context System Design Overview"
  [absl]: https://abseil.io "Abseil"
  [cityhash]: https://github.com/google/cityhash "CityHash, a family of hash functions for strings"
  [liblz4]: https://github.com/lz4/lz4/ "lz4 - Extremely Fast Compression algorithm"
  [libzstd]: https://github.com/facebook/zstd/ "Zstandard - Fast real-time compression algorithm"
  [libcurl]: https://curl.se/libcurl/ "ibcurl - your network transfer library"
  [libssl]: https://github.com/openssl/openssl "OpenSSL - General purpose TLS and crypto library"
