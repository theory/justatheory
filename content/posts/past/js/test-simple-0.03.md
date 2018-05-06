--- 
date: 2005-04-29T17:41:21Z
slug: test-simple-0.03
title: TestSimple 0.03 Released
aliases: [/computers/programming/javascript/test_simple-0.03.html]
tags: [JavaScript, Perl, port, testing]
---

<p>I'm pleased to announce the third alpha release of TestSimple, the port of
<a href="http://search.cpan.org/dist/Test-Simple/" title="Test::Simple and friends on CPAN">Test::Builder, Test::Simple, and Test::More</a> to
JavaScript. You can download
it <a href="http://www.justatheory.com/downloads/TestSimple-0.03.tar.gz" title="Download TestSimple 0.03 now!">here</a>. This release has the following
changes:</p>

<ul>
  <li>Removed trailing commas from 3 arrays, since IE6/Win doesn't like
  them. And now everything works in IE. Thanks to Marshall Roch for tracking
  down and nailing this problem.</li>
  <li><code>isNum()</code> and <code>isntNum()</code>
  in <em>TestBuilder.js</em> now properly convert values to numbers using the
  global <code>Number()</code> function.</li>
  <li>CurrentTest is now properly initialized to 0 when creating a new
  TestBuilder object.</li>
  <li>Values passed to <code>like()</code> and <code>unlike()</code> that are
  not strings now always fail to match the regular expression.</li>
  <li><code>plan()</code> now outputs better error messages.</li>
  <li><code>isDeeply()</code> now works better with circular and repeating
  references.</li>
  <li><code>diag()</code> is now smarter about converting objects to strings
  before outputting them.</li>
  <li>Changed isEq() and isntEq() to use simple equivalence checks
  (<code>==</code> and <code>!=</code>, respectively) instead of stringified
  comparisons, as the equivalence checks are more generally
  useful. Use <code>cmpOk(got, &quot;eq&quot;, expect)</code> to explicitly
  compare stringified versions of values.</li>
  <li><code>TestBuilder.create()</code> now properly returns a new TestBuilder
  object instead of the singleton.</li>
  <li>The <code>useNumbers()</code>, <code>noHeader()</code>,
  and <code>noEnding()</code> accessors will now properly assign a non-null
  value passed to them.</li>
  <li>The arrays returned from <code>summary()</code>
  and <code>details()</code> now have the appropriate structures.</li>
  <li><code>diag()</code> now always properly adds a <q>#</q> character after
  newlines.</li>
  <li>Added <code>output()</code>, <code>failureOutput()</code>,
  <code>todoOutput()</code>, <code>warnOutput()</code>,
  and <code>endOutput()</code> to TestBuilder to set up function reference to
  which to send output for various purposes. The first three each default
  to <code>document.write</code>, while <code>warnOutput()</code> defaults to
  <code>window.alert</code> and <code>endOutout()</code> defaults to the
  <code>appendData</code> function of a text element inside an element with
  the ID <q>test</q> or, failing that, <code>window.write</code>.</li>
  <li><code>todo()</code> and <code>todoSkip()</code> now properly add <q>#</q>
  after all newlines in their messages.</li>
  <li>Fixed line ending escapes in diagnostics to be platform-independent. Bug
  reported by Marshall Roch.</li>
  <li>Ported about a third of the tests from Test::Simple (which is how I
  caught most of the above issues). The remaining test from Test::Simple will
  be ported for the next release.</li>
</ul>

<p>Many thanks to <a href="http://www.spastically.com/" title="Spastically">Marshall Roch</a> for help debugging issues in IE.</p>

<p>Now, there is one outstanding issue I'd like to address before I would
consider this production ready (aside from porting all the remaining tests
from Test::Simple): how to harness the output. Harnessing breaks down into a
number of issues:</p>

<p>How to run all tests in a single window. I might be able to write a build
script that builds a single HTML file that includes all the other HTML files
in iframes or some such. But then will each run in its own space without
stomping on the others? And how would the harness pull in the results of each?
It might be able to go into each of its children and grab the results from the
TestBuilder objects…
</p>

<p>More Feedback/advice/insults welcome!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/javascript/test_simple-0.03.html">old layout</a>.</small></p>


