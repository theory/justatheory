--- 
date: 2005-07-06T18:59:28Z
slug: test-simple-0.11
title: Test.Simple 0.11 Released
aliases: [/computers/programming/javascript/test_simple-0.11.html]
tags: [JavaScript, testing, TAP]
---

<p>I'm pleased to announce the release of Test.Simple 0.11. This release fixes a number of bugs in the framework's IE and Safari support, adds <a href="http://www.openjsan.org/" title="JSAN">JSAN</a> support, and includes an experimental harness for Macromedia^Adobe Director. You can download it from <a href="http://www.openjsan.org/doc/theory/Test/Simple/0.11/index.html" title="Download Test.Simple 0.11 from JSAN!">JSAN</a>, and all future releases will be available on JSAN. See the harness in action <a href="http://www.justatheory.com/code/Test.Simple-0.11/tests/index.html" title="Run the Test.Simple 0.11 Test Suite now!">here</a> (or <a href="http://www.justatheory.com/code/Test.Simple-0.11/tests/index.html?verbose=1" title="Run the Test.Simple 0.11 Tests verbosely!">verbosely</a>!). This release has the following changes:</p>

<ul>
  <li>The browser harness now works more reliably in IE and Safari.</li>
  <li>Fixed syntax errors in <em>tests/harness.html</em> that IE and Safari
      care about.</li>
  <li>Various tweaks for Director compatibility from Gordon McCreight.</li>
  <li>Removed debugging output from <code>Test.More.canOK()</code>.</li>
  <li>Fixed default output so that it doesn't re-open a closed browser
      document when there is a <q>test</q> element.</li>
  <li>Added experimental Test.Harness.Director, complements of Gordon
      McCreight. This harness is subject to change.</li>
  <li>Added <code>Test.PLATFORM</code>, containing a string defining the
      platform. At the moment, the only platforms listed are <q>browser</q> or
      <q>director</q>.</li>
  <li>Added support for Casey
      West's <a href="http://www.openjsan.org/doc/CWEST/JSAN/0.02/index.html"
      title="Start use'ing JSAN modules!">JSAN</a>. All releases of
      Test.Simple will be available on JSAN from now on.</li>
  <li>The <code>iframe</code> in the browser harness is no longer visible in
      IE. Thanks to Marshall Roch for the patch.</li>
  <li>Noted addition of Test.Harness and Test.Harness.Browser in the
      README.</li>
</ul>

<p>I've been getting more and more excited about <a href="http://ww.caseywest.com" title="Casey West's Blog">Casey West</a>'s work on <a href="http://www.openjsan.org/" title="JSAN">JSAN</a>. It gets better every day, and I hope that it attracts a lot of hackers who want to distribute open source JavaScript modules. You should check it out! I've been working on a Perl module to simplify the creation of JSAN distributions. Look for it on CPAN soonish.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/javascript/test_simple-0.11.html">old layout</a>.</small></p>


