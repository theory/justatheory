--- 
date: 2005-08-17T18:24:37Z
slug: test-simple-0.20
title: Test.Simple 0.20 Released
aliases: [/computers/programming/javascript/test_simple-0.20.html]
tags: [JavaScript, testing, TAP, Test Anything Protocol, Internet Explorer, Safari, Firefox, Opera]
---

<p>It gives me great pleasure, not to mention a significant amount of pride, to announce the release of <a href="http://www.openjsan.org/doc/t/th/theory/Test/Simple/0.20/index.html" title="Download Test.Simple 0.20 from JSAN">Test.Simple 0.20</a>. There are quite a few changes in this release, including a few that break backwards compatibility&#x2014;but only you're writing your own Test.Builder-based test libraries (and I don't think anyone has done so yet) or if you're subclassing Test.Harness (and there's only one of those, that I know of).</p>

<p>The biggest change is that Test.Harness.Browser now supports pure <em>.js</em> script files in addition to the original <em>.html</em> files. This works best in Firefox, of course, but with a lot of help from Pawel Chmielowski (<q>prefiks</q> on #jsan), it also works in Safari, Opera, and IE 6 (though not in XP Service Pack 2; I'll work on that after I get my new PC in the next few days). The trick with Firefox (and hopefully other browsers in the future, since it feels lest hackish to me), is that it uses the DOM to create a new HTML document in a hidden <code>iframe</code>, and that document loads the <em>.js</em>. Essentially, it just uses the DOM to mimic the structure of a typical <em>.html</em> test file. For the other browsers, the hidden <code>iframe</code> uses <code>XMLHttpRequest</code> to load and <code>eval</code> the <em>.js</em> test file. <a href="http://www.openjsan.org/src/t/th/theory/Test.Simple-0.20/tests/index.html" title="Run the Test.Simple test harness now!">Check it out</a> (<a href="http://www.openjsan.org/src/t/th/theory/Test.Simple-0.20/tests/index.html?verbose=1" title="Run the Test.Simple test harness verbosely!">verbosely</a>)!</p>

<p>I think that this will greatly enhance the benefits of Test.Simple, as it makes writing tests <em>really</em> simple. All you have to do is create a single <em>.html</em> file that looks something like this:</p>

<pre>
&lt;html&gt;
&lt;head&gt;
  &lt;script type=&quot;text/javascript&quot; src=&quot;./lib/JSAN.js&quot;&gt;&lt;/script&gt;
&lt;/head&gt;
&lt;body&gt;
&lt;script type=&quot;text/javascript&quot;&gt;
new JSAN(&quot;../lib&quot;).use(&quot;Test.Harness.Browser&quot;);
new Test.Harness.Browser(&#x0027;./lib/JSAN.js&#x0027;).encoding(&#x0027;utf-8&#x0027;).runTests(
    &#x0027;foo.js&#x0027;,
    &#x0027;bar.js&#x0027;
);
&lt;/script&gt;
&lt;/body&gt;
&lt;/html&gt;
</pre>

<p>In fact, that's pretty much exactly what Test.Simple's new harness looks like, now that I've moved all of the old tests into <em>.js</em> files (although there is still a <em>simpl.html</em> test file to ensure that <em>.html</em> test files still work!). Here I'm using <a href="http://www.openjsan.org/doc/c/cw/cwest/JSAN/" title="Download JSAN and start using JavaScript Libraries!">JSAN</a> to dynamically load the libraries I need. I use it to load Test.Harness.Browser (which then uses it to load Test.Harness), and then I tell the Test.Harness.Browser object where it is so that it can load it for each <em>.js</em> script. The test script itself can then look something like this:</p>

<pre>
new JSAN(&#x0027;../lib&#x0027;).use(&#x0027;Test.Simple&#x0027;);
plan({tests: 3});
ok(1, &#x0027;compile&#x0027;);
ok(1);
ok(1, &#x0027;foo&#x0027;);
</pre>

<p>And that's it! Just use JSAN to load the appropriate test library or libraries and go! I know that JSAN is already loaded because Test.Harness.Browser loads it for me before it loads and runs my <em>.js</em> test script. Nice, eh?</p>

<p>Of course, you don't have to use JSAN to run pure <em>.js</em> tests, although it can be convenient. Instead, you can just pass a list of files to the harness to have it load them for each test:</p>

<pre>
&lt;html&gt;
&lt;head&gt;
  &lt;script type=&quot;text/javascript&quot; src=&quot;./lib/Test/Harness.js&quot;&gt;&lt;/script&gt;
  &lt;script type=&quot;text/javascript&quot; src=&quot;./lib/Test/Harness/Browser.js&quot;&gt;&lt;/script&gt;
&lt;/head&gt;
&lt;body&gt;
&lt;script type=&quot;text/javascript&quot;&gt;
new Test.Harness.Browser(
    &#x0027;lib/Test/Builder.js&#x0027;,
    &#x0027;lib/Test/More.js&#x0027;,
    &#x0027;../lib/MY/Library.js&#x0027;
).runTests(
    &#x0027;foo.js&#x0027;,
    &#x0027;bar.js&#x0027;
);
&lt;/script&gt;
&lt;/body&gt;
&lt;/html&gt;
</pre>

<p>This example tells Test.Harness.Browser to load Test.Builder and Test.More, and then to run the tests in <em>foo.js</em> and <em>bar.js</em>. No need for JSAN if you don't want it. The test script is exactly the same as the above, only without the line with JSAN loading your test library.</p>

<p>Now, as I've said, this is imperfect. It's <a href="/programming/javascript/need_js_genius.html" title="Plea for Help from JavaScript Geniuses">surprisingly difficult</a> to get browsers to do this properly, and it's likely that it won't work at all in many browsers. I'm sure that I broke the Directory harness, too. Nevertheless, I'm pleased that I got as many to work as I did (again, with great thanks to Pawel Chmielowski for all the great hacks), but at this point, I'll probably only focus on adding support for Windows XP Service Pack 2. But as you might imagine, I'd welcome patches from anyone who wants to add support for other browsers.</p>

<p>There are a lot of other changes in this release. Here's the complete list:</p>

<ul>
  <li>Fixed verbose test output to be complete in the harness in Safari and IE.</li>
  <li>Fixed <code>plan()</code> so that it doesn't die if the object is passed with an unknown attribute. This can happen when JS code has altered <code>Object.prototype</code> (shame on it!). Reported by Rob Kinyon.</li>
  <li>Fixed some errors in the POD documentation.</li>
  <li>Updated JSAN to 0.10.</li>
  <li>Added documentation for Test.Harness.Director, complements of Gordon McCreight.</li>
  <li>Fixed line endings in Konqueror and Opera and any other browser other than MSIE that supports <code>document.all</code>. Reported by Rob Kinyon.</li>
  <li>Added support to Test.Harness.Browser for <em>.js</em> test files in addition to <em>.html</em> test files. Thanks to Pawel Chmielowski for helping me to overcome the final obstacles to actually getting this feature to work.</li>
  <li>Added missing variable declarations. Patch from Pawel Chmielowski.</li>
  <li>More portable fetching of the <code>body</code> element in Test.Builder. Based on patch from Pawel Chmielowski.</li>
  <li>Added an <code>encoding</code> attribute to Test.Harness. This is largely to support pure JS tests, so that the browser harness can set up the proper encoding for the <code>script</code> elements it creates.</li>
  <li>Added support for Opera, with thanks to Pawel Chmielowski.</li>
  <li>Fixed the output from skipAll in the test harness.</li>
  <li>Fixed display of summary of failed tests after all tests have been run by the browser harness. They are now displayed in a nicely formatted table without a <code>NaN</code> stuck where it doesn't belong.</li>
  <li>COMPATIBILITY CHANGE: The browser harness now outputs failure information bold-faced and red. This required changing the output argument to the <code>outputResults()</code> method to an object with two methods, <code>pass()</code> and <code>fail()</code>. Anyone using <code>Test.Harness.outputResults()</code> will want to make any changes accordingly.</li>
  <li>COMPATIBILITY CHANGE: new Test.Builder() now always returns a new Test.Builder object instead of a singleton. If you want the singleton, call <code>Test.Builder.instance()</code>. <code>Test.Builder.create()</code> has been deprecated and will be removed in a future release. This is different from how Perl's Test::Builder works, but is more JavaScript-like and sensible, so we felt it was best to break things early on rather than later. Suggested by Bob Ippolito.</li>
  <li>Added <code>beginAsync()</code> and <code>endAsync()</code> functions to Test.More. Suggested by Bob Ippolito.</li>
</ul>

<p>As always, feedback/comments/suggestions/winges welcome. Enjoy!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/javascript/test_simple-0.20.html">old layout</a>.</small></p>


