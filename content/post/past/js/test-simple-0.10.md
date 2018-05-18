--- 
date: 2005-06-24T05:11:58Z
slug: test-simple-0.10
title: Test.Simple 0.10 Released
aliases: [/computers/programming/javascript/test_simple-0.10.html]
tags: [JavaScript, Perl, Testing, TAP, Test Anything Protocol]
type: post
---

<p>I’m pleased to announce the first beta release of Test.Simple, the port of <a href="http://search.cpan.org/dist/Test-Simple/" title="Test::Simple on CPAN">Test::Builder, Test::Simple, Test::More</a>, and <a href="http://search.cpan.org/dist/Test-Harness/" title="Test::Harness on CPAN">Test::Harness</a> to JavaScript. You can download it <a href="http://www.justatheory.com/downloads/Test.Simple-0.10.tar.gz" title="Download Test.Simple 0.10 Now!">here</a>. See the harness in action <a href="http://www.justatheory.com/code/Test.Simple-0.10/tests/index.html" title="Run the Test.Simple 0.10 Test Suite now!">here</a> (or <a href="http://www.justatheory.com/code/Test.Simple-0.10/tests/index.html?verbose=1" title="Run the Test.Simple 0.10 Tests verbosely!">verbosely</a>!). This release has the following changes:</p>

<ul>
   <li>Changed the signature of functions passed to <code>output()</code> and
        friends to accept a single argument rather than a list of
        arguments. This allows custom functions to be much simpler.</li>
  <li>Added support for Macromedia Director. Patch from Gordon McCreight.</li>
  <li>Backwards Incompatibility change: moved all <q>modules</q> into Test
        <q>namespace</q> by using an object for the Test namespace and
        assigning the <code>Build()</code> constructor to it. See
        http://xrl.us/fy4h for a description of this approach.</li>
  <li>Fixed the <code>typeOf()</code> class method in Test.Builder to just
        return the value returned by the <code>typeof</code> operator if the
        class constructor is an anonymous function.</li>
  <li>Changed <code>for (var in in someArray)</code> to
        <code>for (var i = 0; i &lt; someArray.length; i++)</code> for iterating
        through arrays, since the former method will break if someone has
        changed the prototype for arrays. Thanks to Bob Ippolito for the
        spot!</li>
  <li>The default output in browsers is now to append to an element with the
        ID <q>test</q> or, failing that, to
        use <code>document.write</code>. The use of the
        <q>test</q> element allows output to continue to be written to the browser
        window even after the document has been closed. Reported by Adam
        Kennedy.</li>
  <li>Changed the default <code>endOutput()</code> method to be the same as
        the other outputs.</li>
  <li>Backwards incompatibility change: Changed semantics
        of <code>plan()</code> so that it takes an object for an argument.
        This allows multiple commands to be passed, where the object attribute
        keys are the command and their values are the arguments.</li>
  <li>Backwards incompatibility change: Changed
        the <q>no_plan</q>, <q>skip_all</q>, and <q>no_diag</q> (in Test.More
        only) options to <code>plan()</code> to their studlyCap
        alternatives, <q>noPlan</q>, <q>skipAll</q>, and <q>noDiag</q>. This
        makes them consistent with JavaScript attribute naming
        convention.</li>
  <li>Added <code>beginAsync()</code> and <code>endAsync()</code> methods to Test.Builder to allow
        users to put off the ending of a script until after asynchronous tests
        have been run. Suggested by Adam Kennedy.</li>
  <li>Backwards incompatibility change: Changed the signature for the
    <code>output()</code> method and friends to take only a single anonymous
        function as its argument. If you still need to call a method, pass an
        anonymous function that calls it appropriately.</li>
  <li>Changed handling of line-endings to be browser-specific. That is, if the
        current environment is Internet Explorer, we use <q>\r</q> for line
        endings.  Otherwise we use <q>\n</q>. Although IE properly interprets
        \n as a line ending when it's passed to <code>document.write()</code>,
        it doesn't when passed to a DOM text node. No idea why not.</li>
  <li>Added a browser harness. Now you can run all of your tests in a single
        browser window and get a summary at the end, including a list of
        failed tests and the time spent running the tests.</li>
  <li>Fixed calls to <code>warn()</code> in Test.More.</li>
  <li>Output to the browser now causes the window to scroll when the length of
        the output is greater than the height of the window.</li>
  <li>Backwards incompatibility change: Changed all instances of <q>Ok</q> to
        <q>OK</q>. So this means that the new Test.More function names are
        <code>canOK()</code>, <code>isaOK()</code>,
        and <code>cmpOK()</code>. Sorry 'bout that, won't happen again.</li>
  <li>Ported to Safari (though there are issues--see the <q>Bugs</q> section
        of the Test.Harness.Browser docs for details).</li>
</ul>

<p>Obviously this is a big release. I bumped up the version number because there are a fair number of backwards incompatibilities. But I'm reasonably confident that they wont' change so much in the future. And with the addition of the harness, it's getting ready for prime time!</p>

<p>Next up, I'll finish porting the test from Test::Harness (really!) and add support for JSAN (look for a JSAN announcement soon). But in the meantime, feedback, bug reports, kudos, complaints, etc.warmly welcomed!</p>
