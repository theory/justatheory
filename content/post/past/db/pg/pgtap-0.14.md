--- 
date: 2008-10-27T23:42:56Z
slug: pgtap-0.14
title: pgTAP 0.14 Released
aliases: [/computers/databases/postgresql/pgtap-0.14.html]
tags: [Postgres, pgTAP, Testing, Unit Testing, TAP, Test Anything Protocol]
type: post
---

I've just released [pgTAP 0.14]. This release focuses on getting more schema
functions into your hands, as well as fixing a few issues. Changes:

-   Added `SET search_path` statements to `uninstall_pgtap.sql.in` so that it
    will work properly when TAP is installed in its own schema. Thanks to Ben
    for the catch!
-   Added commands to drop `pg_version()` and `pg_version_num()`
    to`uninstall_pgtap.sql.in`.
-   Added `has_index()`, `index_is_unique()`, `index_is_primary()`,
    `is_clustered()`, and `index_is_type()`.
-   Added `os_name()`. This is somewhat experimental. If you have `uname`, it's
    probably correct, but assistance in improving OS detection in the `Makefile`
    would be greatly appreciated. Notably, it does not detect Windows.
-   Made `ok()` smarter when the test result is passed as `NULL`. It was dying,
    but now it simply fails and attaches a diagnostic message reporting that the
    test result was `NULL`. Reported by Jason Gordon.
-   Fixed an issue in `check_test()` where an extra character was removed from
    the beginning of the diagnostic output before testing it.
-   Fixed a bug comparing `name[]`s on PostgreSQL 8.2, previously hacked around.
-   Added `has_trigger()` and `trigger_is()`.
-   Switched to pure SQL implementations of the `pg_version()` and
    `pg_version_num()` functions, to simplify including pgTAP in module
    distributions.
-   Added a note to `README.pgtap` about the need to avoid `pg_typeof()` and
    `cmp_ok()` in tests run as part of a distribution.

Enjoy!

  [pgTAP 0.14]: https://github.com/theory/pgtap/releases/tag/rel-0.14
