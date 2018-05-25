--- 
date: 2005-04-29T17:41:21Z
slug: test-simple-js-0.03
title: TestSimple 0.03 Released
aliases: [/computers/programming/javascript/test_simple-0.03.html]
tags: [JavaScript, Perl, Port, Testing]
type: post
---

I'm pleased to announce the third alpha release of TestSimple, the port of
[Test::Builder, Test::Simple, and Test::More] to JavaScript. You can download it
[here]. This release has the following changes:

-   Removed trailing commas from 3 arrays, since IE6/Win doesn't like them. And
    now everything works in IE. Thanks to Marshall Roch for tracking down and
    nailing this problem.
-   `isNum()` and `isntNum()` in *TestBuilder.js* now properly convert values to
    numbers using the global `Number()` function.
-   CurrentTest is now properly initialized to 0 when creating a new TestBuilder
    object.
-   Values passed to `like()` and `unlike()` that are not strings now always
    fail to match the regular expression.
-   `plan()` now outputs better error messages.
-   `isDeeply()` now works better with circular and repeating references.
-   `diag()` is now smarter about converting objects to strings before
    outputting them.
-   Changed isEq() and isntEq() to use simple equivalence checks (`==` and `!=`,
    respectively) instead of stringified comparisons, as the equivalence checks
    are more generally useful. Use `cmpOk(got, "eq", expect)` to explicitly
    compare stringified versions of values.
-   `TestBuilder.create()` now properly returns a new TestBuilder object instead
    of the singleton.
-   The `useNumbers()`, `noHeader()`, and `noEnding()` accessors will now
    properly assign a non-null value passed to them.
-   The arrays returned from `summary()` and `details()` now have the
    appropriate structures.
-   `diag()` now always properly adds a “\#” character after newlines.
-   Added `output()`, `failureOutput()`, `todoOutput()`, `warnOutput()`, and
    `endOutput()` to TestBuilder to set up function reference to which to send
    output for various purposes. The first three each default to
    `document.write`, while `warnOutput()` defaults to `window.alert` and
    `endOutout()` defaults to the `appendData` function of a text element inside
    an element with the ID “test” or, failing that, `window.write`.
-   `todo()` and `todoSkip()` now properly add “\#” after all newlines in their
    messages.
-   Fixed line ending escapes in diagnostics to be platform-independent. Bug
    reported by Marshall Roch.
-   Ported about a third of the tests from Test::Simple (which is how I caught
    most of the above issues). The remaining test from Test::Simple will be
    ported for the next release.

Many thanks to [Marshall Roch] for help debugging issues in IE.

Now, there is one outstanding issue I'd like to address before I would consider
this production ready (aside from porting all the remaining tests from
Test::Simple): how to harness the output. Harnessing breaks down into a number
of issues:

How to run all tests in a single window. I might be able to write a build script
that builds a single HTML file that includes all the other HTML files in iframes
or some such. But then will each run in its own space without stomping on the
others? And how would the harness pull in the results of each? It might be able
to go into each of its children and grab the results from the TestBuilder
objects…

More Feedback/advice/insults welcome!

  [Test::Builder, Test::Simple, and Test::More]: http://search.cpan.org/dist/Test-Simple/
    "Test::Simple and friends on CPAN"
  [here]: http://www.justatheory.com/downloads/TestSimple-0.03.tar.gz
    "Download TestSimple 0.03 now!"
  [Marshall Roch]: http://www.spastically.com/ "Spastically"
