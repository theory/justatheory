--- 
date: 2005-10-31T23:47:58Z
slug: custom-perl-aggregates
title: Custom Aggregates in Perl
aliases: [/computers/databases/sqlite/custom_perl_aggregates.html]
tags: [SQLite, API, Perl, Postgres]
type: post
---

About a year ago, [Josh Berkus] was reviewing some Bricolage SQL code, looking
to optimize it for PostgreSQL. One of the things he noticed was that we were
fetching a lot more rows for an object than we needed to. The reason for this is
that an object might be associated with one or more groups, and to get back a
list of all of the group IDs, we were getting multiple rows. For example, if I
wanted to fetch a single story with the ID 10, I might get back rows like this:

    SELECT s.id, s.title, grp.id
    FROM   story s, member m, grp g
    WHERE  s.id = m.story_id
           AND m.grp_id = g.id
           AND s.id = 10;
    s.id |        s.title      | grp.id
    -----+---------------------+--------
      10 | The Princess Bride  | 23
      10 | The Princess Bride  | 24
      10 | The Princess Bride  | 25
      10 | The Princess Bride  | 26
      10 | The Princess Bride  | 27

Now, that's a lot of extra data to have to fetch for just a single row to be
different; it's very wasteful, really. So Josh said, “Why don't you use a custom
aggregate for that?” I knew nothing about aggregates, but I did some research,
and figured out how to write PostgreSQL custom aggregates in SQL. I wrote a very
simple one, called `id_list()`, that joins up all of the values in a column with
an empty space. The aggregate code looks like this:

    CREATE   FUNCTION append_id(TEXT, INTEGER)
    RETURNS  TEXT AS '
        SELECT CASE WHEN $2 = 0 THEN
                    $1
               ELSE
                    $1 || '' '' || CAST($2 AS TEXT)
               END;'
    LANGUAGE 'sql'
    WITH     (ISCACHABLE, ISSTRICT);

    CREATE AGGREGATE id_list (
        SFUNC    = append_id,
        BASETYPE = INTEGER,
        STYPE    = TEXT,
        INITCOND = ''
    );

Now I was able to vastly simplify the results returned by the query:

    SELECT s.id, s.title, id_list(grp.id)
    FROM   story s, member m, grp g
    WHERE  s.id = m.story_id
           AND m.grp_id = g.id
           AND s.id = 10;
    GROUP BY s.id, s.title
    s.id |        s.title      | id_list
    -----+---------------------+---------------
      10 | The Princess Bride  | 23 24 25 26 27

So then I just had to split the `id_list` column on the white space and I was
ready to go. Cool!

So recently, was thinking about how I might do something similar in SQLite. It
turns out that SQLite has a way to add custom aggregates, too, via its
[`sqlite_add_function`] function. But I don't know C, and had been wondering for
a while how, even if I figured out how to write an aggregate function in C,
whether I would have to require users to compile SQLite with my C aggregate in
order to get it to work.

However, as a Perl developer, I thought it might be worthwhile to just quickly
check the [DBD::SQLite] docs might have to say on the matter. And it turns out
that the ability to add aggregates to SQLite is supported in DBD::SQLite via the
`create_aggregate` custom function. And what's more, the aggregate can be
written in Perl! Whoa! I couldn't believe that it could be that easy, but a
quick test script demonstrated that it is:

    #!/usr/bin/perl -w

    use strict;

    use DBI;

    my $dbfile = shift;
    my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile", '', '');

    END {
        $dbh->disconnect;
        unlink $dbfile;
    };

    $dbh->do('CREATE TABLE foo (a int)');
    $dbh->do('BEGIN');
    $dbh->do('INSERT INTO foo (a) VALUES (?)', undef, $_) for 1..10;
    $dbh->do('COMMIT');

    # Create a new aggregate.
    $dbh->func('joiner', 1, 'My::Join', 'create_aggregate');

    my $sel = $dbh->prepare(q{SELECT joiner(a) FROM foo});
    $sel->execute;
    $sel->bind_columns(\my $val);
    print "$val\n" while $sel->fetch;

The first argument to `create_aggregate()` (itself invoked via the DBI `func()`
method) the name of the aggregate, the second is the number of arguments to the
aggregate (use -1 for an unlimited number), and the third is the name of a Perl
class that implements the aggregate. That class needs just three methods:
`new()`, an object constructor; `step()`, called for each aggregate row, and
`finalize`, which must return the value calculated by the aggregate. My simple
implementation looks like this:

    package My::Join;

    sub new { bless [] }
    sub step {
        my $self = shift;
        push @$self, @_;
    }
    sub finalize {
        my $self = shift;
        return join q{ }, @$self;
    }

Yep, that's really it! When I run the script, the output looks like this:

    % try foo
    1 2 3 4 5 6 7 8 9 10

Keen! I mean, that is just *so* slick! And it really demonstrates the power of
SQLite as an embeddable database, as well. Thanks [Matt], for making the SQLite
API available to us mere mortal Perl developers!

  [Josh Berkus]: http://blogs.ittoolbox.com/database/soup/
    "Josh Berkus's Database Soup"
  [`sqlite_add_function`]: http://www.sqlite.org/capi3ref.html#sqlite3_create_function
    "C/C++ Interface For SQLite Version 3: sqlite_add_function"
  [DBD::SQLite]: http://search.cpan.org/dist/DBD-SQLite/ "DBD::SQLite on CPAN"
  [Matt]: http://www.sergeant.org/view/Matt "Matt Sergeant"
