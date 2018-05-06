--- 
date: 2013-02-12T22:11:19Z
slug: bootstrap-bucardo-mulitmaster
title: Bootstrapping Bucardo Master/Master Replication
aliases: [/computers/databases/postgresql/bootstrap-bucardo-mulitmaster.html]
tags: [Postgres, Bucardo, database replication]
---

<p>Let’s say you have a production database up and running and you want to set up a second database with <a href="http://bucardo.org/">Bucardo</a>-powered replication between them. Getting a new master up and running without downtime for an existing master, and without losing any data, is a bit fiddly and under-documented. Having just figured out one way to do it with the forthcoming Bucardo 5 code base, I wanted to blog it as much for my own reference as for yours.</p>

<p>First, let’s set up some environment variables to simplify things a bit. I’m assuming that the database names and usernames are the same, and only the host names are different:</p>

<pre><code>export PGDATABASE=widgets
export PGHOST=here.example.com
export PGHOST2=there.example.com
export PGSUPERUSER=postgres
</code></pre>

<p>And here are some environment variables we’ll use for Bucardo configuration stuff:</p>

<pre><code>export BUCARDOUSER=bucardo
export BUCARDOPASS=*****
export HERE=here
export THERE=there
</code></pre>

<p>First, let’s create the new database as a schema-only copy of the existing database:</p>

<pre><code>createdb -U $PGSUPERUSER -h $PGHOST2 $PGDATABASE
pg_dump -U $PGSUPERUSER -h $PGHOST --schema-only $PGDATABASE \
| psql -U $PGSUPERUSER -h $PGHOST2 -d $PGDATABASE
</code></pre>

<p>You might also have to copy over roles; use <code>pg_dumpall --globals-only</code> to do that.</p>

<p>Next, we configure Bucardo. Start by telling it about the databases:</p>

<pre><code>bucardo add db $HERE$PGDATABASE dbname=$PGDATABASE host=$PGHOST user=$BUCARDOUSER pass=$BUCARDOPASS
bucardo add db $THERE$PGDATABASE dbname=$PGDATABASE host=$PGHOST2 user=$BUCARDOUSER pass=$BUCARDOPASS
</code></pre>

<p>Tell it about all the tables we want to replicate:</p>

<pre><code>bucardo add table public.foo public.bar relgroup=myrels db=$HERE$PGDATABASE 
</code></pre>

<p>Create a multi-master database group for the two databases:</p>

<pre><code>bucardo add dbgroup mydbs $HERE$PGDATABASE:source $THERE$PGDATABASE:source  
</code></pre>

<p>And create the sync:</p>

<pre><code>bucardo add sync mysync relgroup=myrels dbs=mydbs autokick=0
</code></pre>

<p>Note <code>autokick=0</code>. This ensures that, while deltas are logged, they will not be copied anywhere until we tell Bucardo to do so.</p>

<p>And now that we know that any changes from here on in will be queued for replication, we can go ahead and copy over the data. The only caveat is that we need to disable the Bucardo triggers on the target system, so that our copying does not try to queue up. We do that by setting the <a href="http://www.postgresql.org/docs/9.2/static/runtime-config-client.html#GUC-SESSION-REPLICATION-ROLE"><code>session_replication_role</code> GUC</a> to “replica” while doing the copy:</p>

<pre><code>pg_dump -U $PGSUPERUSER -h $PGHOST --data-only -N bucardo $PGDATABASE \
| PGOPTIONS='-c session_replication_role=replica' \
psql -U $PGSUPERUSER -h $PGHOST2 -d $PGDATABASE
</code></pre>

<p>Great, now all the data is copied over, we can have Bucardo copy any changes that have been made in the interim, as well as any going forward:</p>

<pre><code>bucardo update sync mysync autokick=1
bucardo reload config
</code></pre>

<p>Bucardo will fire up the necessary syncs and copy over any interim deltas. And any changes you make to either system in the future will be copied to the other.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/bootstrap-bucardo-mulitmaster.html">old layout</a>.</small></p>


