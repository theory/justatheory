--- 
date: 2009-10-05T23:11:52Z
slug: dbix-connector
title: Database Handle and Transaction Management with DBIx::Connector
aliases: [/computers/programming/perl/modules/dbix-connector.html]
tags: [Perl, DBI, DBix::Class, DBIx::Connector, Transactions, Savepoints]
type: post
---

As part of my ongoing effort to wrestle Catalyst into working the way that *I*
think it should work, I've just uploaded [DBIx::Connector] to the CPAN. See, I
was using [Catalyst::Model::DBI], but it turned out that I wanted to use the
database handle in places other than the Catalyst parts of [my app]. I was
bitching about this to [mst] on \#catalyst, and he said that
Catalyst::Model::DBI was actually a fork of DBIx::Class's handle caching, and
quite out of date. I said, “But this already exists. It's called
[`connect_cached()`].” I believe his response was, “OH FUCK OFF!”

So I started digging into what Catalyst::Model::DBI and DBIx::Class do to cache
their database handles, and how it differs from `connect_cached()`. It turns out
that they were pretty smart, in terms of checking to see if the process had
forked or a new thread had been spawned, and if so, deactivating the old handle
and then returning a new one. Otherwise, things are just cached. This approach
works well in Web environments, including under [mod\_perl]; in forking
applications, like [POE] apps; and in plain Perl scripts. Matt said he'd always
wanted to pull that functionality out of DBIx::Class and then make DBIx::Class
depend on the external implementation. That way everyone could take advantage of
the functionality, including people like me who don't want to use an ORM.

So I did it. Maybe it was crazy (mmmmm…yak meat), but I can now use the same
database interface in the Catalyst and POE parts of my application without
worry:

    my $dbh = DBIx::Connector->connect(
        'dbi:Pg:dbname=circle', 'postgres', '', {
            PrintError     => 0,
            RaiseError     => 0,
            AutoCommit     => 1,
            HandleError    => Exception::Class::DBI->handler,
            pg_enable_utf8 => 1,
        },
    );

    $dbh->do($sql);

But it's not just database handle caching that I've included in DBIx::Connector;
no, I've also stolen some of the transaction management stuff from DBIx::Class.
All you have to do is grab the connector object which encapsulates the database
handle, and take advantage of its `txn_do()` method:

    my $conn = DBIx::Connector->new(@args);
    $conn->txn_do(sub {
        my $dbh = shift;
        $dbh->do($_) for @queries;
    });

The transaction is scoped to the code reference passed to `txn_do()`. Not only
that, it avoids the overhead of calling `ping()` on the database handle unless
something goes wrong. Most of the time, nothing goes wrong, the database is
there, so you can proceed accordingly. If it is gone, however, `txn_do()` will
re-connect and execute the code reference again. The cool think is that you will
never notice that the connection was dropped -- unless it's still gone after the
second execution of the code reference.

And finally, thanks to some pushback from mst, [ribasushi], and others, I added
[savepoint] support. It's a little different than that provided by DBIx::Class;
instead of relying on a magical `auto_savepoint` attribute that subtly changes
the behavior of `txn_do()`, you just use the `svp_do()` method from within
`txn_do()`. The scoping of subtransactions is thus nicely explicit:

    $conn->txn_do(sub {
        my $dbh = shift;
        $dbh->do('INSERT INTO table1 VALUES (1)');
        eval {
            $conn->svp_do(sub {
                shift->do('INSERT INTO table1 VALUES (2)');
                die 'OMGWTF?';
            });
        };
        warn "Savepoint failed\n" if $@;
        $dbh->do('INSERT INTO table1 VALUES (3)');
    });

This transaction will insert the values 1 and 3, but not 2. If you call
`svp_do()` outside of `txn_do()`, it will call `txn_do()` for you, with the
savepoint scoped to the entire transaction:

    $conn->svp_do(sub {
        my $dbh = shift;
        $dbh->do('INSERT INTO table1 VALUES (4)');
        $conn->svp_do(sub {
            shift->do('INSERT INTO table1 VALUES (5)');
        });
    });

This transaction will insert both 3 and 4. And note that you can nest savepoints
as deeply as you like. All this is dependent on whether the database supports
savepoints; so far, PostgreSQL, MySQL (InnoDB), Oracle, MSSQL, and SQLite do. If
you know of others, fork the [repository], commit changes to a branch, and send
me a pull request!

Overall I'm very happy with this module, and I'll probably use it in all my Perl
database projects from here on in. Perhaps later I'll build a model class on it
(something like Catalyst::Model::DBI, only better!), but next up, I plan to
finish documenting [Template::Declare] and writing some views with it. More on
that soon.

  [DBIx::Connector]: https://metacpan.org/pod/DBIx::Connector
    "DBIx::Connector on the CPAN"
  [Catalyst::Model::DBI]: https://metacpan.org/pod/Catalyst::Model::DBI
    "Catalyst::Model::DBI the CPAN"
  [my app]: https://github.com/theory/circle/ "Circle on GitHub"
  [mst]: http://www.trout.me.uk/ "Matt S Trout"
  [`connect_cached()`]: {{% ref "/post/past/perl/dbi-connect-cached-hack.md" %}}
    "Keep DBI's connect_cached From Horking Transactions"
  [mod\_perl]: https://perl.apache.org
  [POE]: https://metacpan.org/pod/POE "POE on CPAN"
  [ribasushi]: https://github.com/ribasushi
  [savepoint]: https://en.wikipedia.org/wiki/Savepoint "Wikipedia: “Savepoint”"
  [repository]: https://github.com/ap/DBIx-Connector
    "DBIx::Connector on GitHub"
  [Template::Declare]: https://metacpan.org/pod/Template::Declare
    "Template::Declare on the CPAN"
