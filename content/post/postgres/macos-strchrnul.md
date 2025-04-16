---
title: Fix Postgres `strchrnul` Compile Error on macOS 15.4
slug: fix-postgres-strchrnul
date: 2025-04-16T19:03:26Z
lastMod: 2025-04-16T19:03:26Z
description: |
  A fix for the `error: 'strchrnul' is only available on macOS 15.4 or newer`
  Postgres compile error.
tags: [Postgres, macOS, pgenv]
type: post
---

Just a quick note to users of [pgenv] and anyone else who compiles Postgres on
macOS. In macOS 15.4, Apple introduced a new API, `strchrnul`, which is common
from other platforms. As a result attempting to compile Postgres on 15.4 and
later will lead to this error:

```
snprintf.c:414:27: error: 'strchrnul' is only available on macOS 15.4 or newer [-Werror,-Wunguarded-availability-new]
  414 |                         const char *next_pct = strchrnul(format + 1, '%');
      |                                                ^~~~~~~~~
snprintf.c:366:14: note: 'strchrnul' has been marked as being introduced in macOS 15.4 here, but the deployment target is macOS 15.0.0
  366 | extern char *strchrnul(const char *s, int c);
      |              ^
snprintf.c:414:27: note: enclose 'strchrnul' in a __builtin_available check to silence this warning
```

Tom Lane [chased down and committed the fix], which will be in the next
releases of Postgres 13-17. It should also go away once macOS 16.0 comes out.
But in the meantime, set `MACOSX_DEPLOYMENT_TARGET` to the current OS release
to avoid the error:

```sh
export MACOSX_DEPLOYMENT_TARGET="$(sw_vers -productVersion)"
```

If you use [pgenv], you can [add it to your configuration]. It will need to be
added to all the version configs, too, unless they don't exist and you also set:

```sh
PGENV_WRITE_CONFIGURATION_FILE_AUTOMATICALLY=no
```

  [pgenv]: https://github.com/theory/pgenv "PostgreSQL binary manager"
  [chased down and committed the fix]: https://postgr.es/m/385134.1743523038@sss.pgh.pa.us
  [add it to your configuration]: https://github.com/theory/pgenv/issues/93 "theory/pgenv#93"
