--- 
date: 2010-06-03T05:19:10Z
slug: handling-multiple-perl-exceptions
title: Handling Multiple Exceptions
aliases: [/computers/programming/perl/handling-multiple-exceptions.html]
tags: [Perl, Exception Handling]
type: post
---

I ran into an issue with [DBIx::Connector] tonight: [SQLite] started throwing an
exception from within a call to `rollback()`: “DBD::SQLite::db rollback failed:
cannot rollback transaction – SQL statements in progress”. This is rather
annoying, as it ate the underlying exception that led to the rollback.

So I've added a test to DBIx::Connector that looks like this:

``` perl
my $dmock = Test::MockModule->new($conn->driver);
$dmock->mock(rollback => sub { die 'Rollback WTF' });

eval { $conn->txn(sub {
    my $sth = shift->prepare("select * from t");
    die 'Transaction WTF';
}) };

ok my $err = $@, 'We should have died';
like $err, qr/Transaction WTF/, 'Should have the transaction error';
```

It fails as expected: the error is “Rollback WTF”. So far so good. Now the
question is, how should I go about fixing it? Ideally I'd be able to access
*both* exceptions in whatever exception handling I do. How to go about that?

I see three options. The first is that taken by [Bricolage] and [DBIx::Class][]:
create a new exception that combines both the transaction exception and the
rollback exception into one. DBIx::Class does it like this:

``` perl
$self->throw_exception(
    "Transaction aborted: ${exception}. "
    . "Rollback failed: ${rollback_exception}"
);
```

That’s okay as far as it goes. But what if `$exception` is an
[Exception::Class::DBI] object, or some other exception object? It would get
stringified and the exception handler would lose the advantages of the object.
But maybe that doesn’t matter so much, since the rollback exception is kind of
important to address first?

The second option is to throw a new exception object with the original
exceptions as attributes. Something like (pseudo-code):

``` perl
DBIx::Connector::RollbackException->new(
    txn_exception      => $exception,
    rollback_exception => $rollback_exception,
);
```

This has the advantage of keeping the original exception as an object, although
the exception handler would have to expect this exception and go digging for it.
So far in DBIx::Connector, I've left DBI exception construction up to the DBI
and to the consumer, so I'm hesitant to add a one-off special-case exception
object like this.

The third option is to use a special variable, `@@`, and put both exceptions
into it. Something like:

``` perl
@@ = ($exception, $rollback_exception);
die $rollback_exception;
```

This approach doesn’t require a dependency like the previous approach, but the
user would still have to know to dig into `@@` if they caught the rollback
exception. But then I might as well have thrown a custom exception object that’s
easier to interrogate than an exception string. Oh, and is it appropriate to use
`@@`? I seem to recall seeing some discussion of this variable on the
perl5-porters mail list, but it’s not documented or supported. Or something.
Right?

What would you do?

  [DBIx::Connector]: https://metacpan.org/pod/DBIx::Connector
  [SQLite]: https://www.sqlite.org
  [Bricolage]: http://www.bricolagecms.org/
  [DBIx::Class]: https://metacpan.org/pod/DBIx::Class
  [Exception::Class::DBI]: https://metacpan.org/pod/Exception::Class::DBI
