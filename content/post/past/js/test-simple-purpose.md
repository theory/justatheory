--- 
date: 2005-05-03T00:16:52Z
slug: test-simple-purpose
title: The Purpose of TestSimple
aliases: [/computers/programming/javascript/test_simple_purpose.html]
tags: [JavaScript, testing, unit testing, Perl, N1VUX]
type: post
---

<p>In response to my <a href="/computers/programming/javascript/test_simple-0.03.html" title="TestSimple 0.03 Released">TestSimple 0.03 announcement</a>, Bill N1VUX asked a number of important questions about TestSimple's purpose. Since this is just an alpha release and I'm still making my way though the port, I haven't created a project page or started to promote it much, yet. Once I get the harness part written and feel like it's stable and working well, I'll likely start to promote it as widely as possible.</p>

<p>But yes, TestSimple is designed for doing unit testing in JavaScript. Of all the JavaScript I've seen, I've never seen any decent unit tests. People sometimes write a few integration tests to test them in browsers, but don't write many tests that would ensure that their JS code runs where they need it to run and that would give them the freedom to refactor. There is generally very little coverage in JavaScript tests&#x2014;if there are any tests at all.</p>

<p>While it's true that JavaScript is nearly always an <em>embedded</em> language (but see also <a href="http://www.mozilla.org/rhino/" title="Rhino includes a command-line JavaScript interpreter!">Rhino</a> and <a href="http://www.mozilla.org/js/spidermonkey/" title="SpiderMonkey has a command-line JavaScript interpreter, too!">SpiderMonkey</a>), that doesn't mean that one doesn't write a lot of JavaScript functions or classes that need testing. It's also important to have a lot of tests you can run in various browsers (just as you can run tests of a Perl module on various OSs and various versions of Perl). I started the port because, as I was learning JavaScript, I realized that I didn't want to write much without writing tests. The purpose is to ensure the quality of JavaScript code as it goes through the development process. And the freedom to refactor that tests offer is very important for my personal development style.</p>

<p>So, to answer N1VUX's questions:</p>

<blockquote><p>Is the point to integration test the whole distributed front-ends of applications from the (EcmaScript compliant) browser?</p></blockquote>

<p>Yes. And I expect that, as people write more JavaScript applications, there will be a lot more code that needs testing. However, unlike other JavaScript testing frameworks I've seen (all based on the xUnit framework), my suite doesn't assume that tests will be run in a browser. Ultimately, I'd like to be able to automate tests outside of browsers&#x2014;or by scripting browsers. But in the meantime, it will produce TAP-compliant output in the browser, and I plan on implementing a harness that will run all of your test scripts in a single browser window and output the results, just like Test::Harness does for Perl modules on the command-line.</p>

<blockquote><p>Or to unit test the client-side java-script as an entity, mocking the server??</p></blockquote>

<p>Yes, I would like to be able to do that eventually. I will likely mock the server by mocking XMLHttpRequest and Microsoft.XMLHTTP to return XML strings that can be used for testing. Stuff like that.</p>

<blockquote><p>Or is the point to Unit test JavaScript functions in the browser <em>in vitro,</em> mocking everything outside the current function?</p></blockquote>

<p>If need be, yes. The point is that you have the freedom to do it the way that makes sense to your particular project. The testing framework itself doesn't care where it's run or how.</p>

<blockquote><p>Or is this for Unit Testing of the Presentation Layer on the server from the Browser? (If so, how can a JavaScript arrange to Mock the Model layer?)</p></blockquote>

<p>Probably not, but again, it depends on the model of your application. I've tried to make no assumptions, just provide you with the tools to easily test your application. I hope and expect that others will start creating the appropriate JavaScript libraries to start mocking whatever other APIs one needs to fully unit test JavaScript code that relies on such libraries.</p>

<blockquote><p>Or is it more likely for driving Integration Testing from the browser with the scripting simplicity we've come to love, without resorting to OLE-stuffing the browser from Perl?</p></blockquote>

<p>That was my initial impetus, yes.</p>

<blockquote><p>Digging into the TAR file (<em>which I normally wouldn't do before peaking at the web copy of the POD2HTML's</em>) I think I understand it's for <strong>unit-testing JavaScript classes</strong>, which I hadn't even considered. (<em>JavaScript has classes that fancy? *shudder* no wonder pages don't work between browser versions.</em>) I hope I don't need to do that.</p></blockquote>

<p>Yes, as more people follow Google's lead, more and more applications will be appearing in JavaScript, and they will require a lot of code. JavaScript already supports a prototype-based object-orientation scheme, and if <a href="http://www.mozilla.org/js/language/js20/index.html" title="Netscape's JavaScript 2.0 design document">JavaScript 2.0</a> ever becomes a reality (please, please, please, please <em>please!</em>), then we'll have real <a href="http://www.mozilla.org/js/language/js20/core/classes.html" title="JavaScript 2.0 Classes">classes</a>, <a href="http://www.mozilla.org/js/language/js20/core/namespaces.html" title="JavaScript 2.0 Namespaces">namespaces</a>, and even <a href="http://www.mozilla.org/js/language/js20/core/packages.html#import" title="JavaScript 2.0 import directive"><code>import</code></a>, <a href="http://www.mozilla.org/js/language/js20/core/statements.html#N-IncludeDirective" title="JavaScript include directive"><code>include</code></a> and <a href="http://www.mozilla.org/js/language/es4/core/pragmas.html" title="ECMAScript 4 Pragmas"><code>use</code></a>! Testing will become increasingly important as more organizations come to rely on growing amounts of production JavaScript code.</p>
