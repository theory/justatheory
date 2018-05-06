--- 
date: 2005-08-22T21:55:26Z
slug: js-ie-dom-help
title: IE DOM Help
aliases: [/computers/programming/javascript/ie_dom_help.html]
tags: [JavaScript, Internet Explorer, DOM]
---

<p>I got Test.Harness.Browser working with IE 6 SP 2 today, but decided to spend a bit of time trying to get it working with the DOM script inclusion approach instead of the XMLHttpRequest approach. The code that causes the problem is this (<code>pre</code> is a pre element generated with the DOM API):</p>

<pre>
el = doc.createElement(&quot;script&quot;);
el.type = &quot;text/javascript&quot;;
// XXX IE chokes on this line.
el.appendChild(doc.createTextNode(&quot;window.onload(null, Test)&quot;));
pre.appendChild(el);
</pre>

<p>This works great in Firefox, but IE 6 doesn't like the call to <code>appendChild()</code>. It says, <q>Unexpected call to method or property access.</q> So I tried to replace that line with:</p>

<pre>
el.innerHTML = &quot;window.onload(null, Test);&quot;;
</pre>

<p>Firefox is still happy, but now IE 6 says, <q>Unknown runtime error.</q> If I try to just append a script tag to <code>pre.innerHTML</code>, I get no error, but the code doesn't seem to execute, either. In fact, pre.innerHTML appears to be empty!</p>

<p>Anyone have any idea how I can dynamically write to a script element that I've created via the DOM?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/javascript/ie_dom_help.html">old layout</a>.</small></p>


