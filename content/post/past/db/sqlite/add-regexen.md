--- 
date: 2006-01-13T16:08:17Z
slug: add-regexen
title: Add Regular Expression Operator to SQLite
aliases: [/computers/databases/sqlite/add_regexen.html]
tags: [SQLite, Perl, Regular Expressions, DBD::SQLite, DBI, Matt Sergeant]
type: post
---

As I [discussed] a couple of months ago, [DBD::SQLite] exposes the [SQLite]
`sqlite3_create_function()` API for adding Pure-Perl functions and aggregates to
SQLite on a per-connection basis. This is cool, but in perusing the [SQLite
expression] documentation, I came across this gem:

> The `REGEXP` operator is a special syntax for the `regexp()` user function. No
> `regexp()` user function is defined by default and so use of the `REGEXP`
> operator will normally result in an error message. If a user-defined function
> named “regexp” is defined at run-time, that function will be called in order
> to implement the `REGEXP` operator.

*Well hell!* I thought. *I can do that!*

In a brief search, I could find no further documentation of this feature, but
all it took was a little experimentation to figure it out. The `regexp()`
function should expect two arguments. The first is the regular expression, and
the second is the value to match. So it can be added to DBD::SQLite like this:

    $dbh = DBI->connect('dbi:SQLite:dbfile=test.db');
    $dbh->func('regexp', 2, sub {
        my ($regex, $string) = @_;
        return $string =~ /$regex/;
    }, 'create_function');

Yep, that's it! Now, I have my own module for handling database connections, and
I wanted to make sure that all of my custom functions are always present, every
time I connect to the database. In a `mod_perl` environment, you can end up with
a lot of connections, and a single process has the potential disconnect and
reconnect more than once (due to exceptions thrown by the database and whatnot).
The easiest way to ensure that the functions are always there as soon as you
connect and every time you connect, I learned thanks to a tip from Tim Bunce, is
to subclass the DBI and implement a `connected()` method. Here's what it looks
like:

    package MyApp::SQLite;
    use base 'DBI';

    package MyApp::SQLite::st;
    use base 'DBI::st';

    package MyApp::SQLite::db;
    use base 'DBI::db';

    sub connected {
        my $dbh = shift;
        # Add regexp function.
        $dbh->func('regexp', 2, sub {
            my ($regex, $string) = @_;
            return $string =~ /$regex/;
        }, 'create_function');
    }

So how does this work? Here's a quick app I wrote to demonstrate the use of the
`REGEXP` expression in SQLite using Perl regular expressions:

    #!/usr/bin/perl -w

    use strict;

    my $dbfile = shift || die "Usage: $0 db_file\n";
    my $dbh = MyApp::SQLite->connect(
        "dbi:SQLite:dbname=$dbfile", '', '',
        {
            RaiseError  => 1,
            PrintError  => 0,
        }
    );

    END {
        $dbh->do('DROP TABLE try');
        $dbh->disconnect;
    }

    $dbh->do('CREATE TABLE try (a TEXT)');

    my $ins = $dbh->prepare('INSERT INTO try (a) VALUES (?)');
    for my $val (qw(foo bar bat woo oop craw)) {
        $ins->execute($val);
    }

    my $sel = $dbh->prepare('SELECT a FROM try WHERE a REGEXP ?');

    for my $regex (qw( ^b a w?oop?)) {
        print "'$regex' matches:\n  ";
        print join "\n  " =>
            @{ $dbh->selectcol_arrayref($sel, undef, $regex) };
        print "\n\n";
    }

This script outputs:

    '^b' matches:
      bar
      bat

    'a' matches:
      bar
      bat
      craw

    'w?oop?' matches:
      foo
      woo
      oop

Pretty slick, no? I wonder if it'd make sense for DBD::SQLite to add the
`regexp()` function itself, in C, using the Perl API, so that it's just *always*
available to DBD::SQLite apps?

  [discussed]: http://www.justatheory.com/computers/databases/sqlite/custom_perl_aggregates.html
    "Custom Aggregates in Perl"
  [DBD::SQLite]: http://search.cpan.org/dist/DBD-SQLite/ "DBD::SQLite on CPAN"
  [SQLite]: http://www.sqlite.org/ "Learn all about SQLite"
  [SQLite expression]: http://www.sqlite.org/lang_expr.html
    "Query Language Understood by SQLite: expression"
