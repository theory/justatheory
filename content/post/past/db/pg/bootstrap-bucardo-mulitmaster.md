--- 
date: 2013-02-12T22:11:19Z
slug: bootstrap-bucardo-mulitmaster
title: Bootstrapping Bucardo Master/Master Replication
aliases: [/computers/databases/postgresql/bootstrap-bucardo-mulitmaster.html]
tags: [Postgres, Bucardo, Database Replication]
type: post
---

Let’s say you have a production database up and running and you want to set up a
second database with [Bucardo]-powered replication between them. Getting a new
master up and running without downtime for an existing master, and without
losing any data, is a bit fiddly and under-documented. Having just figured out
one way to do it with the forthcoming Bucardo 5 code base, I wanted to blog it
as much for my own reference as for yours.

First, let’s set up some environment variables to simplify things a bit. I’m
assuming that the database names and usernames are the same, and only the host
names are different:

``` bash
export PGDATABASE=widgets
export PGHOST=here.example.com
export PGHOST2=there.example.com
export PGSUPERUSER=postgres
```

And here are some environment variables we’ll use for Bucardo configuration
stuff:

``` bash
export BUCARDOUSER=bucardo
export BUCARDOPASS=*****
export HERE=here
export THERE=there
```

First, let’s create the new database as a schema-only copy of the existing
database:

``` bash
createdb -U $PGSUPERUSER -h $PGHOST2 $PGDATABASE
pg_dump -U $PGSUPERUSER -h $PGHOST --schema-only $PGDATABASE \
 | psql -U $PGSUPERUSER -h $PGHOST2 -d $PGDATABASE
```

You might also have to copy over roles; use `pg_dumpall --globals-only` to do
that.

Next, we configure Bucardo. Start by telling it about the databases:

``` bash
bucardo add db $HERE$PGDATABASE dbname=$PGDATABASE host=$PGHOST user=$BUCARDOUSER pass=$BUCARDOPASS
bucardo add db $THERE$PGDATABASE dbname=$PGDATABASE host=$PGHOST2 user=$BUCARDOUSER pass=$BUCARDOPASS
```

Tell it about all the tables we want to replicate:

``` bash
bucardo add table public.foo public.bar relgroup=myrels db=$HERE$PGDATABASE 
```

Create a multi-master database group for the two databases:

``` bash
bucardo add dbgroup mydbs $HERE$PGDATABASE:source $THERE$PGDATABASE:source
```

And create the sync:

``` bash
bucardo add sync mysync relgroup=myrels dbs=mydbs autokick=0
```

Note `autokick=0`. This ensures that, while deltas are logged, they will not be
copied anywhere until we tell Bucardo to do so.

And now that we know that any changes from here on in will be queued for
replication, we can go ahead and copy over the data. The only caveat is that we
need to disable the Bucardo triggers on the target system, so that our copying
does not try to queue up. We do that by setting the [`session_replication_role`
GUC] to “replica” while doing the copy:

``` bash
pg_dump -U $PGSUPERUSER -h $PGHOST --data-only -N bucardo $PGDATABASE \
  | PGOPTIONS='-c session_replication_role=replica' \
  | psql -U $PGSUPERUSER -h $PGHOST2 -d $PGDATABASE
```

Great, now all the data is copied over, we can have Bucardo copy any changes
that have been made in the interim, as well as any going forward:

``` bash
bucardo update sync mysync autokick=1
bucardo reload config
```

Bucardo will fire up the necessary syncs and copy over any interim deltas. And
any changes you make to either system in the future will be copied to the other.

  [Bucardo]: http://bucardo.org/
  [`session_replication_role` GUC]: http://www.postgresql.org/docs/9.2/static/runtime-config-client.html#GUC-SESSION-REPLICATION-ROLE
