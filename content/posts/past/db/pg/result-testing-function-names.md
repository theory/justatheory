--- 
date: 2009-06-08T00:06:26Z
slug: result-testing-function-names
title: Need Help Naming Result Set Testing Functions
aliases: [/computers/databases/postgresql/result-testing-function-names.html]
tags: [Postgres, SQL, pgTAP, testing, unit testing]
---

<p>I've been thinking more since I posted about <a href="/computers/databases/postgresql/comparing-relations.html" title="Thoughts on Testing SQL Result Sets">testing SQL result sets</a>, and I think I've settled on two sets of functions for pgTAP: one that tests two SQL queries (though you will be encouraged to use a prepared statement), and one to test two cursors. I'm thinking of naming them:</p>

<ul>
  <li><code>query_gets()</code></li>
  <li><code>cursor_gets()</code></li>
</ul>

<p>I had been planning on <code>*_returns()</code> or <code>*_yields()</code>, but they didn't feel
right. “Returns” implies that I would be passing a query and a data structure (to me at least), and while I want to support that, too, it's not what I was looking for right now. “Yield,” on the other hand, is more related to set-returning functions in my mind (even if PL/pgSQL doesn't use that term). Anyway, I like the use of “gets” because it's short and pretty unambiguous.</p>

<p>These function will compare query results as unordered sets, but I want variants that test ordered sets, as well. I've been struggling to come up with a decent name for these variants, but not liking any very well. The obvious ones are:</p>

<ul>
  <li><code>ordered_query_gets()</code></li>
  <li><code>ordered_cursor_gets()</code></li>
</ul>

<p>And:</p>

<ul>
  <li><code>sorted_query_gets()</code></li>
  <li><code>sorted_cursor_gets()</code></li>
</ul>

<p>But these are kind of long for functions that will be, I believe, used frequently. I could just add a character to get the same idea, in the spirit of <code>sprintf</code>:</p>

<ul>
  <li><code>oquery_gets()</code></li>
  <li><code>ocursor_gets()</code></li>
</ul>

<p>Or:</p>

<ul>
  <li><code>squery_gets()</code></li>
  <li><code>scursor_gets()</code></li>
</ul>

<p>I think that these are okay, but might be somewhat confusing. I think that the “s” variant probably won't fly, since for <code>sprintf</code> and friends, the “s” stands for “string.” So I'm leaning towards the “o” variants.</p>

<p>But I'm throwing it out there for the masses to make suggestions: Got any ideas for better function names? Are there some relational terms for ordered sets, for example, that might make more sense? What do you think?</p>

<p>As a side note, I'm also considering:</p>

<ul>
  <li><code>col_is()</code> to compare the result of a single column query to an array or other query. This would need an ordered variant, as well.</li>
  <li><code>row_is()</code>, although I have no idea how I'd be able to support passing a row expression to a function, since PostgreSQL doesn't allow <code>RECORD</code>s to be passed to functions.</li>
</ul>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/result-testing-function-names.html">old layout</a>.</small></p>


