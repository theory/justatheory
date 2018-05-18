--- 
date: 2005-04-07T18:59:27Z
slug: test-simple
title: "New JavaScript Testing Method: TestSimple"
aliases: [/computers/programming/javascript/test_simple.html]
tags: [JavaScript, Perl]
type: post
---

<p>I'm pleased to announce the first alpha release of my port of <a
href="search.cpan.org/dist/Test-Simple/" title="Read the Test::Simple/Test::Builder/Test::More documentation on CPAN">Test::Simple/Test::More/Test::Builder</a> to JavaScript. <a
href="http://www.justatheory.com/downloads/TestBuilder-0.01.tar.gz"
title="Download TestSimple 0.01 Now">Download it now</a> and let me know what
you think!</p>

<p>You can see what the tests look like by loading the files in
the <em>tests/</em> directory into your Web browser. This is my first stab at
what I hope becomes a complete port. I could use some feedback/ideas on a
number of outstanding issues:</p>

<ul>
  <li>I have made no decisions as to where to output test results,
  diagnostics, etc. Currently, they're simply output to document.write(). This
  may well be the best place in the long run, though it might be nice to allow
  users to configure where output goes. It will also be easy to control the
  output, since the output functions can easily be replaced in JavaScript.
  Suggestions welcome.</li>

  <li>I have no idea how to exit execution of tests other than by throwing an
  exception, which is only supported by JavaScript 1.5, anyway, AFAIK. As a
  result, <code>skipAll()</code>, <code>BAILOUT()</code>,
  and <code>skipRest()</code> do not work.</li>

  <li>Skip and Todo tests currently don't work because named blocks (e.g.,
  <code>SKIP:</code> and <code>TODO:</code>) are lexical in JavaScript.
  Therefore I cannot get at them from within a function called from within a
  block (at least not that I can tell). It might be that I need to just pass
  function references to <code>skip()</code> and <code>todo()</code>, instead.
  This is a rather different interface than that supported by Test::More, but
  it might work. Thoughts?</li>

  <li>Currently, one must call <code>Test._ending()</code> to finish running
  tests. This is because there is no <code>END</code> block to grab on to in
  JavaScript. Suggestions for how to capture output and append the output of
  <code>_ending()</code> are welcome. It might work to have
  the <code>onload</code> event execute it, but then it will have to look for
  the proper context in which to append it (a <code>&lt;pre&gt;</code> tag, at
  this point).</li>

  <li>Anyone have any idea how to get at the line number and file name in a
  JavaScript? Failures currently aren't too descriptive. As a result, I'm not
  sure if <code>level()</code> will have any part to play.</li>

  <li>Is there threading in JavaScript?</li>

  <li>I haven't written TestHarness yet. It may not make sense to even have
  such a thing in JavaScript; I'm not sure.</li>

  <li>I'm using a <a href="http://search.cpan.org/dist/Module-Build/"
  title="Read the Module::Build documentation on CPAN">Module::Build</a>
  script to build a distribution. I don't think there's a standard for
  distributing JavaScript libraries, but I think that this works reasonably
  well. I have all of the documentation in POD, and the script generates HTML
  and text versions before creating the tarball. The <em>Build.PL</em> script
  of course is not included in the distribution. I started out trying to write
  the documentation in JSDoc, but abandoned it for all of the reasons I <a
  href="http://www.justatheory.com/computers/programming/javascript/no_jsdoc_please.html"
  title="JSDoc Doesn't Quite do the Trick for Me">recounted last
  week</a>.</li>

  <li>Is there a way to dynamically load a JavaScript file? I'd like to use an
  approach to have <em>TestMore.js</em> and <em>TestSimple.js</em>
  load <em>TestBuilder.js</em>. I'd also like to use it to
  implement <code>loadOk()</code> (equivalent to
  Test::More's <code>use_ok()</code> and
  <code>require_ok()</code> subroutines).</li>
</ul>

<p>More details are in the ToDo section of the TestBuilder docs.</p>

<p>Let me know what you think!</p>
