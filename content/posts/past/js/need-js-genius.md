--- 
date: 2005-08-09T04:31:40Z
slug: need-js-genius
title: Plea for Help from JavaScript Geniuses
aliases: [/computers/programming/javascript/need_js_genius.html]
tags: [JavaScript, DOM]
---

<p>I've been working for some time to get pure <em>.js</em> test files working with <a href="http://www.openjsan.org/doc/t/th/theory/Test/Simple/" title="Get Test.Simple on JSAN"><code>Test.Simple</code></a>. In principal, it's simple: The Browser harness simply constructs a hidden <code>iframe</code>, and if the test script ends in <em>.js</em>, it uses <code>document.write()</code> for that <code>iframe</code> to write out a new HTML document that includes the test script via a <code>script</code> tag. It can also load other scripts specified by the user in the <em>index.html</em> file that runs the harness.</p>

<p>I got it working, and then converted all of <code>Test.Simple</code>'s own tests over to <em>.js</em> files, at which point it got all weird. The tests were dying after the third test file was loaded and run. After weeks of on and off debugging, I've reduced the problem enough to find the following:</p>

<ul>
  <li>I'm using <a href="http://www.openjsan.org/doc/c/cw/cwest/JSAN/" title="JSAN on JSAN">JSAN</a> to load dependencies in the test scripts themselves. The browser harness loads it by writing a <code>script</code> tag into the <code>head</code> section of the <code>iframe</code>.</li>
  <li>The tests always use <code>JSAN</code> to load <code>Test.Builder</code>, either directly or by loading a library that depends on it (like <code>Test.More</code>.</li>
  <li><code>Test.Builder</code> detects when it's being run in a browser and sets an <code>onload</code> event handler to end the execution of tests.</li>
  <li>For the first two test files, <code>Test.Builder</code> loads and runs, and sets up the <code>onload</code> event handler, and it properly executes when the test finish.</li>
  <li>But in the third test, the <code>onload</code> event handler seems to run <em>before</em> <code>Test.Builder</code> has finished execution or even loading! As such, it cannot get access to the <code>Test.Builder</code> class to finish the tests, and throws an exception: <q>Error: this.Test has no properties</q>, where <code>this</code> is the <code>iframe</code> window object.</li>
</ul>

<p>The only thing I can guess is that it's retaining the <code>onload</code> event handler for the previous test file, even if I put <code>delete buffer.onload</code> before writing out the HTML to load the test file! (Note that <q><code>buffer</code></q> is the name of the variable that is holding the <code>contentWindow</code> attribute of the <code>iframe</code> object.) You can observe this behavior for yourself by <a href="/code/Test.Simple-0.11_1/tests/index.html" title="Run the broken test suite now!">running the tests</a> now. They don't work in Safari at all (I code to Firefox and then port to the other browsers), but Firefox demonstrates the issue. I have <code>alert()</code>s that run just before <code>Test.Builder</code> sets up the <code>onload</code> event handler, and then inside the event handler, either when its run or when it catches an exception (but before it rethrows it). The order of execution, you'll note, is as follows:</p>

<ul>
  <li><q>async.js..........</q> output to browser</li>
  <li><code>alert("Setup: buffer")</code> during the execution of <code>Test.Builder</code> for <em>async.js</em>, where "buffer" is the name of the <code>iframe</code> element.</li>
  <li><code>alert("Onload: buffer")</code> for <em>async.js</em>, during the execution of the <code>onload</code> event</li>
  <li><q>bad_plan.js.......</q> output to browser</li>
  <li><code>alert("Setup: buffer")</code> during the execution of <code>Test.Builder</code> for <em>bad_plan.js</em></li>
  <li><code>alert("Onload: buffer")</code> for <em>bad_plan.js</em>, during the execution of the <code>onload</code> event</li>
  <li><q>buffer.js........</q> output to browser</li>
  <li><code>alert("Catch: buffer")</code> output from catching the exception in the <code>onload</code> handler for <em>buffer.js</em>, which, of course, <code>Test.builder</code> hasn't set up yet!</li>
</ul>

<p>If I don't rethrow the exception, it then runs the code in <code>Test.Builder</code> that sets up the <code>onload</code> handler. In other words, the <code>onload</code> handler runs <em>before</em> it has been created. Huh?</p>

<p>The nearest to a workaround that I've found is to delete the <code>iframe</code> element after each test and create a new one. The errors are still thrown, but all tests seem to pass anyway. It doesn't seem to like the old-style <em>.html</em> test files, though; it hangs on them without throwing any error at all. Grrrr.</p>

<p>So, are you a JavaScript genius? Do you know how the browser, DOM, and frames work and interact better than you know your own family? If so, please, <em>please</em> give me a hint as to what I can do to fix this problem so that I can get a new version of <code>Test.Simple</code> out ASAP. Thanks!</p>

<p><strong>Update:</strong> I forgot to mention that the in-progress source code for <code>Test.Simple</code> with support for <em>.js</em> test files can be <a href="/code/Test.Simple-0.11_1.tar.gz" title="Download Test.Simple 0.11_1">downloaded here</a>, so that you can play with it on your own system. Thanks!</p>
<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/javascript/need_js_genius.html">old layout</a>.</small></p>


