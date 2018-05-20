--- 
date: 2009-04-17T19:36:03Z
slug: ossp-uuid-postgresql
title: PostgreSQL + OSSP UUID on Mac OS X
aliases: [/computers/databases/postgresql/ossp-uuid-postgresql.html]
tags: [Postgres, UUIDs, OSSP, macOS]
type: post
---

Wanted to get this down since I just dealt with it for the second time in the
last year. The issue is this: If you have [OSSP uuid] installed on Mac OS X, and
you want to build PostgreSQL with OSSP uuid support, you pass `--with-ossp-uuid`
to PostgreSQL's `configure` script. However, you might notice this in the
output:

    checking ossp/uuid.h usability... no
    checking ossp/uuid.h presence... yes
    configure: WARNING: ossp/uuid.h: present but cannot be compiled
    configure: WARNING: ossp/uuid.h:     check for missing prerequisite headers?
    configure: WARNING: ossp/uuid.h: see the Autoconf documentation
    configure: WARNING: ossp/uuid.h:     section "Present But Cannot Be Compiled"
    configure: WARNING: ossp/uuid.h: proceeding with the preprocessor's result
    configure: WARNING: ossp/uuid.h: in the future, the compiler will take precedence
    configure: WARNING:     ## ---------------------------------------- ##
    configure: WARNING:     ## Report this to pgsql-bugs@postgresql.org ##
    configure: WARNING:     ## ---------------------------------------- ##
    checking for ossp/uuid.h... yes

The reason for this message is that OSSP uuid has symbols that conflicts those
included with Mac OS X. If you look in `config.log`, you'll see something like
this:

    configure:13224: checking ossp/uuid.h usability
    configure:13241: gcc -no-cpp-precomp -c -O2 -Wall -Wmissing-prototypes -Wpointer-arith -Wdeclaration-after-statement -Wendif-labels -fno-strict-aliasing -fwrapv  -I/usr/local/include/libxml2  -I/usr/local/include conftest.c >&5
    In file included from conftest.c:98:
    /usr/local/include/ossp/uuid.h:94: error: conflicting types for 'uuid_t'
    /usr/include/unistd.h:133: error: previous declaration of 'uuid_t' was here

It turns out that I [reported] this issue to OSSP a while ago. For PostgreSQL,
at least it doesn't seem to be much of a problem: the build continues and I'm
able to install the ossp-uuid contrib module without a problem. So the upshot
is: **you can ignore the above warning!**

One recommendation I *do* have, however, is to install the OSSP uuid header file
in a non-default location. Why? Because if you build Apache and APR from source,
like I do, you'll get the same failure because of conflicting `uuid_t` symbols,
and APR will fail to actually build! So I pass
`--includedir=/usr/local/include/ossp` to OSSP uuid's configure. This has no
effect on how OSSP uuid itself behaves, and the PostgreSQL is smart enough to
look there without having to be told. Meanwhile, it will then be out of the way
of your APR build (assuming you delete `/usr/local/include/uuid.h` or
`/usr/include/uuid.h`).

  [OSSP uuid]: http://www.ossp.org/pkg/lib/uuid/
  [reported]: http://cvs.ossp.org/tktview?tn=164
    "OSSP Ticket 164: Header doesn't work if <unistd.h> is included
    first"
