--- 
date: 2008-10-11T04:50:03Z
slug: pgtap-0.12
title: pgTAP 0.12 Released
aliases: [/computers/databases/postgresql/pgtap-0.12.html]
tags: [Postgres, pgTAP, Testing, Unit Testing, TAP, Test Anything Protocol]
type: post
---

In anticipation of my [PostgreSQL Conference West 2008 talk] on Sunday, I've
just released [pgTAP 0.12]. This is a minor release with just a few tweaks:

-   Updated `plan()` to disable warnings while it creates its tables. This means
    that `plan()` no longer send NOTICE messages when they run, although tests
    still might, depending on the setting of `client_min_messages`.
-   Added `hasnt_table()`, `hasnt_view()`, and `hasnt_column()`.
-   Added `hasnt_pk()`, `hasnt_fk()`, `col_isnt_pk()`, and `col_isnt_fk()`.
-   Added missing `DROP` statements to `uninstall_pgtap.sql.in`.

I also have an idea to add functions that return the server version number (and
each of the version number parts) and an OS string, to make testing things on
various versions of PostgreSQL and on various operating systems a lot simpler.

I think I'll also spend some time in the next few weeks on an article explaining
exactly what pgTAP is and why you'd want to use it. Provided, of course, I can
find the tuits for that.

  [PostgreSQL Conference West 2008 talk]:
    https://web.archive.org/web/20081120015713/http://www.postgresqlconference.org/west08/talks/
    "PostgreSQL Conference West 2008 Talks"
  [pgTAP 0.12]: https://github.com/theory/pgtap/releases/tag/rel-0.12
