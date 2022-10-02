---
date: 2005-04-12T21:20:20Z
description: I'm pleased to announce the second alpha release of TestSimple, the port of Test::Builder, Test::Simple, and Test::More] to JavaScript
lastMod: 2022-10-02T22:39:29Z
slug: javascript-testsimple-0.02-released
tags:
  - use Perl
  - Perl
  - JavaScript
  - JavaScript Test Framework
title: JavaScript TestSimple 0.02 Released
---

I'm pleased to announce the second alpha release of TestSimple, the port of
[Test::Builder, Test::Simple, and Test::More] to JavaScript. You can download it
[here]. This release has the following changes:

*   Removed `eqArray()` and `eqAssoc()` functions from TestMore per
    suggestion from Michael Schwern. The problem is that these are not
    test functions, and so are inconsistent with the way the rest of
    the functions work. `isDeeply()` is the function that users really
    want.

*   Changed `eqSet()` to `isSet()` and made it into a real test
    function.

*   Implemented `skip()`, `todoSkip()`, and `todo()`. These are a bit
    different than the Perl originals originals so read the docs!

*   Implemented `skipAll()` and `BAILOUT()` using exceptions and an
    exception handler installed in `window.onerror`.

*   The final message of a test file now properly outputs in the proper
    place. Tests must be run inside an element its "id" attribute set
    to "test", such as `<pre id="test">`. The `window.onload` handler
    will find it and append the final test information.

*   Implemented `skipRest()` in TestBuilder and TestMore. This method
    is stubbed out the Perl original, but not yet implemented there!

The only truly outstanding issues I see before I would consider these "modules"
ready for production use are:

*   Figure out how to get at file names and line numbers for better
    diagnostic messages. Is this even possible in JavaScript?

*   Decide where to send test output, and where to allow other output
    to be sent. Test::Builder clones `STDERR` and `STDOUT` for this
    purpose. We'll probably have to do it by overriding `document.write()>`,
    but it'd be good to allow users to define alternate outputs (tests
    may not always run in a browser, eh?). Maybe we can use an output
    object? Currently, a browser and its DOM are expected to be
    present. I could really use some advice from real JavaScript gurus
    on this one.

*   Write tests!

Feedback/advice/insults welcome!

*Originally published [on use Perl;]*

  [Test::Builder, Test::Simple, and Test::More]: http://search.cpan.org/dist/Test-Simple/
  [here]: http://www.justatheory.com/downloads/TestSimple-0.02.tar.gz
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/24154/
    "use.perl.org journal of Theory: “JavaScript TestSimple 0.02 Released”"
