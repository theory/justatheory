--- 
date: 2009-05-11T19:59:12Z
description: More thoughts on they whys and hows of database testing, and wondering why one might think that it’s pointless or useless.
slug: more-on-database-testing
title: More on Database Testing
aliases: [/computers/databases/more-on-database-testing.html]
tags: [Databases, Databases, SQL, Testing, Unit Testing, pgTAP, Postgres]
type: post
---

I've been meaning for a while to come back to the topic of [database testing].
After posting that entry, I thought more about the quote from a PostgreSQL core
hacker, which I think bears repeating:

> Well, you are testing for bugs, and bugs are pretty specific in where they
> appear. Writing the tests is 90% of the job; writing the infrastructure is
> minor. If the infrastructure has limitations, which all do, you might as well
> write that extra 10% too.

I had been so focused on the first sentence, on the *why* of database testing,
that I'd not rally addressed the rest. I failed to notice that he was
questioning the utility of a testing *infrastructure,* or what I would call a
framework, like [pgTAP]. So let me rectify that right now by addressing his
actual point.

The idea of using an established framework and [protocol] is to be able to focus
exclusively on the task of writing tests, rather than worrying about how to
analyze test results. I agree that writing tests can be time-consuming, but that
doesn't mean that one should write one's own testing framework. The great thing
about pgTAP is that it emits TAP, which can then be analyzed along with any
other TAP-emitting test framework in any environment, including [Perl], [C],
[JavaScript], [PHP], and even [Oracle], among others.

The other argument that might support writing one's own testing infrastructure
is if it's too hard to apply one style of testing to a given application. For
example, most of the existing [TAP producers] provide a functional interface to
writing tests. SQL, on the other hand, is not a functional language. So--leaving
aside for the moment that one can provide an effective [functional interface]
for writing database tests--even if one wanted to write a relational-style
testing framework, it could still emit TAP! TAP is, after all, just a stream of
text. So as long as a SQL `SELECT` statement returns a stream of TAP, then you
can take advantage of the myriad of test analysis tools out there.

Now, I was discussing the use of TAP with a different PostgreSQL contributor,
who was asking me about modifying the output of `pg_regress` to be TAP. The way
that `pg_regress` works--and therefore how PostgreSQL core tests work--is
simple: One writes SQL statements into a test script, and then one writes an
expected output file. If the output of the tests might vary by platform,
database setting, or compile-time feature, one just creates more expected files,
each with the appropriate variations.

The PostgreSQL test runner, `pg_regress` then simply runs the script through
`psql` and `diff`s the output against each expected file. If one of the files is
identical to the output, the test passes. Otherwise it fails. When the tests
run, the output looks like this:

    parallel group (2 tests):  copyselect copy
       copy                 ... ok
       copyselect           ... ok

My core hacker correspondent was thinking of modifying this output to be TAP,
something like this:

    # Parallel group (2 tests):  copyselect copy
    1..2
    ok 1 - copy
    ok 2 - copyselect

With this change, he could then run the regression tests through [TAP::Harness]
in a cron job and send failure reports when a test failed. This is good as far
as it goes, but it has a couple of significant limitations. For one, there are
no diagnostics if something goes wrong. This is because, and this is the second
shortcoming, it just turns the result of testing a single script into TAP, not
individual assertions. There might be 1000s of SQL statements in one script, but
if the test fails, one won't know what failed until one looks at
`regression.diff`.

One of the great features of TAP is the support for diagnostics. For example, if
an assertion fails, you might see output something like this:

    not ok 38 - The frobnitz should be named "foo"
    # Failed test 38: "The frobnitz should be named "foo""
    #         have: NULL
    #         want: foo

Just changing the listing of the test scripts run does not get you this
advantage. That's not to say that it doesn't make certain things easier, or that
one couldn't simply have shorter test scripts in order to limit the scope of
what's being tested and what's a result. But **a single test script does not
make for a good assertion.** In short, `pg_regress` tests don't do assertions at
all. They simply compare actual and expected output from very verbose scripts.
This is a hell of a lot better than nothing, but is still quite limited.

I suggested to my correspondent that he consider modifying the tests he was
working on to use pgTAP, instead. Of course, if you have a *lot* of existing
tests, it might be more trouble than it's worth to rewrite them all. But that
doesn't mean that you can't write new tests going forward using something that's
more granular, and gives you a lot more control over the output.

His answer rather shocked me:

> I'm lucky enough to only be dealing with really good developers, so I can
> produce software that works even without focusing specifically on low-level
> unit tests.

To me, it's a misconception to think “really good developers” don't need tests.
As I said in reply, I consider myself a “really good developer,” and I'd have a
whole lot more pain with the code I maintain if it weren't for the tests I've
written. Tests do *not* compensate for poor coders. Rather, they make it easier
to maintain, modify, and refactor code, to fix bugs, and to add new features.
Not to mention testing my code on new versions of software, such as testing my
CPAN modules with Perl 5.10 and testing my client's PostgreSQL databases with
8.3 or 8.4 as they look to upgrade from 8.2.

One place where my correspondent agreed that `pg_regress` could use improvement
is in the whole approach to matching different outputs. Using pgTAP, one can
write tests in such a way that there are different expected results depending on
database settings right in the test scripts themselves! This is because the TAP
output can vary in any number of ways, and the harness doesn't care, as long as
the tests pass. `pg_regress` is *extremely* strict about what it considers a
passing test, and this lacks the necessary flexibility for testing some advanced
features.

This is why there are no tests for multibyte character semantics (such as
locale-aware sorting) in the PostgreSQL core tests.

Are you a database testing doubter? Have I convinced you yet that a rock-solid
test suite can actually make your job easier and more enjoyable? Perhaps I never
will, but I am still very interested in your reasons for doubting the utility of
database testing. What other points should I be thinking about as I prepare for
my [PGCon presentation]?

  [database testing]: {{% ref "/post/past/db/pg/why-test-databases" %}}
    "Why Test Databases?"
  [pgTAP]: https://pgtap.org
  [protocol]: http://testanything.org/ "Test Anything Protocol"
  [Perl]: https://metacpan.org/pod/Test::More "Test::More"
  [C]: http://jc.ngo.org.uk/trac-bin/trac.cgi/wiki/LibTap "libtap"
  [JavaScript]: http://openjsan.org/doc/t/th/theory/Test/Simple/ "Test.Simple"
  [PHP]: http://www.phpunit.de/ "PHPUnit"
  [Oracle]: http://code.google.com/p/pluto-test-framework/wiki/PlutoWikiMain
    "PLUTO - PL/SQL Unit Testing for Oracle"
  [TAP producers]: http://testanything.org/wiki/index.php/TAP_Producers
  [functional interface]: https://pgtap.org "pgTAP"
  [TAP::Harness]: https://metacpan.org/pod/TAP::Harness
  [PGCon presentation]: https://www.pgcon.org/2009/schedule/events/165.en.html
    "PGCon: Unit Test Your Database!"
