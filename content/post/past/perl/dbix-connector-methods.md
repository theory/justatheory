--- 
date: 2009-10-13T19:25:19Z
slug: dbix-connector-methods
title: Suggest Method Names for DBIx::Connector
aliases: [/computers/programming/perl/modules/dbix-connector-methods.html]
tags: [Perl, DBI, databases, SQL, DBIx::Connector, bike shedding]
type: post
---

Thanks to feedback from Tim Bunce and Peter Rabbitson in a DBIx::Class [bug
report], I've been reworking [DBIx::Connector]'s block-handling methods. Tim's
objection is that the the feature of `do()` and `txn_do()` that executes the
code reference a second time in the event of a connection failure can be
dangerous. That is, it can lead to action-at-a-distance bugs that are hard to
find and fix. Tim suggested renaming the methods `do_with_retry()` and
`txn_do_with_retry()` in order to make explicit what's going on, and to have
non-retry versions of the methods.

I've made this change in the [repository]. But I wasn't happy with the method
names; even though they're unambiguous, they are also overly long and not very
friendly. I want people to *use* the retrying methods, but felt that the long
names make the non-retrying preferable to users. While I was at it, I also
wanted to get rid of `do()`, since it quickly became clear that it could [cause
some confusion] with the DBI's `do()` method.

I've been thesaurus spelunking for the last few days, and have come up with a
few options, but would love to hear other suggestions. I like using `run`
instead of `do` to avoid confusion with the DBI, but otherwise I'm not really
happy with what I've come up with. There are basically five different methods
(using Tim's suggestions for the moment):

`run( sub {} )`
:   Just run a block of code.

`txn_run( sub {} )`
:   Run a block of code inside a transaction.

`run_with_retry( sub {} )`
:   Run a block of code without pinging the database, and re-run the code if it
    throws an exception and the database turned out to be disconnected.

`txn_run_with_rerun( sub {} )`
:   Like `run_with_retry()`, but run the block inside a transaction.

`svp_run( sub {} )`
:   Run a block of code inside a savepoint (no retry for savepoints).

Here are some of the names I've come up with so far:

| Run block | Run in txn | Run in savepoint | Run with retry | Run in txn with retry | Retry Mnemonic                           |
|-----------|------------|------------------|----------------|-----------------------|------------------------------------------|
| `run`     | `txn_run`  | `svp_run`        | `runup`        | `txn_runup`           | Run assuming the db is up, retry if not. |
| `run`     | `txn_run`  | `svp_run`        | `run_up`       | `txn_run_up`          | Same as above.                           |
| `run`     | `txn_run`  | `svp_run`        | `rerun`        | `txn_rerun`           | Run assuming the db is up, rerun if not. |
| `run`     | `txn_run`  | `svp_run`        | `run::retry`   | `txn_run::retry`      | `::` means “with”                        |

That last one is a cute hack suggested by [Rob Kinyon] on IRC. As you can see,
I'm pretty consistent with the non-retrying method names; it's the methods that
retry that I'm not satisfied with. A approach I've avoided is to use an adverb
for the non-retry methods, mainly because there is no retry possible for the
savepoint methods, so it seemed silly to have `svp_run_safely()` to complement
`do_safely()` and `txn_do_safely()`.

Brilliant suggestions warmly appreciated.

  [bug report]: https://rt.cpan.org/Ticket/Display.html?id=47005
    "RT #47005: txn_do should provide a way to disable retry"
  [DBIx::Connector]: http://search.cpan.org/perldoc?DBIx::Connector
    "DBIx::Connector on CPAN"
  [repository]: http://github.com/theory/dbix-connector/
    "DBIx::Connector on GitHub"
  [cause some confusion]: http://github.com/theory/dbix-connector/issues#issue/3
    "Issue #3: API is somewhat confusing"
  [Rob Kinyon]: http://search.cpan.org/~rkinyon/ "Rob Kinyon's CPAN distributions"
