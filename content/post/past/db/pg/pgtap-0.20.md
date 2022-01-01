--- 
date: 2009-03-30T00:30:00Z
slug: pgtap-0.20
title: pgTAP 0.20 Infiltrates Community
aliases: [/computers/databases/postgresql/pgtap-0.20.html]
tags: [Postgres, pgTAP, Testing, Unit Testing, TAP, PL/pgSQL]
type: post
---

I did all I could to stop it, but it just wasn’t possible. [pgTAP 0.20] has
somehow made its way from my Subversion server and infiltrated the PostgreSQL
community. Can nothing be done to stop this menace? Its use leads to cleaner,
more stable, and more-safely refactored code. This insanity must be stopped!
Please review the following list of its added vileness since 0.19 to determine
how you can stop the terrible, terrible influence on your PostgreSQL
unit-testing practices that is pgTAP:

-   Changed the names of the functions tested in `sql/do_tap.sql` and
    `sql/runtests.sql` so that they are less likely to be ordered differently
    given varying collation orders provided in different locales and by
    different vendors. Reported by Ingmar Brouns.
-   Added the `--formatter` and `--archive` options to `pg_prove`.
-   Fixed the typos in `pg_prove` where the output of `--help` listed
    `--test-match` and `--test-schema` instead of `--match` and `--schema`.
-   Added `has_cast()`, `hasnt_cast()`, and `cast_context_is()`.
-   Fixed a borked function signature in `has_trigger()`.
-   Added `has_operator()`, `has_leftop()`, and `has_rightop()`.
-   Fixed a bug where the order of columns found for multicolum indexes by
    `has_index()` could be wrong. Reported by Jeff Wartes. Thanks to Andrew
    Gierth for help fixing the query.

Don’t make the same mistake I did, where I wrote a lot of pgTAP tests for a
client, and now testing database upgrades from 8.2 to 8.3 is just too reliable!
**YOU HAVE BEEN WARNED.**

Good luck with your mission.

  [pgTAP 0.20]: https://github.com/theory/pgtap/releases/tag/rel-0.20
