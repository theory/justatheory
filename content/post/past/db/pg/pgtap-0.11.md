--- 
date: 2008-09-24T22:05:06Z
lastMod: 2022-05-22T21:36:50Z
slug: pgtap-0.11
title: pgTAP 0.11 Released
aliases: [/computers/databases/postgresql/pgtap-0.11.html]
tags: [Postgres, pgTAP, Testing, Unit Testing, TAP, Test Anything Protocol]
type: post
---

So I've just released [pgTAP 0.11]. I know I said I wasn't going to work on it
for a while, but I changed my mind. Here's what's changed:

-   Simplified the tests so that they now load `test_setup.sql` instead of
    setting a bunch of stuff themselves. Now only `test_setup.sql` needs to be
    created from `test_setup.sql.in`, and the other `.sql` files depend on it,
    meaning that one no longer has to specify `TAPSCHEMA` for any `make` target
    other than the default.
-   Eliminated all uses of `E''` in the tests, so that we don't have to process
    them for testing on 8.0.
-   Fixed the spelling of `ON_ROLLBACK` in the test setup. Can't believe I had
    it with one L in all of the test files before! Thanks to Curtis "Ovid" Poe
    for the spot.
-   Added a couple of variants of `todo()` and `skip()`, since I can never
    remember whether the numeric argument comes first or second. Thanks to
    PostgreSQL's functional polymorphism, I don't have to. Also, there are
    variants where the numeric value, if not passed, defaults to 1.
-   Updated the link to the pgTAP home page in `pgtap.sql.in`.
-   TODO tests can now nest.
-   Added `todo_start()`, `todo_end()`, and `in_todo()`.
-   Added variants of `throws_ok()` that test error messages as well as error
    codes.
-   Converted some more tests to use `check_test()`.
-   Added `can()` and `can_ok()`.
-   Fixed a bug in `check_test()` where the leading whitespace for diagnostic
    messages could be off by 1 or more characters.
-   Fixed the `installcheck` target so that it properly installs PL/pgSQL into
    the target database before the tests run.

Now I really am going to do some other stuff for a bit, although I do want to
see what I can poach from [Epic Test]. And I *do* have that [talk] on pgTAP next
month. So I'll be back with more soon enough.

  [pgTAP 0.11]: https://github.com/theory/pgtap/releases/tag/rel-0.11
  [Epic Test]: http://epictest.org/
    "Epic: More full of fail than any other testing tool"
  [talk]: https://web.archive.org/web/20081120015713/http://www.postgresqlconference.org/west08/talks/
    "PostgreSQL Conference West 2008 Talks"
