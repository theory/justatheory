---
title: Update Your Control Files
slug: update-control
date: 2025-04-28T20:08:49Z
lastMod: 2025-04-28T20:08:49Z
description: |
  Suggestions to PostgreSQL extension maintainers to make some tweaks to your
  `.control` files and `Makefile`s.
tags: [Postgres, Extensions, PGXS]
type: post
---

Reviews of the extension search path patch, now [committed][patch] and slated
for PostgreSQL 18, revealed a few issues with extension configuration. Based
on the ensuing discussion, and even though PostgreSQL 18 will include
workarounds, it's best to make adjustments to the extensions you maintain, the
better to serve existing PostgreSQL versions and to hew closer to best
practices.

Thus, a couple of recommendations for extension maintainers.

1.  Remove the `$libdir/` prefix from the `module_pathname` directive in the
    [control file]. The `$libdir/` requires extension modules to live in
    `pkglibdir` (see [pg_config]), and no other directories included in
    `dynamic_library_path`, which limits where users can install it. Although
    PostgreSQL 18 will ignore the prefix, the docs will also no longer
    recommend it.

2.  Remove the `directory` parameter from the [control file] and the
    `MODULEDIR` directive from the `Makefile`. Honestly, few people used these
    directives, which installed extension files in subdirectories or even
    completely different absolute directories. In some cases they may have
    been useful for testing or extension organization, but the introduction of
    the [extension search path][patch] alleviates its use cases.

These changes will future-proof your extensions and make them better ecosystem
citizens. Plus, they clean out some otherwise funky configurations that just
aren't necessary. Make the changes today --- and while you're at it, test your
extensions with PostgreSQL 18 pre-releases!

Look, [I'll go first].

  [patch]: https://github.com/postgres/postgres/commit/4f7f7b0
  [control file]: https://www.postgresql.org/docs/current/extend-extensions.html#EXTEND-EXTENSIONS-FILES
  [pg_config]: https://www.postgresql.org/docs/17/app-pgconfig.html
  [I'll go first]: https://github.com/theory/pg-semver/pull/76
