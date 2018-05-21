--- 
date: 2010-03-15T18:33:18Z
description: I'm tired of having to remember to set USE_PGXS=1 when building third-party PostgreSQL extensions like pgTAP. Aren’t you?
slug: no-more-use-pgxs
title: No more USE_PGXS=1?
aliases: [/computers/databases/postgresql/no_more_use_pgxs.html]
tags: [Postgres, Makefile]
type: post
---

I've become very tired of having to set `USE_PGXS=1` every time I build pgTAP
outside the `contrib` directory of a PostgreSQL distribution:

``` bash
make USE_PGXS=1
make USE_PGXS=1 install
make USE_PGXS=1 installcheck
```

I am forever forgetting to set it, and it’s just not how one normally expects a
build incantation to work. It was required because that’s how the core [contrib
extensions] work: They all have this code in their `Makefile`s, which those of
us who develop third-party modules have borrowed:

``` bash
ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
else
subdir = contrib/citext
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif
```

They generally expect `../../src/Makefile.global` to exist, and if it doesn’t,
you have to tell it so. I find this annoying, because third-party extensions are
almost never built from the `contrib` directory, so one must always remember to
specify `USE_PGXS=1`.

I'd like to propose, instead, that those of us who maintain third-party
extensions like [pgTAP], [PL/Parrot], and [Temporal PostgreSQL] not force our
users to have to remember this special variable by instead checking to see if
it’s needed ourselves. As such, I've just [added] this code to pgTAP’s
`Makefile`:

``` bash
ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
else
ifeq (exists, $(shell [ -e ../../src/bin/pg_config/pg_config ] && echo exists) ) 
top_builddir = ../..
PG_CONFIG := $(top_builddir)/src/bin/pg_config/pg_config
else
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
endif
endif
```

So it still respects `USE_PGXS=1`, but if it’s not set, it looks to see if it
can find `pg_config` where it would expect it to be if built from the `contrib`
directory. If it’s not there, it simply uses `pg_config` as if `USE_PGXS=1` was
set. This makes building from the `contrib` directory or from anywhere else the
same process:

``` bash
make
make install
make installcheck
```

Much better, much easier to remember.

Is there any reason why third-party PostgreSQL extensions should *not* adopt
this pattern? I don’t think it makes sense for contrib extensions in core to do
it, but for those that will never be in core, I think it makes a lot of sense.

Comments?

  [contrib extensions]: http://www.postgresql.org/docs/8.4/static/contrib.html
    "PostgreSQL Documentation: “Additional Supplied Modules”"
  [pgTAP]: http://pgtap.org
  [PL/Parrot]: http://github.com/leto/plparrot/
  [Temporal PostgreSQL]: http://temporal.projects.postgresql.org/
  [added]: http://github.com/theory/pgtap/commit/400db6d2db7ebabb90fbc528100bb9e518f7fbc3
