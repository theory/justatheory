--- 
date: 2009-07-01T21:32:28Z
slug: results-eq
title: "Committed: pgTAP Result Set Assertion Functions"
aliases: [/computers/databases/postgresql/results_eq.html]
tags: [Postgres, pgTAP, SQL, testing]
---

<p>Regular readers will know that I've been thinking a lot about
<a href="/computers/databases/postgresql/comparing-relations.html" title="Thoughts on Testing SQL Result Sets">testing SQL result sets</a> and
how to <a href="/computers/databases/postgresql/result-testing-function-names.html" title="Need Help Naming Result Set Testing Functions">how to name result testing functions</a>,
and various <a href="/computers/databases/postgresql/set_testing_update.html" title="pgTAP Set-Testing Update">implementation issues</a>. I am very happy
to say that I've now committed the first three such test functions to the
<a href="http://github.com/theory/pgtap/tree/master/" title="Get the pgTAP source on GitHub">Git repository</a>. They've been tested
on 8.4 and 8.3. Here's what I came up with.</p>

<p>I had a pretty good idea how to compare sets and how to compare ordered
bags, but ordered sets and unordered bags of results escaped me. During two
days of intense hacking and experimentation, I quickly wrote
<code>set_eq()</code>, which performs a set comparison of the results of two
queries, and <code>obag_eq()</code>, which performs a row-by-row comparison of
the results of two queries. I then set to work on <code>bag_eq()</code>, which
would do a set comparison but require the same number of duplicate rows
between the two queries. <code>set_eq()</code> was easy because I just needed
to create temporary tables of the two queries and then execute
two <code>EXCEPT</code> queries against them to see where they differ, if at
all. <code>bag_eq()</code> was getting kind of hairy, though, so I asked about
it on the Freenode #postgresql channel, where <a href="http://www.depesz.com/" title="select * from depesz">depesz</a> looked at my example and pointed out
that <code>EXCEPT ALL</code> would do just want I needed.</p>

<p>Hot damn, all it took was the addition a single extra word to the same
queries used by <code>set_eq()</code> and I was set. This made me very happy,
and such well-thought-out features are the reason I love PostgreSQL. My main
man depesz made my day.</p>

<p>But <code>oset_eq()</code>, which was to compare ordered sets of results was
proving much harder. The relational operators that operate on sets don't care
about order, so I would have to write the code to care myself. And because
dupes needed to be ignored, it got even harder. In fact, it proved just not
worth the effort. The main reason I abandoned this test function, though, was
not difficulties of implementation (which were significant), but ambiguity of
interpretation. After all, if duplicates are allowed but ignored, how does one
deal with their effect on order? For example, say that I have two queries that
order people based on name. One query might order them like so:</p>

<pre>
select * from people order by name;
  name  | age 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Damian |  19
 Larry  |  53
 Tom    |  35
 Tom    |  44
 Tom    |  35
</pre>

<p>Another run of the same query could give me a different order:</p>

<pre>
select * from people order by name;
  name  | age 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Damian |  19
 Larry  |  53
 Tom    |  35
 Tom    |  35
 Tom    |  44
</pre>

<p>Because I ordered only on “name,” the database was free to sort records
with the same name in an undefined way. Meaning that the rows could be in
different orders. This is known, if I understand correctly, as a
“<a href="https://en.wikipedia.org/wiki/Partially_ordered_set" title="Wikipedia: Partially ordered set">Partially ordered set</a>,” or
“poset.” Which is all well and good, but from my point of view makes it damn
near impossible to be able to do a row-by-row comparison and ignore dupes,
because they could be in different orders!</p>

<p>So once I gave up on that, I was down to three functions instead of four,
and only one depends on ordering. So I also dropped the idea of having the “o”
in the function names. Instead, I changed <code>obag_eq()</code> to
<code>results_eq()</code>, and now I think I have three much more descriptive
names. To summarize, the functions are:</p>

<dl>
  <dt><code>results_eq</code></dt>
  <dd>Compares two result sets row by row, meaning that they must be in the same order and have the same number of duplicate rows in the same places.</dd>
  <dt><code>set_eq</code></dt>
  <dd>Compares result sets to ensure they have the same rows, without regard to order or duplicate rows.</dd>
  <dt><code>bag_eq</code></dt>
  <dd>Compares result sets without regard to order, but each must have the same duplicate rows.</dd>
</dl>

<p>I'm very happy with this, because I was able to give up on the stupid
function names with the word “order” included or implicit in them. Plus, I
have different names for functions that are similar, which is nicely
in adherence to the
<a href="http://www.perl.com/pub/a/2003/06/25/perl6essentials.html" title="Perl 6 Design Philosophy">principle of distinction</a>. They all
provide nice diagnostics on failure, as well, like this
from <code>results_eq()</code>:</p>

<pre>
# Failed test 146
#     Results differ beginning at row 3:
#         have: (1,Anna)
#         want: (22,Betty)
</pre>

<p>Or this from <code>set_eq()</code> or <code>bag_eq()</code></p>

<pre>
# Failed test 146
#     Extra records:
#         (87,Jackson)
#         (1,Jacob)
#     Missing records:
#         (44,Anna)
#         (86,Angelina)
</pre>

<p><code>set_eq()</code> and <code>bag_eq()</code> also offer up useful
diagnostics when the data types of the rows vary:</p>

<pre>
# Failed test 147
#     Columns differ between queries:
#         have: (integer,text)
#         want: (text,integer)
</pre>

<p><code>results_eq()</code> doesn't have access to such data, though if I can
find some tuits (got any to give me?), I'll write a quick C function that can
return an array of the data types in a <code>record</code> object.</p>

<p>Now, as for the issue of arguments, what I settled on is,
like <a href="http://epictest.org/" title="Epic, more full of fail than any other testing tool">Epic</a>, passing strings of SQL to these functions.
However, unlike Epic, if you pass in a simple string with no spaces, or a
double-quoted string, pgTAP assumes that it's the name of a prepared
statement. The documentation now recommends prepared statements, which you can
use like this:</p>

<pre>
PREPARE my_test AS SELECT * FROM active_users() WHERE name LIKE 'A%';
PREPARE expect AS SELECT * FROM users WHERE active = $1 AND name LIKE $2;
SELECT results_eq(&#x0027;my_test&#x0027;, &#x0027;expect&#x0027;);
</pre>

<p>This allows you to keep your SQL written as SQL, keeping your test, um,
SQLish. But in those cases where you have some really simple SQL, you can
just use that, too:</p>

<pre>
SELECT set_eq(
    &#x0027;SELECT * FROM active_users()&#x0027;,
    &#x0027;SELECT * FROM users ORDER BY id&#x0027;
);
</pre>

<p>This feels like a good compromise to me, allowing the best of both worlds:
keeping things in pure SQL to avoid quoting ugliness in SQL strings, while
letting users pass in SQL strings if they really want to.</p>

<p>It turns out that I wasn't able to support cursors
for <code>set_eq()</code> or <code>bag_eq()</code>, because they
use the statements passed to them to create temporary tables and then compare
the records in those temporary tables. But <code>results_eq()</code> uses
cursors internally. And it turns out that there's a data type for cursors,
<code>refcursor</code>. So it was easy to add cursor support
to <code>results_eq()</code> for those who want to use it:</p>

<pre>
DECLARE cwant CURSOR FOR SELECT * FROM active_users();
DECLARE chave CURSOR FOR SELECT * FROM users WHERE active ORDER BY name;
SELECT results_eq(&#x0027;cwant&#x0027;::refcursor, &#x0027;chave&#x0027;::refcursor );
</pre>

<p>Neat, huh? As I said, I'm very pleased with this approach overall. There
are a few caveats, such as less strict comparisons in
<code>results_eq()</code> on 8.3 and lower, and less useful diagnostics
for data type differences in <code>results_eq()</code>, but overall, I
think that the implementation is pretty good, and that these functions
will be really useful.</p>

<p>So what do you think? Please clone
the <a href="http://github.com/theory/pgtap/tree/master/" title="Get the pgTAP source on GitHub">Git repository</a> and take the
functions for a test drive on 8.3 or 8.4. Let me know what you think!</p>

<p>In the meantime, before releasing a new version, I still plan to add:</p>

<ul>
  <li><code>set_includes()</code> - Set includes records in another set.</li>
  <li><code>set_excludes()</code> - Set excludes records in another set.</li>
  <li><code>bag_includes()</code> - Bag includes records in another bag.</li>
  <li><code>bag_excludes()</code> - Bag excludes records in another bag.</li>
  <li><code>col_eq()</code> - Single column result set equivalent to an array of values.</li>
  <li><code>row_eq()</code> - Single row form a query equivalent to a record.</li>
  <li><code>rowtype_is()</code> - The data type of the rows in a query is equivalent to an array of types.</li>
</ul>

<p>Hopefully I can find some time to work on those next week. The only challenging one is
<code>row_eq()</code>, so I may skip that one for now.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/results_eq.html">old layout</a>.</small></p>


