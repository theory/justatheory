--- 
date: 2005-04-12T21:26:44Z
slug: test-simple-0.02
title: TestSimple 0.02 Released
aliases: [/computers/programming/javascript/test_simple-0.02.html]
tags: [JavaScript, Perl, testing, JavaScript Test Framework, TAP]
type: post
---

<p>I'm pleased to announce the second alpha release of TestSimple, the port of
<a href="http://search.cpan.org/dist/Test-Simple/" title="Test::Simple and friends on CPAN">Test::Builder, Test::Simple, and Test::More</a> to
JavaScript. You can download it <a href="/downloads/TestSimple-0.02.tar.gz" title="Download TestSimple 0.02 now!">here</a>. This release has the following
changes:</p>

<ul>
  <li>Removed <code>eqArray()</code> and <code>eqAssoc()</code> functions from
      TestMore per suggestion from Michael Schwern. The problem is that these
      are not test functions, and so are inconsistent with the way the rest of
      the functions work. <code>isDeeply()</code> is the function that users
      really want.</li>
  <li>Changed <code>eqSet()</code> to <code>isSet()</code> and made it into a
      real test function.</li>
  <li>Implemented <code>skip()</code>, <code>todoSkip()</code>,
      and <code>todo()</code>. These are a bit different than the Perl
      originals originals so read the docs!</li>
  <li>Implemented <code>skipAll()</code> and <code>BAILOUT()</code> using
      exceptions and an exception handler installed
      in <code>window.onerror</code>.</li>
  <li>The final message of a test file now properly outputs in the proper
      place. Tests must be run inside an element its <q>id</q> attribute set
      to <q>test</q>, such as <code>&lt;pre id=&quot;test&quot;&gt;</code>. The
      <code>window.onload</code> handler will find it and append the final test
      information.</li>
  <li>Implemented <code>skipRest()</code> in TestBuilder and TestMore. This
      method is stubbed out the Perl original, but not yet implemented
      there!</li>
</ul>

<p>The only truly outstanding issues I see before I would consider
these <q>modules</q> ready for production use are:</p>

<ul>
  <li>Figure out how to get at file names and line numbers for better
  diagnostic messages. Is this even possible in JavaScript?</li>
  <li>Decide where to send test output, and where to allow other output to be
  sent. Test::Builder clones <code>STDERR</code> and <code>STDOUT</code> for
  this purpose. We'll probably have to do it by overriding
  <code>document.write()></code>, but it'd be good to allow users to define
  alternate outputs (tests may not always run in a browser, eh?). Maybe we can
  use an output object? Currently, a browser and its DOM are expected to be
  present. I could really use some advice from real JavaScript gurus on this
  one.</li>
  <li>Write tests!</li>
</ul>

<p>Feedback/advice/insults welcome!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/javascript/test_simple-0.02.html">old layout</a>.</small></p>


