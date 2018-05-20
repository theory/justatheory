--- 
date: 2005-06-24T05:11:58Z
slug: test-simple-0.10
title: Test.Simple 0.10 Released
aliases: [/computers/programming/javascript/test_simple-0.10.html]
tags: [JavaScript, Perl, Testing, TAP, Test Anything Protocol]
type: post
---

I’m pleased to announce the first beta release of Test.Simple, the port of
[Test::Builder, Test::Simple, Test::More], and [Test::Harness] to JavaScript.
You can download it [here]. See the harness in action [here][1] (or
[verbosely]!). This release has the following changes:

-   Changed the signature of functions passed to `output()` and friends to
    accept a single argument rather than a list of arguments. This allows custom
    functions to be much simpler.
-   Added support for Macromedia Director. Patch from Gordon McCreight.
-   Backwards Incompatibility change: moved all “modules” into Test “namespace”
    by using an object for the Test namespace and assigning the `Build()`
    constructor to it. See http://xrl.us/fy4h for a description of this
    approach.
-   Fixed the `typeOf()` class method in Test.Builder to just return the value
    returned by the `typeof` operator if the class constructor is an anonymous
    function.
-   Changed `for (var in in someArray)` to
    `for (var i = 0; i < someArray.length; i++)` for iterating through arrays,
    since the former method will break if someone has changed the prototype for
    arrays. Thanks to Bob Ippolito for the spot!
-   The default output in browsers is now to append to an element with the ID
    “test” or, failing that, to use `document.write`. The use of the “test”
    element allows output to continue to be written to the browser window even
    after the document has been closed. Reported by Adam Kennedy.
-   Changed the default `endOutput()` method to be the same as the other
    outputs.
-   Backwards incompatibility change: Changed semantics of `plan()` so that it
    takes an object for an argument. This allows multiple commands to be passed,
    where the object attribute keys are the command and their values are the
    arguments.
-   Backwards incompatibility change: Changed the “no\_plan”, “skip\_all”, and
    “no\_diag” (in Test.More only) options to `plan()` to their studlyCap
    alternatives, “noPlan”, “skipAll”, and “noDiag”. This makes them consistent
    with JavaScript attribute naming convention.
-   Added `beginAsync()` and `endAsync()` methods to Test.Builder to allow users
    to put off the ending of a script until after asynchronous tests have been
    run. Suggested by Adam Kennedy.
-   Backwards incompatibility change: Changed the signature for the `output()`
    method and friends to take only a single anonymous function as its argument.
    If you still need to call a method, pass an anonymous function that calls it
    appropriately.
-   Changed handling of line-endings to be browser-specific. That is, if the
    current environment is Internet Explorer, we use “\\r” for line endings.
    Otherwise we use “\\n”. Although IE properly interprets \\n as a line ending
    when it's passed to `document.write()`, it doesn't when passed to a DOM text
    node. No idea why not.
-   Added a browser harness. Now you can run all of your tests in a single
    browser window and get a summary at the end, including a list of failed
    tests and the time spent running the tests.
-   Fixed calls to `warn()` in Test.More.
-   Output to the browser now causes the window to scroll when the length of the
    output is greater than the height of the window.
-   Backwards incompatibility change: Changed all instances of “Ok” to “OK”. So
    this means that the new Test.More function names are `canOK()`, `isaOK()`,
    and `cmpOK()`. Sorry 'bout that, won't happen again.
-   Ported to Safari (though there are issues--see the “Bugs” section of the
    Test.Harness.Browser docs for details).

Obviously this is a big release. I bumped up the version number because there
are a fair number of backwards incompatibilities. But I'm reasonably confident
that they wont' change so much in the future. And with the addition of the
harness, it's getting ready for prime time!

Next up, I'll finish porting the test from Test::Harness (really!) and add
support for JSAN (look for a JSAN announcement soon). But in the meantime,
feedback, bug reports, kudos, complaints, etc.warmly welcomed!

  [Test::Builder, Test::Simple, Test::More]: http://search.cpan.org/dist/Test-Simple/
    "Test::Simple on CPAN"
  [Test::Harness]: http://search.cpan.org/dist/Test-Harness/
    "Test::Harness on CPAN"
  [here]: http://www.justatheory.com/downloads/Test.Simple-0.10.tar.gz
    "Download Test.Simple 0.10 Now!"
  [1]: http://www.justatheory.com/code/Test.Simple-0.10/tests/index.html
    "Run the Test.Simple 0.10 Test Suite now!"
  [verbosely]: http://www.justatheory.com/code/Test.Simple-0.10/tests/index.html?verbose=1
    "Run the Test.Simple 0.10 Tests verbosely!"
