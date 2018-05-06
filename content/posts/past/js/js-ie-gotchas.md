--- 
date: 2005-04-29T19:38:19Z
slug: js-ie-gotchas
title: Quirks of IE's JavaScript Implementation
aliases: [/computers/programming/javascript/ie_gotchas.html]
tags: [JavaScript, Internet Explorer, Gotchas, JScript, Firefox, line endings, oxford comma]
---

<p>Just a few notes about the quirks of IE's JavaScript implementation that I
had to figure out and work around to
get <a href="/computers/programming/javascript/test_simple-0.03.html" title="TestSimple 0.03 Released">TestSimple</a> working in IE.:</p>

<ul>
  <li>
    <p>IE doesn't like serial commas. In other words, If I create an object
  like this:</p>
    <pre>var obj = {
    foo: &quot;yow&quot;,
    bar: &quot;bat&quot;,
};
</pre>
    <p>IE will complain. It seems it doesn't like that last comma, but it
    doesn't give you a decent diagnostic message to help you figure out that
    that's what it doesn't like. Fortunately, I didn't have to figure this one
    out; <a href="http://www.spastically.com/" title="Spastically">Marshall</a> did And now I know to expect that IE
    thinks that its JavaScript should parse like SQL. Whatever!</p>
  </li>
  <li>
    <p>You can't truncate an array using a single argument
      to <code>splice()</code>.  In Firefox, <code>ary.splice(0)</code> will
      truncate the array, but in IE, you must provide the second argument,
      like this: <code>ary.splice(0, ary.length)</code>&#x2014;or else it
      won't actually truncate the array.</p>
  </li>
  <li>
    <p>Many IE JavaScript functions don't seem to actually inherit from the
    Function class! I discovered this when I tried to
    call <a href="/computers/programming/javascript/apply_on_write.html" title="How do I Add apply() to IE JavaScript Functions?"><code>document.write.apply()</code></a> and it failed. Not only
    does the <code>apply()</code> method not exist, but I can't even add it!  I
    came up with a decent workaround for this problem in TestBuilder, but I
    still don't have a general solution to the problem. I did
    find <a href="http://www.technicalpursuit.com/documents_codingstds.html" title="TIBET&#8482; Coding Standards &amp; Sample Code">a page</a> that might
    have a general solution, but it sure is ugly.</p>
  </li>
  <li>
    <p>IE automatically converts line endings in to the platform specific
    alternatives whenever you assign a JavaScript string to a text element.
    When Marshall showed me output that wasn't properly adding <q>#</q> after
      all line endings, this was my immediate suspicion, and a quick Googling
      <a href="http://simon.incutio.com/archive/2004/02/17/lineEndings" title="Automatic line ending conversions in IE">confirmed the issue</a>. So I had to add regular expressions to look for all
      variations on the line endings.</p>
  </li>
</ul>

<p>I'm sure I'll notice other issues as I work more with JavaScript, but feel
free to chime in here with any gotchas you've noticed, and then I won't have
to work so hard to figure them out on my own in the future (and neither will
you)!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/programming/javascript/ie_gotchas.html">old layout</a>.</small></p>


