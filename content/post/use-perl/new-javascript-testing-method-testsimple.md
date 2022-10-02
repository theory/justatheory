---
date: 2005-04-07T19:31:29Z
description: I'm pleased to announce the first alpha release of my port of Test::Simple/Test::Builder/Test::More to JavaScript.
lastMod: 2022-10-02T22:39:29Z
slug: new-javascript-testing-method-testsimple
tags:
  - use Perl
  - Perl
  - JavaScript
  - JavaScript Test Framework
title: 'New JavaScript Testing Method: TestSimple'
---

I'm pleased to announce the first alpha release of my port of
[Test::Simple/Test::Builder/Test::More] to JavaScript. [Download it now] and let
me know what you think!

You can see what the tests look like by loading the files in the *tests/*
directory into your Web browser. This is my first stab at what I hope becomes a
complete port. I could use some feedback/ideas on a number of outstanding
issues:

*   I have made no decisions as to where to output test results, diagnostics,
    etc. Currently, they're simply output to `document.write()`. This may well
    be the best place in the long run, though it might be nice to allow users to
    configure where output goes. It will also be easy to control the output,
    since the output functions can easily be replaced in JavaScript. Suggestions
    welcome.

*   I have no idea how to exit execution of tests other than by throwing an
    exception, which is only supported by JavaScript 1.5, anyway, AFAIK. As a
    result, `skipAll()`, `BAILOUT()`, and `skipRest()` do not work.

*   Skip and Todo tests currently don't work because named blocks (e.g., `SKIP:`
    and `TODO:`) are lexical in JavaScript. Therefore I cannot get at them from
    within a function called from within a block (at least not that I can tell).
    It might be that I need to just pass function references to `skip()` and
    `todo()`, instead. This is a rather different interface than that supported
    by Test::More, but it might work. Thoughts?

*   Currently, one must call `Test._ending()` to finish running tests. This is
    because there is no `END` block to grab on to in JavaScript. Suggestions for
    how to capture output and append the output of `_ending()` are welcome. It
    might work to have the `onload` event execute it, but then it will have to
    look for the proper context in which to append it (a `<pre>` tag, at this
    point).

*   Anyone have any idea how to get at the line number and file name in a
    JavaScript? Failures currently aren't too descriptive. As a result, I'm not
    sure if `level()` will have any part to play.

*   Is there threading in JavaScript?

*   I haven't written TestHarness yet. It may not make sense to even have such a
    thing in JavaScript; I'm not sure.

*   I'm using a [Module::Build] script to build a distribution. I don't think
    there's a standard for distributing JavaScript libraries, but I think that
    this works reasonably well. I have all of the documentation in POD, and the
    script generates HTML and text versions before creating the tarball. The
    *Build.PL* script of course is not included in the distribution. I started
    out trying to write the documentation in JSDoc, but abandoned it for all of
    the reasons I [recounted last week].

*   Is there a way to dynamically load a JavaScript file? I'd like to use an
    approach to have *TestMore.js* and *TestSimple.js* load *TestBuilder.js*.
    I'd also like to use it to implement `loadOk()` (equivalent to Test::More's
    `use_ok()` and `require_ok()` subroutines).

More details are in the ToDo section of the TestBuilder docs.

Let me know what you think!

*Originally published [on use Perl;]*

  [Test::Simple/Test::More/Test::Builder]: https://metacpan.org/dist/Test-Simple
  [Download it now]: http://www.justatheory.com/downloads/TestBuilder-0.01.tar.gz
  [Module::Build]: http://search.cpan.org/dist/Module-Build/
  [recounted last     week]: http://www.justatheory.com/computers/programming/javascript/no_jsdoc_please.html
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/24059/
    "use.perl.org journal of Theory: “New JavaScript Testing Method: TestSimple”"
