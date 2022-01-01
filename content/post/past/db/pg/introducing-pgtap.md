--- 
date: 2008-06-07T05:24:27Z
slug: introducing-pgtap
title: Introducing pgTAP
aliases: [/computers/databases/postgresql/introducing_pgtap.html]
tags: [Postgres, TAP, Test Anything Protocol, Perl, Testing, Unit Testing]
type: post
---

So I started working on a new PostgreSQL data type this week. More on that soon;
in the meantime, I wanted to create a test suite for it, and wasn't sure where
to go. The only PostgreSQL tests I've seen are those distributed with Elein
Mustain's [tests] for the email data type she created in a [PostgreSQL General
Bits] posting from a couple of years ago. I used the same approach myself for my
[GTIN data type], but it was rather hard to use: I had to pay very close
attention to what was output in order to tell the description output from the
test output. It was quite a PITA, actually.

This time, I started down the same path, then then started thinking about Perl
testing, where each unit test, or “assertion,” in the xUnit parlance, triggers
output of a single line of information indicating whether or not a test
succeeded. It occurred to me that I could just run a bunch of queries that
returned booleans to do my testing. So my first stab looked something like this:

``` postgres
\set ON_ERROR_STOP 1
\set AUTOCOMMIT off
\pset format unaligned
\pset tuples_only
\pset pager
\pset null '[NULL]'

SELECT foo() = 'bar';
SELECT foo(1) = 'baz';
SELECT foo(2) = 'foo';
```

The output looked like this:

    % psql try -f ~/Desktop/try.sql
    t
    t
    t

Once I started down that path, and had written ten or so tests, It suddenly
dawned on me that the Perl [Test::More] module and its core `ok()` subroutine
worked just like that. It essentially just depends on a boolean value and
outputs text based on that value. A couple minutes of hacking and I had this:

``` postgres
CREATE TEMP SEQUENCE __tc__;
CREATE OR REPLACE FUNCTION ok ( boolean, text ) RETURNS TEXT AS $$
    SELECT (CASE $1 WHEN TRUE THEN '' ELSE 'not ' END) || 'ok'
        || ' ' || NEXTVAL('__tc__')
        || CASE $2 WHEN '' THEN '' ELSE COALESCE( ' - ' || $2, '' ) END;
$$ LANGUAGE SQL;
```

I then rewrote my test queries like so:

``` postgres
\echo 1..3
SELECT ok( foo() = 'bar'   'foo() should return "bar"' );
SELECT ok( foo(1) = 'baz', 'foo(1) should return "baz"' );
SELECT ok( foo(2) = 'foo', 'foo(2) should return "foo"' );
```

Running these tests, I now got:

    % psql try -f ~/Desktop/try.sql
    1..3
    ok 1 - foo() should return "bar"
    ok 2 - foo(1) should return "baz"
    ok 3 - foo(2) should return "foo"

And, ***BAM!*** I had the beginning of a test framework that emits pure [TAP]
output.

Well, I was so excited about this that I put aside my data type for a few hours
and banged out the rest of the framework. Why was this exciting to me? Because
now I can use a standard test harness to run the tests, even mix them in with
other TAP tests on any project I might work on. Just now, I quickly hacked
together a quick script to run the tests:

``` perl
use TAP::Harness;

my $harness = TAP::Harness->new({
    timer   => $opts->{timer},
    exec    => [qw( psql try -f )],
});

$harness->runtests( @ARGV );
```

Now I'm able to run the tests like so:

    % try ~/Desktop/try.sql        
    /Users/david/Desktop/try........ok   
    All tests successful.
    Files=1, Tests=3,  0 wallclock secs ( 0.00 usr  0.00 sys +  0.01 cusr  0.00 csys =  0.01 CPU)
    Result: PASS

Pretty damn cool! And lest you wonder whether such a suite of TAP-emitting test
functions is suitable for testing SQL, here are a few examples of tests I've
written:

``` postgres
-- Plan the tests.
SELECT plan(4);

-- Emit a diagnostic message for users of different locales.
SELECT diag(
    E'These tests expect LC_COLLATE to be en_US.UTF-8,\n'
    || 'but yours is set to ' || setting || E'.\n'
    || 'As a result, some tests may fail. YMMV.'
)
    FROM pg_settings
    WHERE name = 'lc_collate'
    AND setting <> 'en_US.UTF-8';

SELECT is( 'a', 'a', '"a" should = "a"' );
SELECT is( 'B', 'B', '"B" should = "B"' );

CREATE TEMP TABLE try (
    name lctext PRIMARY KEY
);

INSERT INTO try (name)
VALUES ('a'), ('ab'), ('â'), ('aba'), ('b'), ('ba'), ('bab'), ('AZ');

SELECT ok( 'a' = name, 'We should be able to select the value' )
    FROM try
    WHERE name = 'a';

SELECT throws_ok(
    'INSERT INTO try (name) VALUES (''a'')',
    '23505',
    'We should get an error inserting a lowercase letter'
);

-- Finish the tests and clean up.
SELECT * FROM finish();
```

As you can see, it's just SQL. And yes, I have ported most of the test functions
from [Test::More], as well as a couple from [Test::Exception].

So, without further ado, I'd like to introduce [pgTAP], a lightweight test
framework for PostgreSQL implemented in PL/pgSQL and PL/SQL. I'll be hacking on
it more in the coming days, mostly to get a proper client for running tests
hacked together. Then I think I'll see if pgFoundry is interested in it.

Whaddya think? Is this something you could use? I can see many uses, myself, not
only for testing a custom data type as I develop it, but also custom functions
in PL/pgSQL or PL/Perl, and, heck, just regular schema stuff. I've had to write
a lot of Perl tests to test my database schema (triggers, rules, functions,
etc.), all using the DBI and being very verbose. Being able to do it all in a
single psql script seems so much cleaner. And if I can end up mixing the output
of those scripts in with the rest of my unit tests, so much the better!

Anyway, feedback welcome. Leave your comments, suggestions, complaints, patches,
etc., below. Thanks!

  [tests]: http://www.varlena.com/GeneralBits/Tidbits/email_test.sql
    "Testing the email data type"
  [PostgreSQL General Bits]: http://www.varlena.com/GeneralBits/128.php
    "Base Type using Domains"
  [GTIN data type]: https://github.com/theory/gtin "GTIN data type project info"
  [Test::More]: https://metacpan.org/pod/Test::More "Test::More on CPAN"
  [TAP]: http://testanything.org/ "Test Anything Protocol"
  [Test::Exception]: https://metacpan.org/pod/Test::Exception
    "Test::Exception on CPAN"
  [pgTAP]: https://github.com/theory/pgtap/ "pgTAP Git repository"
