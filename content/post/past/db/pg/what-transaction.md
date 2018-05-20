--- 
date: 2004-10-15T23:13:53Z
slug: what-transaction
title: How to Determine Your Transaction ID
aliases: [/computers/databases/postgresql/what_transaction.html]
tags: [Postgres, SQL, DBI, DBD::Pg, Perl]
type: post
---

Today I had reason to find out what PostgreSQL transaction I was in the middle
of at any given moment in Bricolage. Why? I wanted to make sure that a single
request was generating multiple transactions, instead of the normal one. It's a
long story, but suffice it to say that lengthy transactions were causing
deadlocks. Read [this] if you're really interested.

Anyway, here's how to determine your current transaction using DBI. The query
will be the same for any client, of course.

    my $sth = $dbh->prepare(qq{
        SELECT transaction
        FROM   pg_locks
        WHERE  pid = pg_backend_pid()
               AND transaction IS NOT NULL
        LIMIT  1
    });

    $sth->execute;
    $sth->bind_columns(\my $txid);
    $sth->fetch;
    print "Transaction: $txid\n";

  [this]: http://bugs.bricolage.cc/show_bug.cgi?id=709#c19
    "Bug report: Deadlocks during Bricolage publishes"
