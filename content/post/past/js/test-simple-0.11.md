--- 
date: 2005-07-06T18:59:28Z
slug: test-simple-js-0.11
title: Test.Simple 0.11 Released
aliases: [/computers/programming/javascript/test_simple-0.11.html]
tags: [JavaScript, Testing, TAP]
type: post
---

I'm pleased to announce the release of Test.Simple 0.11. This release fixes a
number of bugs in the framework's IE and Safari support, adds [JSAN] support,
and includes an experimental harness for Macromedia\^Adobe Director. You can
download it from [JSAN][1], and all future releases will be available on JSAN.
See the harness in action [here] (or [verbosely]!). This release has the
following changes:

-   The browser harness now works more reliably in IE and Safari.
-   Fixed syntax errors in *tests/harness.html* that IE and Safari care about.
-   Various tweaks for Director compatibility from Gordon McCreight.
-   Removed debugging output from `Test.More.canOK()`.
-   Fixed default output so that it doesn't re-open a closed browser document
    when there is a “test” element.
-   Added experimental Test.Harness.Director, complements of Gordon McCreight.
    This harness is subject to change.
-   Added `Test.PLATFORM`, containing a string defining the platform. At the
    moment, the only platforms listed are “browser” or “director”.
-   Added support for Casey West's [JSAN][2]. All releases of Test.Simple will
    be available on JSAN from now on.
-   The `iframe` in the browser harness is no longer visible in IE. Thanks to
    Marshall Roch for the patch.
-   Noted addition of Test.Harness and Test.Harness.Browser in the README.

I've been getting more and more excited about [Casey West]'s work on [JSAN]. It
gets better every day, and I hope that it attracts a lot of hackers who want to
distribute open source JavaScript modules. You should check it out! I've been
working on a Perl module to simplify the creation of JSAN distributions. Look
for it on CPAN soonish.

  [JSAN]: http://www.openjsan.org/ "JSAN"
  [1]: http://www.openjsan.org/doc/theory/Test/Simple/0.11/index.html
    "Download Test.Simple 0.11 from JSAN!"
  [here]: http://www.justatheory.com/code/Test.Simple-0.11/tests/index.html
    "Run the Test.Simple 0.11 Test Suite now!"
  [verbosely]: http://www.justatheory.com/code/Test.Simple-0.11/tests/index.html?verbose=1
    "Run the Test.Simple 0.11 Tests verbosely!"
  [2]: http://www.openjsan.org/doc/CWEST/JSAN/0.02/index.html
    "Start use'ing JSAN modules!"
  [Casey West]: http://ww.caseywest.com "Casey West's Blog"
