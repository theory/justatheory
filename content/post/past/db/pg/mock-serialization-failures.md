--- 
date: 2012-11-02T22:16:28Z
slug: mock-postgres-serialization-failures
title: Mocking Serialization Failures
aliases: [/computers/databases/postgresql/mock-serialization-failures.html]
tags: [Postgres, SQL]
type: post
---

I’ve been hacking on the forthcoming [Bucardo] 5 code base the last couple
weeks, as we’re going to start using it pretty extensively at [work], and it
needed a little love to get it closer to release. The biggest issue I fixed was
the handling of serialization failures.

When copying deltas from one database to another, Bucardo sets the [transaction
isolation] to “Serializable”. As of PostgreSQL 9.1, this is true serializable
isolation. However, there were no tests for it in Bucardo. And since pervious
versions of PostgreSQL had poorer isolation (retained in 9.1 as “Repeatable
Read”), I don’t think anyone really noticed it much. As I’m doing all my testing
against 9.2, I was getting the serialization failures about half the time I ran
the test suite. It took me a good week to chase down the issue. Once I did, I
posted to the Bucardo mail list pointing out that Bucardo was *not* attempting
to run a transaction again after failure, and at any rate, the model for how it
thought to do so was a little wonky: it let the replicating process die, on the
assumption that a new process would pick up where it left off. It did not.

Bucardo maintainer Greg Sabino Mullane [proposed] that we let the replicating
process try again on its own. So I went and made it do that. And then the tests
started passing every time. Yay!

Returning to the point of this post, I felt that there ought to be tests for
serialization failures in the Bucardo test suite, so that we can ensure that
this continues to work. My first thought was to use PL/pgSQL in 8.4 and higher
to mock a serialization failure. Observe:

    david=# \set VERBOSITY verbose
    david=# DO $$BEGIN RAISE EXCEPTION 'Serialization error'
           USING ERRCODE = 'serialization_failure'; END $$;
    ERROR:  40001: Serialization error
    LOCATION:  exec_stmt_raise, pl_exec.c:2840

Cool, right? Well, the trick is to get this to run on the replication target,
but only once. When Bucardo retries, we want it to succeed, thus properly
demonstrating the COPY/SERIALIZATION FAIL/ROLLBACK/COPY/SUCCESS pattern.
Furthermore, when it copies deltas to a target, Bucardo disables all triggers
and rules. So how to get something trigger-like to run on a target table and
throw the serialization error?

Studying the Bucardo source code, I discovered that Bucardo itself does not
disable triggers and rules. Rather, it sets the `session_replica_role` GUC to
“replica”. This causes PostgreSQL to disable the triggers and rules — except for
those that have been set to `ENABLE REPLICA`. The PostgreSQL [`ALTER TABLE`
docs][]:

> The trigger firing mechanism is also affected by the configuration variable
> session\_replication\_role. Simply enabled triggers will fire when the
> replication role is “origin” (the default) or “local”. Triggers configured as
> ENABLE REPLICA will only fire if the session is in “replica” mode, and
> triggers configured as ENABLE ALWAYS will fire regardless of the current
> replication mode.

Well how cool is that? So all I needed to do was plug in a replica trigger and
have it throw an exception once but not twice. Via email, Kevin Grittner pointed
out that a sequence might work, and indeed it does. Because sequence values are
non-transactional, sequences return different values every time they’re access.

Here’s what I came up with:

``` plpgsql
CREATE SEQUENCE serial_seq;

CREATE OR REPLACE FUNCTION mock_serial_fail(
) RETURNS trigger LANGUAGE plpgsql AS $_$
BEGIN
    IF nextval('serial_seq') % 2 = 0 THEN RETURN NEW; END IF;
    RAISE EXCEPTION 'Serialization error'
            USING ERRCODE = 'serialization_failure';
END;
$_$;

CREATE TRIGGER mock_serial_fail AFTER INSERT ON bucardo_test2
    FOR EACH ROW EXECUTE PROCEDURE mock_serial_fail();
ALTER TABLE bucardo_test2 ENABLE REPLICA TRIGGER mock_serial_fail;
```

The first `INSERT` (or, in Bucardo’s case, `COPY`) to `bucardo_test2` will die
with the serialization error. The second `INSERT` (or `COPY`) succeeds. This
worked great, and I was able to write test in a few hours and [get them
committed]. And now we can be reasonably sure that Bucardo will always properly
handle serialization failures.

  [Bucardo]: http://bucardo.org/wiki/Bucardo
  [work]: http://iovation.com/
  [transaction isolation]: http://www.postgresql.org/docs/current/static/transaction-iso.html
  [proposed]: https://bucardo.org/pipermail/bucardo-general/2012-October/001616.html
  [`ALTER TABLE` docs]: http://www.postgresql.org/docs/9.2/static/sql-altertable.html
  [get them committed]: https://github.com/bucardo/bucardo/commit/3931056f15f3f6df9b089fd439c14ec38b66d841
