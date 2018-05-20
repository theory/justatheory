--- 
date: 2010-07-28T19:38:54Z
description: After some prodding from the MySQL Community Manager, some OSCON hacking yields tangible results.
slug: introducing-mytap
title: Introducing MyTAP
aliases: [/computers/databases/mysql/introducing_mysql.html]
tags: [MySQL, myTAP, pgTAP, testing, unit testing, Postgres, database, test-driven database development, test-driven database design]
type: post
---

I gave my [OSCON tutorial] ([slides]) last week. It went okay. I spent *way* too
much time helping to get everyone set up with [pgTAP], and then didn't have time
to have the attendees do the exercises, and I had to rush through 2.5 hours of
material in 1.5 hours. Yikes! At least the video will be better when it's
released (more when that happens).

But as often happens, I was asked whether something like pgTAP exists for
[MySQL]. But this time I was asked by MySQL Community Manager [Giuseppe Maxia],
who also said that he'd tried to create a test framework himself (a fellow Perl
hacker!), but that it wasn't as nice as pgTAP. Well, since I was at OSCON and
tend to like to hack on side projects while at conferences, and since I hoped
that Giuseppe will happily take it over once I've implemented the core, I
started hacking on it myself. And today, I'm pleased to announce the release of
[MyTAP] 0.01 ([downloads]).

Once you've downloaded it, install it against your MySQL server like so:

    mysql -u root < mytap.sql

Here's a very simple example script:

    -- Start a transaction.
    BEGIN;

    -- Plan the tests.
    SELECT tap.plan(1);

    -- Run the tests.
    SELECT tap.pass( 'My test passed, w00t!' );

    -- Finish the tests and clean up.
    CALL tap.finish();
    ROLLBACK;

You can run this test from a `.sql` file using the `mysql` client like so:

    mysql -u root --disable-pager --batch --raw --skip-column-names --unbuffered --database try --execute 'source test.sql'

But that's a PITA and can only run one test at a time. Instead, put all of your
tests into a directory, perhaps named `tests`, each with the suffix “.my”, and
use [`my_prove`] (install [TAP::Parser::SourceHandler::MyTAP] from CPAN to get
it) instead:

    my_prove -u root --database try tests/

For MyTAP's own tests, the output looks like this:

    tests/eq.my ........ ok
    tests/hastap.my .... ok
    tests/matching.my .. ok
    tests/moretap.my ... ok
    tests/todotap.my ... ok
    tests/utils.my ..... ok
    All tests successful.
    Files=6, Tests=137,  1 wallclock secs
    (0.06 usr  0.03 sys +  0.01 cusr  0.02 csys =  0.12 CPU)
    Result: PASS

Nice, eh? Of course there are quite a few more assertion functions. See the
[complete documentation] for details.

Now, I did my best to keep the interface the same as pgTAP, but there are a few
differences:

-   MySQL temporary tables are [teh suck], so I had to use permanent tables to
    track test state. To make this more feasible, MyTAP is always installed in
    its own database, (named “tap” by default), and you must always
    schema-qualify your use of the MyTAP functions.
-   Another side-effect of permanent tables is that MyTAP must keep track of
    test outcomes without colliding with the state from tests running in
    multiple concurrent connections. So MyTAP uses [`connection_id()`] to keep
    track of state for a single test run. It also deletes the state when tests
    `finish()`, but if there's a crash before then, data can be left in those
    tables. If the connection ID is ever re-used, this can lead to conflicts.
    This seems mostly avoidable by using [InnoDB] tables and transactions in the
    tests.
-   The word “is” is strictly reserved by MySQL, so the function that
    corresponds to pgTAP's `is()` is `eq()` in MyTAP. Similarly, `isnt()` is
    called `not_eq()` in MyTAP.
-   There is no way to throw an exception in MySQL functions an procedures, so
    the code cheats by instead performing an illegal operation: selecting from a
    non-existent column, where the name of that column is the error message.
    Hinky, but should get the point across.

Other than these issues, things went fairly smoothly. I finished up the 0.01
version last night and released it today with most of the core functionality in
place. And now I want to find others to take over, as I am not a MySQL hacker
myself and thus unlikely ever to use it. If you're interested, my
recommendations for things to do next are:

-   Move `has_table()` to its own file, named `mytap-schema.sql` or similar, and
    start porting the relevant pgTAP [table assertion functions], [schema
    assertion functions], [have assertion functions], [function and procedure
    assertion functions], and [assorted other database object assertion
    functions].

-   Consider an approach to porting the [pgTAP relation comparison assertion
    functions], perhaps by requiring that prepared statements be created and
    their names passed to the functions. The functions can then select from the
    prepared statements into temporary tables to compare results (as in
    `set_eq()` and `bag_eq()`), or use cursors to iterate over the prepared
    statements row-by-row (as in `results_eq()`)

-   Set up a mail list and a permanent home for MyTAP (I've used GitHub pages
    for the [current site], but I don't think it should remain tightly
    associated with my GitHub identity). I'd like to see some folks from the
    MySQL community jump on this.

So fork on [GitHub] or contact me if you'd like to be added as a collaborator
(I'm looking at *you,* [Giuseppe][Giuseppe Maxia]!).

Hope you find it useful.

  [OSCON tutorial]: http://www.oscon.com/oscon2010/public/schedule/detail/14168
    "Test Driven Database Development"
  [slides]: https://www.slideshare.net/justatheory/test-drivern-database-development
    "slides on SlideShare"
  [pgTAP]: http://pgtap.org/
  [MySQL]: http://www.mysql.com/
  [Giuseppe Maxia]: http://datacharmer.blogspot.com/
  [MyTAP]: http://github.com/theory/mytap/
  [downloads]: http://github.com/theory/mytap/downloads
  [`my_prove`]: http://search.cpan.org/perldoc?my_prove
  [TAP::Parser::SourceHandler::MyTAP]: http://search.cpan.org/dist/TAP-Parser-SourceHandler-MyTAP/
  [complete documentation]: http://theory.github.com/mytap/documentation.html
  [teh suck]: http://dev.mysql.com/doc/refman/5.0/en/temporary-table-problems.html
  [`connection_id()`]: http://dev.mysql.com/doc/refman/5.0/en/information-functions.html#function_connection-id
  [InnoDB]: http://dev.mysql.com/doc/refman/5.0/en/innodb.html
  [table assertion functions]: http://pgtap.org/documentation.html#Table+For+One
  [schema assertion functions]: http://pgtap.org/documentation.html#The+Schema+Things
  [have assertion functions]: http://pgtap.org/documentation.html#To+Have+or+Have+Not
  [function and procedure assertion functions]: http://pgtap.org/documentation.html#Feeling+Funky
  [assorted other database object assertion functions]: http://pgtap.org/documentation.html#Database+Deets
  [pgTAP relation comparison assertion functions]: http://pgtap.org/documentation.html#Pursuing+Your+Query
  [current site]: http://theory.github.com/mytap/
  [GitHub]: http://github.com/theory/mytap/ "MyTAP on GitHub"
