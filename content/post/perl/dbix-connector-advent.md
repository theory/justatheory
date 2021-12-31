
---
title: Less Tedium, More Transactions
date: 2011-12-22T12:00:00Z
description: "*2011 Perl Advent Calendar* post on the use of the DBIx::Connector Perl module."
slug: dbix-connector-advent
tags: [Perl, Advent Calendar, DBIx::Connector]
type: post
---

A frequent pattern when writing database-backed applications with the [DBI] is
to connect to the database and cache the database handle somewhere. A simplified
example:

``` perl
package MyApp::DB;
use DBI;
use strict;

my $DBH = DBI->connect('DBI:SQLite:dbname=myapp.db', '', '', {
    PrintError     => 0,
    RaiseError     => 1,
    AutoCommit     => 1,
    sqlite_unicode => 1,
});

sub dbh { $DBH }
```

Just load MyApp::DB anywhere in your app and, whenever you want to use the
database, grab the handle from `MyApp::DB->dbh`.

This pattern is common enough that [Apache::DBI] was created to magically do it
for you on mod\_perl, and the DBI added [`connect_cached()`] so that it could
cache connections itself. However, each of these solutions has some issues:

-   What happens when your program forks? Apache::DBI handles this condition,
    but neither the home-grown solution nor `connect_cached()` does, and
    identifying a forked database handle as the source of a crash is notoriously
    unintuitive.

-   What happens when your program spawns a new thread? Sure, some DBI drivers
    might still work, but others might not. Best to treat new threads the same
    as new processes and reconnect to the database. Neither Apache::DBI nor
    `connect_cached()` deal with threading issues, and of course neither does
    the custom solution.

-   Apache::DBI is magical and mysterious; but the magic comes with serious
    side-effects. Apache::DBI plugs itself right into the DBI itself, replacing
    its connection methods (which is why load ordering is so important to use it
    properly). Knowledge of Apache::DBI is actually built right into the DBI
    itself, meaning that the magic runs deep and both ways. These are pretty
    serious violations of encapsulation in both directions.

-   `connect_cached()` has a bit of its own unfortunate magic. Every call to
    `connect_cached()` resets the connection attributes. So if you have code in
    one place that starts a transaction, and code elsewhere but executed in the
    same scope that also fetches a `connect_cached()` handle, the transaction
    will be committed then and there, even though the code that started it might
    not be done with it. One can [work around this issue via callbacks], but
    it's a bit of a hack.

Using a custom caching solution avoids the magic, but getting fork- and
thread-safety right is surprisingly non-trivial, in the same way that [doing
your own exception-handling is surprisingly non-trivial].

Enter [DBIx::Connector], a module that efficiently manages your database
connections in a thread- and fork-safe manner so that you don't have to. If you
already have a custom solution, switching to DBIx::Connector is easy. Here's a
revision of MyApp::DB that uses it:

``` perl
package MyApp::DB;
use DBIx::Connector;
use strict;

my $CONN = DBIx::Connector->new('DBI:SQLite:dbname=myapp.db', '', '', {
    PrintError     => 0,
    RaiseError     => 1,
    AutoCommit     => 1,
    sqlite_unicode => 1,
});

sub conn { $CONN }
sub dbh  { $CONN->dbh }
 ```

Simple, right? You pass exactly the same parameters to `DBIx::Connector->new`
that you passed to `DBI->connect`. The DBIx::Connector object simply proxies the
DBI. You want the database handle itself, just call `dbh()` and proceed as
usual, confident that if your app forks or spawns new threads, your database
handle will be safe. Why? Because DBIx::Connector detects such changes, and
re-connects to the database, being sure to properly dispose of the original
connection. But really, you don't have to worry about that, because
DBIx::Connector does the worrying for you.

#### Execution Methods

DBIx::Connector is very good at eliminating the [technical friction] of process
and thread management. But that's not all there is to it.

Although you can just fetch the DBI handle from your DBIx::Connector object and
go, a better approach is to use its execution methods. These methods scope
execution to a code block. Here's an example using [`run()`][]:

``` perl
$conn->run(sub {
    shift->do($query);
});
```

That may not seem so useful, and is more to type, but the real power comes from
the [`txn()`] method. `txn()` executes the code block within the scope of a
transaction. So where you normally would write something like this:

```perl
use Try::Tiny;
use MyApp::DBH;

my $dbh = MyApp::DBH->dbh;  
try {
    $dbh->begin_work;
    # do stuff...
    $dbh->commit;
} catch {
    $dbh->rollback;
    die $_;
};
```

The `try()` method scopes the transaction for you, so that you can just focus on
the work to be done and transaction management:

``` perl
use Try::Tiny;
use MyApp::DBH;

try {
    MyApp::DBH->conn->txn(sub {
        # do stuff...
    }
} catch {
    die $_;
};
```

There's no need to call `begin_work`, `commit`, or `rollback`, as `txn()` does
all that for you. Furthermore, it improves the maintainability of your code, as
the scope of the transaction is much more clearly defined as the scope of the
code block. Additional calls to `txn()` or `run()` within that block are
harmless, and just become part of the same transaction:

``` perl
MyApp::DBH->conn->txn(sub {
    my $dbh = shift;
    $dbh->do($_) for @queries;
    $conn->run(sub {
        shift->do($expensive_query);
        $conn->txn(sub {
            shift->do($another_expensive_query);
        });
    });
});
```

Even cooler is the [`svp()`] method, which scopes execution of a code block to a
savepoint, or subtransaction, if your database supports it (all of the drivers
currently supported by DBIx::Connector do). For example, this transaction will
commit the insertion of values 1 and 3, but not 2:

``` perl
MyApp::DBH->conn->txn(sub {
    my $dbh = shift;
    $dbh->do('INSERT INTO table1 VALUES (1)');
    try {
        $conn->svp(sub {
            shift->do('INSERT INTO table1 VALUES (2)');
            die 'OMGWTF?';
        });
    } catch {
           warn "Savepoint failed: $_\n";
    };
    $dbh->do('INSERT INTO table1 VALUES (3)');
});
```

#### Connection Management

The recommended pattern for using a cached DBI handle is to call [`ping()`] when
you fetch it from the cache, and reconnect if it returns false. Apache::DBI and
`connect_cached()` do this for you, and so does DBIx::Connector. However, in a
busy application `ping()` can get called *a lot*. [We] recently did some query
analysis for a client, and found that 1% of the database execution time was
taken up with `ping()` calls. That may not sound like a lot, but looking at the
numbers, it amounted to 100K pings *per hour*. For something that just returns
true 99.9\*% of the time, it seems a bit silly.

Enter DBIx::Connector [connection modes]. The default mode is "ping", as that's
what most installations are accustomed to. A second mode is "no\_ping", which
simply disables pings. I don't recommend that.

A better solution is to use "fixup" mode. This mode doesn't normally call
`ping()` either. However, if a code block passed to `run()` or `txn()` throws an
exception, *then* DBIx::Connector will call `ping()`. If it returns false,
DBIx::Connector reconnects to the database and executes the code block again.
This configuration should handle some common situations, such as idle timeouts,
without bothering you about it.

Specify "fixup" mode whenever you call an execution method, like so:


``` perl
$conn->txn(fixup => sub { ... });
```


You can also specify that your connection always use "fixup" via the [`fixup()`]
accessor. Modify the caching library like so (line 8 is new):

``` perl
my $CONN = DBIx::Connector->new('DBI:SQLite:dbname=myapp.db', '', '', {
    PrintError     => 0,
    RaiseError     => 1,
    AutoCommit     => 1,
    sqlite_unicode => 1,
});

$CONN->mode('fixup'); # ⬅ ⬅ ⬅  enter fixup mode!

sub conn { $CONN }
sub dbh  { $CONN->dbh }
```

However, you must be more careful with fixup mode than with ping mode, because a
code block can be executed twice. So you must be sure to write it such that
there are no side effects to multiple executions. Don't do this, for example:

``` perl
my $count = 0;
$conn->txn(fixup => sub {
    shift->do('INSERT INTO foo (count) VALUES(?)', undef, ++$count);
});
say $count; # may be 1 or 2
```

Will it insert a value of `1` or `2`? It's much safer to remove
non-transactional code from the block, like so:

``` perl
my $count = 0;
++$count;
$conn->txn(fixup => sub {
    shift->do('INSERT INTO foo (count) VALUES(?)', undef, $count);
});
say $count; # can only be 1
```

An even trickier pattern to watch out for is something like this:

``` perl
my $user = 'rjbs';
$conn->run(fixup => sub {
    my $dbh = shift;
    $dbh->do('INSERT INTO users (nick) VALUES (?)', undef, $user);

    # Do some other stuff...

    $dbh->do('INSERT INTO log (msg) VALUES (?)', undef, 'Created user');
});
 ```

If the database disconnects between the first and second calls to `do`, and
DBIx::Connector manages to re-connect and run the block again, you might get a
unique key violation on the first call to `do`. This is because we've used the
`run()` method. In the fist execution of the block, user "rjbs" was inserted and
autocommitted. On the second call, user "rjbs" is already there, and because
it's a username, we get a unique key violation.

The rule of thumb here is to use `run()` only for database reads, and to use
`txn()` (and `svp()`) for writes. `txn()` will ensure that the transaction is
rolled back, so the second execution of the code block will be side-effect-free.

#### Pedigree

DBIx::Connector is derived from patterns originally implemented for
[DBIx::Class], though it's nearly all original code. The upside for those of us
who don't use ORMs is that we get this independent piece of ORM-like behavior
without its ORMishness. So if you're a database geek like me, DBIx::Connector is
a great way to reduce [technical friction] without buying into the whole idea of
an ORM.

As it turns out, [DBIx::Connector] is good not just for straight-to-database
users, but also for ORMs. Both [DBIx::Class] and [Rose::DB] have plans to
replace their own caching and transaction-handling implementations with
DBIx::Connector under the hood. That will be great for everyone, as the problems
will all be solved in this one place.

<small>This post [originally appeared] on the  *Perl Advent Calendar 2011.*</small>

  [DBI]: https://metacpan.org/module/DBI
  [Apache::DBI]: https://metacpan.org/module/Apache::DBI
  [`connect_cached()`]: https://metacpan.org/module/DBI#connect_cached
  [work around this issue via callbacks]:
    {{% ref "/post/past/perl/dbi-connect-cached-hack" %}}
  [doing your own exception-handling is surprisingly non-trivial]:
    http://perladvent.org/2011/2011-12-17.html
  [DBIx::Connector]: https://metacpan.org/module/DBIx::Connector
  [technical friction]:
    http://www.modernperlbooks.com/mt/2011/11/on-technical-friction.html
  [`run()`]: https://metacpan.org/module/DBIx::Connector#run
  [`txn()`]: https://metacpan.org/module/DBIx::Connector#txn
  [`svp()`]: https://metacpan.org/module/DBIx::Connector#svp
  [`ping()`]: https://metacpan.org/module/DBI#ping
  [We]: http://pgexperts.com/
  [connection modes]: https://metacpan.org/module/DBIx::Connector#Connection-Modes
  [`fixup()`]: https://metacpan.org/module/DBIx::Connector#fixup
  [DBIx::Class]: https://metacpan.org/module/DBIx::Class
  [Rose::DB]: https://metacpan.org/module/Rose::DB
  [originally appeared]: http://perladvent.org/2011/2011-12-22.html
    "Perl Advent Calendar 2011: “Less Tedium, More Transactions”"