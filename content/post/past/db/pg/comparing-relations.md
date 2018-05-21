--- 
date: 2009-06-01T22:13:00Z
slug: comparing-relations
title: Thoughts on Testing SQL Result Sets
aliases: [/computers/databases/postgresql/comparing-relations.html]
tags: [Postgres, pgTAP, SQL]
type: post
---

### pgTAP: The Critique

I've been continuing hacking on [pgTAP] in order to add a lot more
schema-testing functionality and a few other niceties. But back when I started
the project, I using it to write tests for [CITEXT], which was great for my
sanity as I developed it, but proved a bit controversial. In a [pgsql-hackers
post], Tom Lane wrote:

> There was some discussion earlier about whether the proposed regression tests
> for citext are suitable for use in contrib or not. After playing with them for
> awhile, I have to come down very firmly on the side of "not". I have these
> gripes:
>
> 1.  The style is gratuitously different from every other regression test in
>     the system. This is not a good thing. If it were an amazingly better way
>     to do things, then maybe, but as far as I can tell the style pgTAP forces
>     on you is really pretty darn poorly suited for SQL tests. You have to
>     contort what could naturally be expressed in SQL as a table result into a
>     scalar. Plus it’s redundant with the expected-output file.
>
> 2.  It’s ridiculously slow; at least a factor of ten slower than doing
>     equivalent tests directly in SQL. This is a very bad thing. Speed of
>     regression tests matters a lot to those of us who run them a dozen times
>     per day —– and I do not wish to discourage any developers who don’t work
>     that way from learning better habits ;–)
>
> Because of \#1 and \#2 I find the use of pgTAP to be a nonstarter.

These are legitimate criticisms, of course. To take the second item first, I
would eventually like to figure out a way to make pgTAP a lot faster (in my own
benchmarks, I found it to be about 4 times slower than pure SQL, not ten times,
but still). A number of functions can likely be rewritten in C, and maybe data
can be stored in memory rather than in a temporary table. Overall, though, the
speed of the tests doesn’t really concern me much. I'm quite used to large test
suites, such as that for [Bricolage], that take 5 or 10 minutes or more. This is
because, compared to the time it would take me to maintain the code without
tests, it’s nothing. I find and fix bugs much more quickly thanks to regression
tests. And really, one should just run a subset of the tests for whatever one is
working on, and then run the full suite before checking in. One could even have
a larger, more comprehensive (read: slower) test suite that’s run via a cron
job, so that it identifies bugs in checked in code but developers don’t have to
spend a lot of time waiting for tests to finish running.

As a result, I wouldn’t advocate for converting the existing PostgreSQL
regression test suite to pgTAP. I could see writing a new suite of tests on
pgTAP that run on the [build farm]. This would be great, as they would
complement the existing test suite, and be able to test stuff that can’t be
tested with `pg_regress`.

So really, the performance issue can be addressed in a few ways, some technical,
some social, some structural. Like I said, I'm not overly concerned about it,
and I wouldn’t make Tom suffer unduly from it, either (I converted all of the
CITEXT tests to plain SQL).

### Coercing Composite Values

The first issue is tougher, however. Tom was responding to a test like this:

``` postgres
SELECT is(
    ARRAY( SELECT name FROM srt ORDER BY name )::text,
    ARRAY['AAA', 'aardvark', 'aba', 'ABC', 'abc']::text,
    'The words should be case-insensitively sorted'
);
```

Now, I agree that it’s redundant with the expected-output file, but the
assumption with [TAP] is that there *is no* expected output file: you just
analyze its output using a [harness]. The need for an expected output file is
driven by the legacy of `pg_regress`.

A bigger issue, and the one I'll focus on for the remainder of this post, is the
requirement currently inherent in pgTAP to “contort what could naturally be
expressed in SQL as a table result into a scalar.” The issue is apparent in the
above example: even though I'm selecting a number of rows from a table, I use
the `ARRAY()` constructor function to force them into a scalar value—an array—in
order to easily do the comparison. It also results in a useful diagnostic
message in case the test fails:

    # Failed test 40: "The words should be case-insensitively sorted"
    #         have: {AAA,aardvark,ABC,abc,aba}
    #         want: {AAA,aardvark,aba,ABC,abc}

So for simple cases like this, it doesn’t bother me much personally. But I've
also had to write tests for functions that return composite types—that is,
*rows*—and again I had to fall back on coercing them into scalar values to do
the comparison. For example, say that the `fooey()` function returns a `dude`
value, which is a composite type with an integer and a text string. Here’s how
to test it with pgTAP:

``` postgres
SELECT is(
    fooey()::text,
    ROW( 42, 'Bob' )::text,
    'Should get what we expect from fooey()'
);
```

So I'm again coercing a value into something else (of course, if I could pass
`record`s to functions, that issue goes away). And it does yield nice
diagnostics on failure:

    # Failed test 96: "Should get what we expect from fooey()"
    #         have: (42,Fred)
    #         want: (42,Bob)

It gets much worse with set returning functions—Tom’s “table result:” it
requires both type *and* row coercion (or “contortion” if you'd prefer). Here’s
an example of a `fooies()` function that returns a set of `dude`s:

``` postgres
SELECT is(
    ARRAY( SELECT ROW(f.*)::text FROM fooies() f ),
    ARRAY[
        ROW( 42, 'Fred' )::text,
        ROW( 99, 'Bob' )::text
    ],
    'Should get what we expect from fooies()'
);
```

As you can see, it’s do-able, but clumsy and error prone. We really are taking a
table result and turning into a scalar value. And thanks to the casts to `text`,
the test can actually incorrectly pass if, for example, the integer was actually
stored as text (although, to be fair, the same is true of a `pg_regress` test,
where *everything* is converted to text before comparing results).

What we *really* need is a way to write two queries and compare their *result
sets,* preferably without any nasty casts or coercion into scalar values, and
with decent diagnostics when a test fails.

As an aside, another approach is to use `EXCEPT` queries to make sure that two
data sets are the same:

``` postgres
SELECT ok(
    NOT EXISTS (
        (SELECT 42, 'Fred' UNION SELECT 99, 'Bob')
        EXCEPT
        SELECT * from fooies()
    ),
    'Should get what we expect from fooies()'
);

SELECT ok(
    NOT EXISTS (
        SELECT * from fooies()
        EXCEPT
        (SELECT 42, 'Fred' UNION SELECT 99, 'Bob')
    ),
    'Should have no unexpected rows from fooies()'
);
```

Here I've created two separate tests. The first makes sure that `fooies()`
returns all the expected rows, and the second makes sure that it doesn’t return
any unexpected rows. But since this is just a boolean test (yes, we've coerced
the results into booleans!), there are no diagnostics if the test fails: you'd
have to go ahead and run the query yourself to see what’s unexpected. Again,
this is do-able, and probably a more correct comparison than using the casts of
rows to `text`, but makes it harder to diagnose failures. And besides, `EXCEPT`
compares sets, which are inherently unordered. That means that if you need to
test that results come back in a specific order, you can’t use this approach.

That said, if someone knows of a way to do this in one query—somehow make some
sort of `NOT EXCEPT` operator work—I'd be very glad to hear it!

### Prior Art

pgTAP isn’t the only game in town. There is also Dmitry Koterov’s [PGUnit]
framework and Bob Brewer’s [Epic]. PGUnit seems to have one main assertion
function, `assert_same()`, which works much like pgTAP’s `is()`. Epic’s
`assert_equal()` does, too, but Epic also offers a few functions for testing
result sets that neither pgTAP nor PGUnit support. One such function is
`assert_rows()`, to which you pass strings that contain SQL to be evaluated. For
example:

``` plpgsql
CREATE OR REPLACE FUNCTION test.test_fooies() RETURNS VOID AS $_$
BEGIN
    PERFORM test.assert_rows(
        $$ VALUES(42, 'Fred'), (99, 'Bob') $$,
        $$ SELECT * FROM fooies()          $$
    );
    RAISE EXCEPTION '[OK]';
END;
$_$ LANGUAGE plpgsql;
```
This works reasonably well. Internally, Epic runs each query twice, using
`EXCEPT` to compare result sets, just as in my boolean example above. This
yields a proper comparison, and because `assert_rows()` iterates over returned
rows, it emits a useful message upon test failure:

    psql:try_epic.sql:21: ERROR:  Record: (99,Bob) from: VALUES(42, 'Fred'), (99, 'Bob') not found in: SELECT * FROM fooies()
    CONTEXT:  SQL statement "SELECT  test.assert_rows( $$ VALUES(42, 'Fred'), (99, 'Bob') $$, $$ SELECT * FROM fooies() $$ )"
    PL/pgSQL function "test_fooies" line 2 at PERFORM

A bit hard to read with all of the SQL exception information, but at least the
information is there. At [PGCon], Bob told me that passing strings of SQL code
made things a lot easier to implement in Epic, and I can certainly see how that
could be (pgTAP uses SQL code strings too, with its `throws_ok()`, `lives_ok()`,
and `performs_ok()` assertions). But it just doesn’t feel SQLish to me. I mean,
if you needed to write a really complicated query, it might be harder to
maintain: even using dollar quoting, it’s harder to track stuff. Furthermore,
it’s slow, as PL/pgSQL’s `EXECUTE` must be called twice and thus plan twice. And
don’t even try to test a query with side-effects—such as a function that inserts
a row and returns an ID—as the second run will likely lead to test failure just
might blow something up.

### SQL Blocks?

One approach is to use blocks. I'm thinking here of something like Ruby blocks
or Perl code references: a way to dynamically create some code that is compiled
and planned when it loads, but its execution can be deferred. In Perl it works
like this:

``` perl
my $code = sub { say "woof!" };
$code->(); # prints "woof!"
```

In Ruby (and to a lesser extent in Perl), you can pass a block to a method:

``` ruby
foo.bar { puts "woof!" }
```

The `bar` method can then run that code at its leisure. We can sort of do this
in PostgreSQL using `PREPARE`. To take advantage of it for Epic’s
`assert_rows()` function, one can do something like this:

``` plpgsql
CREATE OR REPLACE FUNCTION test.test_fooies() RETURNS VOID AS $_$
BEGIN
    PREPARE want AS VALUES(42, 'Fred'), (99, 'Bob');
    PREPARE have AS SELECT * FROM public.fooies();
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want $$),
        test.global($$ EXECUTE have $$)
    );
    RAISE EXCEPTION '[OK]';
END;
$_$ LANGUAGE plpgsql;
```

The nice thing about using a prepared statement is that you can actually write
all of your SQL in SQL, rather than in an SQL string, and then pass the simple
`EXECUTE` statement to `assert_rows()`. Also note the calls to `test.global()`
in this example. This is a tricky function in Epic that takes an SQL statement,
turns its results into a temporary table, and then returns the table name. This
is required for the `EXECUTE` statements to work properly, but a nice
side-effect is that the actual queries are executed only once each, to create
the temporary tables. Thereafter, those temporary tables are used to fetch
results for the test.

Another benefit of prepared statements is that you can write a query once and
use it over and over again in your tests. Say that you had a few set returning
functions that return different results from the `users` table. You could then
test them all like so:

``` plpgsql
CREATE OR REPLACE FUNCTION test.test_user_funcs() RETURNS VOID AS $_$
BEGIN
    PREPARE want(bool) AS SELECT * FROM users WHERE active = $1;
    PREPARE active     AS SELECT * FROM get_active_users();
    PREPARE inactive   AS SELECT * FROM get_inactive_users();
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want(true) $$),
        test.global($$ EXECUTE active     $$)
    );
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want(false) $$),
        test.global($$ EXECUTE inactive    $$)
    );
    RAISE EXCEPTION '[OK]';
END;
$_$ LANGUAGE plpgsql;
```

Note how I've tested both the `get_active_users()` and the
`get_inactive_users()` function by passing different values when executing the
`want` prepared statement. Not bad. I think that this is pretty SQLish, aside
from the necessity for `test.global()`.

Still, the use of prepared statements with Epic’s `assert_rows()` is not without
issues. There is still a lot of execution here (to create the temporary tables
and to select from them a number of times). Hell, this last example reveals an
inefficiency in the creation of the temporary tables, as the two different
executions of `have` create two separate temporary tables for data that’s
already in the `users` table. If you have a lot of rows to compare, a lot more
memory will be used. And you still can’t check the ordering of your results,
either.

So for small result sets and no need to check the ordering of results, this is a
pretty good approach. But there’s another.

### Result Set Handles

Rather than passing blocks to be executed by the tests, in many dynamic testing
frameworks you can pass data structures be compared. For example, [Test::More]’s
`is_deeply()` assertion allows you to test that two data structures contain the
same values in the same structures:

``` perl
is_deeply \@got_data, \@want_data, 'We should have the right stuff';
```

This does a deep comparison between the contents of the `@got_data` array and
`@want_data`. Similarly, I could imagine a test to check the contents of a
[DBIx::Class] result set object:

``` perl
results_are( $got_resultset, $want_resultset );
```

In this case, the `is_results()` function would iterate over the two result
sets, comparing each result to make sure that they were identical. So if
prepared statements in SQL are akin to blocks in dynamic languages, what is akin
to a result set?

The answer, if you're still with me, is *cursors*.

Now, cursors don’t work with Epic’s SQL-statement style tests, but I could
certainly see how a pgTAP function like this would be useful:

``` postgres
DECLARE want CURSOR FOR SELECT * FROM users WHERE active;
DECLARE have CURSOR FOR SELECT * FROM get_active_users();
SELECT results_are( 'want', 'have' );
```

The nice thing about this approach is that, even more than with prepared
statements, everything is written in SQL. The `results_are()` function would
simply iterate over each row returned from the two cursors to make sure that
they were the same. In the event that there was a difference, the diagnostic
output would be something like:

    #   Failed test 42:
    #     Results begin differing at row 3:
    #          have: (3,Larry,t)
    #          want: (3,Larry,f)

So there’s a useful diagnostic, ordering is preserved, no temporary tables are
created, and the data is fetched directly from its sources (tables or functions
or whatever) just as it would be in a straight SQL statement. You still have the
overhead of PL/pgSQL’s `EXECUTE`, and iterating over the results, but, outside
of some sort of `NOT INTERSECT` operator, I don’t see any other way around it.

### The Plan

So I think I'll actually look at adding support for doing this in two ways: one
with prepared statements (or query strings, if that’s what floats your boat)
like Epic does, though I'm going to look at avoiding the necessity for something
like Epic’s `global()` function. But I'll also add functions to test cursors.
And maybe a few combinations of these things.

So, does an approach like this, especially the cursor solution, address Tom’s
criticism? Does it feel more relational? Just to rewrite the kind of test Tom
originally objected to, it would now look something like this:

``` postgres
DECLARE have CURSOR FOR SELECT name FROM srt ORDER BY name;
DECLARE want CURSOR FOR VALUES ('AAA'), ('aardvark'), ('aba'), ('ABC'), ('abc');
SELECT results_are(
    'have', 'want',
    'The words should be case-insensitively sorted'
);
```

Thoughts? I'm not going to get to it this week, so feedback would be greatly
appreciated.

  [pgTAP]: http://pgtap.projects.postgresql.org/
    "pgTAP: Unit Testing for PostgreSQL"
  [CITEXT]: /computers/databases/postgresql/citext-patch-submitted.html
    "CITEXT Patch Submitted to PostgreSQL Contrib"
  [pgsql-hackers post]: http://archives.postgresql.org/pgsql-hackers/2008-07/msg00627.php
    "Tom Lane on pgsql-hackers: “Re: PATCH: CITEXT 2.0 v3”"
  [Bricolage]: http://www.bricolagecms.org/
    "Bricolage Content Management and Publishing System"
  [build farm]: http://buildfarm.postgresql.org/ "PostgreSQL Build Farm"
  [TAP]: http://testanything.org/ "TAP: Test Anything Protocol"
  [harness]: http://search.cpan.org/perldoc?TAP::Harness "TAP::Harness on CPAN"
  [PGUnit]: http://en.dklab.ru/lib/dklab_pgunit/
    "PGUnit: stored procedures unit-test framework for PostgreSQL 8.3"
  [Epic]: http://epictest.org/
    "Epic: more full of fail than any other testing tool"
  [PGCon]: https://www.pgcon.org/2009/ "The PostgreSQL Conference 2009"
  [Test::More]: http://search.cpan.org/perldoc?Test::More
  [DBIx::Class]: http://search.cpan.org/perldoc?DBIx::Class
