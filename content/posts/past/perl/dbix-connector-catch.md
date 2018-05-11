--- 
date: 2011-05-10T21:12:11Z
slug: dbix-connector-catch
title: DBIx::Connector Exception Handling Design
aliases: [/computers/programming/perl/modules/dbix-connector-catch.html]
tags: [Perl, database, DBIx::Connector, exception handling, DBI]
---

<p>In response to a <a href="http://rt.cpan.org/Ticket/Display.html?id=65196">bug report</a>, I removed the documentation suggesting that one use the <code>catch</code> function exported by <a href="http://search.cpan.org/perldoc?Try::Tiny">Try::Tiny</a> to specify an exception-handling function to the <a href="http://search.cpan.org/perldoc?DBIx::Connector">DBIx::Connector</a> execution methods. When I wrote those docs, Try::Tiny's <code>catch</code> method just returned the subroutine. It was later changed to return an object, and that didn't work very well. It seemed a much better idea not to depend on an external function that could change its behavior when there is no direct dependency on Try::Tiny in DBIx::Connector. I removed that documentation in 0.43. So instead of this:</p>

<pre><code>$conn-&gt;run(fixup =&gt; sub {
    ...
}, catch {
    ...
});
</code></pre>

<p>It now recommends this:</p>

<pre><code>$conn-&gt;run(fixup =&gt; sub {
    ...
}, catch =&gt; sub {
    ...
});
</code></pre>

<p>Which frankly is better balanced anyway.</p>

<p>But in discussion with Mark Lawrence in <a href="http://rt.cpan.org/Ticket/Display.html?id=65196">the ticket</a>, it has become clear that there's a bit of a design problem with this approach. And that problem is that there is no <code>try</code> keyword, only <code>catch</code>. The <code>fixup</code> in the above example does not <code>try</code>, but the inclusion of the <code>catch</code> <em>implicitly</em> makes it behave like <code>try</code>. That also means that if you use the default mode (which  can be set via the <a href="http://search.cpan.org/dist/DBIx-Connector/lib/DBIx/Connector.pm#mode"><code>mode</code> method</a>), then there will usually be no leading keyword, either. So we get something like this:</p>

<pre><code>$conn-&gt;run(sub {
    ...
}, catch =&gt; sub {
    ...
});
</code></pre>

<p>So it starts with a <code>sub {}</code> and no <code>fixup</code> keyword, but there is a <code>catch</code> keyword, which implicitly wraps that first <code>sub {}</code> in a <code>try</code>-like context. And aesthetically, it's unbalanced.</p>

<p>So I'm trying to decide what to do about these facts:</p>

<ul>
<li>The <code>catch</code> implicitly makes the first sub be wrapped in a <code>try</code>-type context but without a <code>try</code>-like keyword.</li>
<li>If one specifies no mode for the first sub but has a <code>catch</code>, then it looks unbalanced.</li>
</ul>

<p>At one level, I'm beginning to think that it was a mistake to add the exception-handling code at all. Really, that should be the domain of another module like Try::Tiny or, better, the language. In that case, the example would become:</p>

<pre><code>use Try::Tiny;
try {
    $conn-&gt;run(sub {
        ...
    });
} catch {
  ....
}
</code></pre>

<p>And maybe that really should be the recommended approach. It seems silly to have replicated most of Try::Tiny inside DBIx::Connector just to cut down on the number of anonymous subs and indentation levels. The latter can be got round with some semi-hinky nesting:</p>

<pre><code>try { $conn-&gt;run(sub {
    ...
}) } catch {
    ...
}
</code></pre>

<p>Kind of ugly, though. The whole reason the <code>catch</code> stuff was added to DBIx::Connector was to make it all nice and integrated (as discussed <a href="https://github.com/theory/dbix-connector/issues/3">here</a>). But perhaps it was not a valid tradeoff. I'm not sure.</p>

<p>So I'm trying to decide how to solve these problems. The options as I see them are:</p>

<ol>
<li><p>Add another keyword to use before the first sub that means "the default mode". I'm not keen on the word "default", but it would look something like this:</p>

<pre><code>$conn-&gt;run(default =&gt; sub {
    ...
}, catch =&gt; sub {
    ...
});
</code></pre>

<p>This would provide the needed balance, but the <code>catch</code> would still implicitly execute the first sub in a <code>try</code> context. Which isn't a great idea.</p></li>
<li><p>Add a <code>try</code> keyword. So then one could do this:</p>

<pre><code>$conn-&gt;run(try =&gt; sub {
    ...
}, catch =&gt; sub {
    ...
});
</code></pre>

<p>This makes it explicit that the first sub executes in a <code>try</code> context. I'd also have to add companion <code>try_fixup</code>, <code>try_ping</code>, and <code>try_no_ping</code> keywords. Which are ugly. And furthermore, if there <em>was</em> no <code>try</code> keyword, would a <code>catch</code> be ignored? That's what would be expected, but it changes the current behavior.</p></li>
<li><p>Deprecate the <code>try</code>/<code>catch</code> stuff in DBIx::Connector and eventually remove it. This would simplify the code and leave the responsibility for exception handling to other modules where it's more appropriate. But it would also be at the expense of formatting; it's just a little less aesthetically pleasing to have the <code>try</code>/<code>catch</code> stuff outside the method calls. But maybe it's just more appropriate.</p></li>
</ol>

<p>I'm leaning toward #3, but perhaps might do #1 anyway, as it'd be nice to be more explicit and one would get the benefit of the balance with <code>catch</code> blocks for as long as they're retained. But I'm not sure yet. I want your feedback on this. How do you want to use exception-handling with DBIx::Connector? Leave me a comment here or on <a href="https://rt.cpan.org/Ticket/Display.html?id=65196">the ticket</a>.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/programming/perl/modules/dbix-connector-catch.html">old layout</a>.</small></p>


