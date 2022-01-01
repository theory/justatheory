--- 
date: 2011-09-26T19:09:48Z
slug: dbix-connector-and-ssi
title: DBIx::Connector and Serializable Snapshot Isolation
aliases: [/computers/databases/postgresql/dbix-connector-and-ssi.html]
tags: [Postgres, Databases, SSI, Serializable Isolation Level, DBI, DBIx::Connector, Perl]
type: post
---

I was at [Postgres Open] week before last. This was a great conference, very
welcoming atmosphere and lots of great talks. One of the more significant, for
me, was the [session on serializable transactions] by Kevin Grittner, who
developed [SSI] for PostgreSQL 9.1. I hadn’t paid much attention to this feature
before now, but it became clear to me, during the talk, that it’s time.

So what is SSI? Well, serializable transactions are almost certainly how you
think of transactions already. Here’s how Kevin describes them:

> True serializable transactions can simplify software development. Because any
> transaction which will do the right thing if it is the only transaction
> running will also do the right thing in any mix of serializable transactions,
> the programmer need not understand and guard against all possible conflicts.
> If this feature is used consistently, there is no need to ever take an
> explicit lock or SELECT FOR UPDATE/SHARE.

This is, in fact, generally how I’ve thought about transactions. But I’ve
certainly run into cases where it wasn’t true. Back in 2006, I wrote an article
on [managing many-to-many relationships with PL/pgSQL] which demonstrated a race
condition one might commonly find when using an ORM. The solution I offered was
to [always use] a PL/pgSQL function that does the work, and that function
executes a `SELECT...FOR UPDATE` statement to overcome the race condition. This
creates a lock that forces conflicting transactions to be performed serially.

Naturally, this is something one would rather not have to think about. Hence
[SSI]. When you identify a transaction as serializable, it will be executed in a
truly serializable fashion. So I could actually do away with the
`SELECT...FOR UPDATE` workaround — not to mention any other race conditions I
might have missed — simply by telling PostgreSQL to enforce transaction
isolation. This essentially eliminates the possibility of unexpected
side-effects.

This comes at a cost, however. Not in terms of performance so much, since the
[SSI implementation] uses some fancy, recently-developed algorithms to keep
things efficient. (Kevin tells me via IRC: “Usually the rollback and retry work
is the bulk of the additional cost in an SSI load, in my testing so far. A
synthetic load to really stress the LW locking, with a fully-cached database
doing short read-only transactions will have no serialization failures, but can
run up some CPU time in LW lock contention.”) No, the cost is actually in
increased chance of transaction rollback. Because SSI will catch more
transaction conflicts than the traditional “read committed” isolation level,
frameworks that expect to work with SSI need to be prepared to handle more
transaction failures. From [the fine manual][]:

> The Serializable isolation level provides the strictest transaction isolation.
> This level emulates serial transaction execution, as if transactions had been
> executed one after another, serially, rather than concurrently. However, like
> the Repeatable Read level, applications using this level must be prepared to
> retry transactions due to serialization failures.

And that brings me to [DBIx::Connector], my Perl module for safe connection and
transaction management. It currently has no such retry smarts built into it. The
feature closest to that is the “fixup” [connection mode], wherein if a execution
of a code block fails due to a connection failure, DBIx::Connector will
re-connect to the database and execute the code reference again.

I think I should extend DBIx::Connector to take isolation failures and deadlocks
into account. That is, `fixup` mode would retry a code block not only on
connection failure but also on serialization failure (SQLSTATE 40001) and
deadlocks (SQLSTATE 40P01). I would also add a new attribute, `retries`, to
specify the number of times to retry such execution, with a default of three
(which likely will cover the vast majority of cases). This has actually been an
oft-requested feature, and I’m glad to have a new reason to add it.

There are a few design issues to overcome, however:

-   Fixup mode is supported not just by `txn()`, which scopes the execution of a
    code reference to a single transaction, but also `run()`, which does no
    transaction handling. Should the new retry support be added there, too? I
    could see it either way (a single SQL statement executed in `run()` is
    implicitly transaction-scoped).
-   Fixup mode is also supported by `svp()`, which scopes the execution of a
    code reference to a savepoint (a.k.a. a subtransaction). Should the rollback
    and retry be supported there, too, or would the whole transaction have to be
    retried? I’m thinking the latter, since that’s currently the behavior for
    connection failures.
-   Given these issues, will it make more sense to perhaps create a new mode?
    Maybe it would be supported only by `txn()`.

This is do-able, will likely just take some experimentation to figure it out and
settle on the appropriate API. I’ll need to find the tuits for that soon.

In the meantime, given currently [in-progress changes], I’ve just released a new
version of DBIx::Connector with a single change: All uses of the deprecated
`catch` syntax now throw warnings. The previous version threw warnings only the
first time the syntax was used in a particular context, to keep error logs from
getting clogged up. Hopefully most folks have changed their code in the two
months since the previous release and switched to [Try::Tiny] or some other
model for exception handling. The `catch` syntax will be completely removed in
the next release of DBIx::Connector, likely around the end of the year.
Hopefully the new SSI-aware retry functionality will have been integrated by
then, too.

In a future post I’ll likely chew over whether or not to add an API to set the
transaction isolation level within a call to `txn()` and friends.

  [Postgres Open]: http://postgresopen.org/
  [session on serializable transactions]: http://postgresopen.org/2011/schedule/presentations/61/
  [SSI]: http://wiki.postgresql.org/wiki/SSI
  [managing many-to-many relationships with PL/pgSQL]: http://onlamp.com/pub/a/onlamp/2006/06/29/many-to-many-with-plpgsql.html
  [always use]: http://oreilly.com/pub/a/databases/2006/09/07/plpgsql-batch-updates.html?page=5
    "Batch Updates with PL/pgSQL (p.5)"
  [SSI implementation]: http://wiki.postgresql.org/wiki/Serializable
  [the fine manual]: https://www.postgresql.org/docs/current/transaction-iso.html#XACT-SERIALIZABLE
  [DBIx::Connector]: https://metacpan.org/module/DBIx::Connector
  [connection mode]: https://metacpan.org/module/DBIx::Connector#Connection-Modes
  [in-progress changes]: {{% ref "/post/past/perl/dbix-connector-catch" %}}
  [Try::Tiny]: https://metacpan.org/module/Try::Tiny
