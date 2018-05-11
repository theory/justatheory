--- 
date: 2009-06-01T22:13:00Z
slug: comparing-relations
title: Thoughts on Testing SQL Result Sets
aliases: [/computers/databases/postgresql/comparing-relations.html]
tags: [Postgres, pgTAP, SQL]
---

<h3>pgTAP: The Critique</h3>

<p>I've been continuing hacking on <a href="http://pgtap.projects.postgresql.org/" title="pgTAP: Unit Testing for PostgreSQL">pgTAP</a> in order to add a lot more
schema-testing functionality and a few other niceties. But back when I started
the project, I using it to write tests for <a href="/computers/databases/postgresql/citext-patch-submitted.html" title="CITEXT Patch Submitted to PostgreSQL Contrib">CITEXT</a>, which was great for my
sanity as I developed it, but proved a bit controversial. In a
<a href="http://archives.postgresql.org/pgsql-hackers/2008-07/msg00627.php" title="Tom Lane on pgsql-hackers: “Re: PATCH: CITEXT 2.0 v3”">pgsql-hackers post</a>, Tom Lane wrote:</p>

<blockquote><p>There was some discussion earlier about whether the proposed regression
tests for citext are suitable for use in contrib or not.  After playing
with them for awhile, I have to come down very firmly on the side of
&quot;not&quot;.  I have these gripes:</p>

<ol>
<li><p>The style is gratuitously different from every other regression test
in the system.  This is not a good thing.  If it were an amazingly
better way to do things, then maybe, but as far as I can tell the style
pgTAP forces on you is really pretty darn poorly suited for SQL tests.
You have to contort what could naturally be expressed in SQL as a table
result into a scalar. Plus it’s redundant with the expected-output file.</p></li>
<li><p>It’s ridiculously slow; at least a factor of ten slower than doing
equivalent tests directly in SQL.  This is a very bad thing.  Speed of
regression tests matters a lot to those of us who run them a dozen times
per day —– and I do not wish to discourage any developers who don’t
work that way from learning better habits ;–)</p></li>
</ol>


<p>Because of #1 and #2 I find the use of pgTAP to be a nonstarter.</p></blockquote>

<p>These are legitimate criticisms, of course. To take the second item first, I
would eventually like to figure out a way to make pgTAP a lot faster (in my
own benchmarks, I found it to be about 4 times slower than pure SQL, not ten
times, but still). A number of functions can likely be rewritten in C, and
maybe data can be stored in memory rather than in a temporary table. Overall,
though, the speed of the tests doesn’t really concern me much. I'm quite used
to large test suites, such as that for <a href="http://www.bricolagecms.org/" title="Bricolage Content Management and Publishing System">Bricolage</a>, that take 5 or 10
minutes or more. This is because, compared to the time it would take me to
maintain the code without tests, it’s nothing. I find and fix bugs much more
quickly thanks to regression tests. And really, one should just run a subset
of the tests for whatever one is working on, and then run the full suite
before checking in. One could even have a larger, more comprehensive (read:
slower) test suite that’s run via a cron job, so that it identifies bugs in
checked in code but developers don’t have to spend a lot of time waiting for
tests to finish running.</p>

<p>As a result, I wouldn’t advocate for converting the existing PostgreSQL
regression test suite to pgTAP. I could see writing a new suite of tests on
pgTAP that run on the <a href="http://buildfarm.postgresql.org/" title="PostgreSQL Build Farm">build farm</a>. This would be great, as they would
complement the existing test suite, and be able to test stuff that can’t be
tested with <code>pg_regress</code>.</p>

<p>So really, the performance issue can be addressed in a few ways, some
technical, some social, some structural. Like I said, I'm not overly concerned
about it, and I wouldn’t make Tom suffer unduly from it, either (I converted
all of the CITEXT tests to plain SQL).</p>

<h3>Coercing Composite Values</h3>

<p>The first issue is tougher, however. Tom was responding to a test like this:</p>

<pre><code>SELECT is(
    ARRAY( SELECT name FROM srt ORDER BY name )::text,
    ARRAY[&#x0027;AAA&#x0027;, &#x0027;aardvark&#x0027;, &#x0027;aba&#x0027;, &#x0027;ABC&#x0027;, &#x0027;abc&#x0027;]::text,
    &#x0027;The words should be case-insensitively sorted&#x0027;
);
</code></pre>

<p>Now, I agree that it’s redundant with the expected-output file, but the
assumption with <a href="http://testanything.org/" title="TAP: Test Anything Protocol">TAP</a> is that there <em>is no</em> expected output file: you just
analyze its output using a <a href="http://search.cpan.org/perldoc?TAP::Harness" title="TAP::Harness on CPAN">harness</a>. The need for an expected output file
is driven by the legacy of <code>pg_regress</code>.</p>

<p>A bigger issue, and the one I'll focus on for the remainder of this post, is
the requirement currently inherent in pgTAP to “contort what could naturally
be expressed in SQL as a table result into a scalar.” The issue is apparent in
the above example: even though I'm selecting a number of rows from a table, I
use the <code>ARRAY()</code> constructor function to force them into a scalar value—an
array—in order to easily do the comparison. It also results in a useful
diagnostic message in case the test fails:</p>

<pre><code># Failed test 40: "The words should be case-insensitively sorted"
#         have: {AAA,aardvark,ABC,abc,aba}
#         want: {AAA,aardvark,aba,ABC,abc}
</code></pre>

<p>So for simple cases like this, it doesn’t bother me much personally. But I've
also had to write tests for functions that return composite types—that is,
<em>rows</em>—and again I had to fall back on coercing them into scalar values to do
the comparison. For example, say that the <code>fooey()</code> function returns a <code>dude</code>
value, which is a composite type with an integer and a text string. Here’s how
to test it with pgTAP:</p>

<pre><code>SELECT is(
    fooey()::text,
    ROW( 42, &#x0027;Bob&#x0027; )::text,
    &#x0027;Should get what we expect from fooey()&#x0027;
);
</code></pre>

<p>So I'm again coercing a value into something else (of course, if I could pass
<code>record</code>s to functions, that issue goes away). And it does yield nice
diagnostics on failure:</p>

<pre><code># Failed test 96: "Should get what we expect from fooey()"
#         have: (42,Fred)
#         want: (42,Bob)
</code></pre>

<p>It gets much worse with set returning functions—Tom’s “table result:” it
requires both type <em>and</em> row coercion (or “contortion” if you'd prefer). Here’s
an example of a <code>fooies()</code> function that returns a set of <code>dude</code>s:</p>

<pre><code>SELECT is(
    ARRAY( SELECT ROW(f.*)::text FROM fooies() f ),
    ARRAY[
        ROW( 42, &#x0027;Fred&#x0027; )::text,
        ROW( 99, &#x0027;Bob&#x0027; )::text
    ],
    &#x0027;Should get what we expect from fooies()&#x0027;
);
</code></pre>

<p>As you can see, it’s do-able, but clumsy and error prone. We really are taking
a table result and turning into a scalar value. And thanks to the casts to
<code>text</code>, the test can actually incorrectly pass if, for example, the integer
was actually stored as text (although, to be fair, the same is true of a
<code>pg_regress</code> test, where <em>everything</em> is converted to text before comparing
results).</p>

<p>What we <em>really</em> need is a way to write two queries and compare their <em>result
sets,</em> preferably without any nasty casts or coercion into scalar values, and
with decent diagnostics when a test fails.</p>

<p>As an aside, another approach is to use <code>EXCEPT</code> queries to make sure that two
data sets are the same:</p>

<pre><code>SELECT ok(
    NOT EXISTS (
        (SELECT 42, &#x0027;Fred&#x0027; UNION SELECT 99, &#x0027;Bob&#x0027;)
        EXCEPT
        SELECT * from fooies()
    ),
    &#x0027;Should get what we expect from fooies()&#x0027;
);

SELECT ok(
    NOT EXISTS (
        SELECT * from fooies()
        EXCEPT
        (SELECT 42, &#x0027;Fred&#x0027; UNION SELECT 99, &#x0027;Bob&#x0027;)
    ),
    &#x0027;Should have no unexpected rows from fooies()&#x0027;
);
</code></pre>

<p>Here I've created two separate tests. The first makes sure that <code>fooies()</code>
returns all the expected rows, and the second makes sure that it doesn’t
return any unexpected rows. But since this is just a boolean test (yes, we've
coerced the results into booleans!), there are no diagnostics if the test
fails: you'd have to go ahead and run the query yourself to see what’s
unexpected. Again, this is do-able, and probably a more correct comparison
than using the casts of rows to <code>text</code>, but makes it harder to diagnose
failures. And besides, <code>EXCEPT</code> compares sets, which are inherently unordered.
That means that if you need to test that results come back in a specific
order, you can’t use this approach.</p>

<p>That said, if someone knows of a way to do this in one query—somehow make
some sort of <code>NOT EXCEPT</code> operator work—I'd be very glad to hear it!</p>

<h3>Prior Art</h3>

<p>pgTAP isn’t the only game in town. There is also Dmitry Koterov’s <a href="http://en.dklab.ru/lib/dklab_pgunit/" title="PGUnit: stored procedures unit-test framework for PostgreSQL 8.3">PGUnit</a>
framework and Bob Brewer’s <a href="http://epictest.org/" title="Epic: more full of fail than any other testing tool">Epic</a>. PGUnit seems to have one main assertion
function, <code>assert_same()</code>, which works much like pgTAP’s <code>is()</code>. Epic’s
<code>assert_equal()</code> does, too, but Epic also offers a few functions for testing
result sets that neither pgTAP nor PGUnit support. One such function is
<code>assert_rows()</code>, to which you pass strings that contain SQL to be evaluated.
For example:</p>

<pre><code>CREATE OR REPLACE FUNCTION test.test_fooies() RETURNS VOID AS $_$
BEGIN
    PERFORM test.assert_rows(
        $$ VALUES(42, &#x0027;Fred&#x0027;), (99, &#x0027;Bob&#x0027;) $$,
        $$ SELECT * FROM fooies()          $$
    );
  RAISE EXCEPTION &#x0027;[OK]&#x0027;;
END;
$_$ LANGUAGE plpgsql;
</code></pre>

<p>This works reasonably well. Internally, Epic runs each query twice, using
<code>EXCEPT</code> to compare result sets, just as in my boolean example above. This
yields a proper comparison, and because <code>assert_rows()</code> iterates over returned
rows, it emits a useful message upon test failure:</p>

<pre><code>psql:try_epic.sql:21: ERROR:  Record: (99,Bob) from: VALUES(42, &#x0027;Fred&#x0027;), (99, &#x0027;Bob&#x0027;) not found in: SELECT * FROM fooies()
CONTEXT:  SQL statement &quot;SELECT  test.assert_rows( $$ VALUES(42, &#x0027;Fred&#x0027;), (99, &#x0027;Bob&#x0027;) $$, $$ SELECT * FROM fooies() $$ )&quot;
PL/pgSQL function &quot;test_fooies&quot; line 2 at PERFORM
</code></pre>

<p>A bit hard to read with all of the SQL exception information, but at least the
information is there. At <a href="https://www.pgcon.org/2009/" title="The PostgreSQL Conference 2009">PGCon</a>, Bob told me that passing strings of SQL
code made things a lot easier to implement in Epic, and I can certainly see
how that could be (pgTAP uses SQL code strings too, with its <code>throws_ok()</code>,
<code>lives_ok()</code>, and <code>performs_ok()</code> assertions). But it just doesn’t feel
SQLish to me. I mean, if you needed to write a really complicated query, it
might be harder to maintain: even using dollar quoting, it’s harder to track
stuff. Furthermore, it’s slow, as PL/pgSQL’s <code>EXECUTE</code> must be called twice
and thus plan twice. And don’t even try to test a query with
side-effects—such as a function that inserts a row and returns an ID—as the
second run will likely lead to test failure just might blow something up.</p>

<h3>SQL Blocks?</h3>

<p>One approach is to use blocks. I'm thinking here of something like Ruby blocks
or Perl code references: a way to dynamically create some code that is
compiled and planned when it loads, but its execution can be deferred. In Perl
it works like this:</p>

<pre><code>my $code = sub { say &quot;woof!&quot; };
$code-&gt;(); # prints &quot;woof!&quot;
</code></pre>

<p>In Ruby (and to a lesser extent in Perl), you can pass a block to a method:</p>

<pre><code>foo.bar { puts &quot;woof!&quot; }
</code></pre>

<p>The <code>bar</code> method can then run that code at its leisure. We can sort of do this
in PostgreSQL using <code>PREPARE</code>. To take advantage of it for Epic’s
<code>assert_rows()</code> function, one can do something like this:</p>

<pre><code>CREATE OR REPLACE FUNCTION test.test_fooies() RETURNS VOID AS $_$
BEGIN
    PREPARE want AS VALUES(42, &#x0027;Fred&#x0027;), (99, &#x0027;Bob&#x0027;);
    PREPARE have AS SELECT * FROM public.fooies();
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want $$),
        test.global($$ EXECUTE have $$)
    );
    RAISE EXCEPTION &#x0027;[OK]&#x0027;;
END;
$_$ LANGUAGE plpgsql;
</code></pre>

<p>The nice thing about using a prepared statement is that you can actually write
all of your SQL in SQL, rather than in an SQL string, and then pass the simple
<code>EXECUTE</code> statement to <code>assert_rows()</code>. Also note the calls to <code>test.global()</code>
in this example. This is a tricky function in Epic that takes an SQL
statement, turns its results into a temporary table, and then returns the
table name. This is required for the <code>EXECUTE</code> statements to work properly,
but a nice side-effect is that the actual queries are executed only once each,
to create the temporary tables. Thereafter, those temporary tables are used to
fetch results for the test.</p>

<p>Another benefit of prepared statements is that you can write a query once and
use it over and over again in your tests. Say that you had a few set returning
functions that return different results from the <code>users</code> table. You could then
test them all like so:</p>

<pre><code>CREATE OR REPLACE FUNCTION test.test_user_funcs() RETURNS VOID AS $_$
BEGIN
    PREPARE want(bool) AS SELECT * FROM users WHERE active = $1;
    PREPARE active     AS SELECT * FROM get_active_users();
    PREPARE inactive   AS SELECT * FROM get_inactive_users();
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want(true) $$),
        test.global($$ EXECUTE active     $$)
    );
    PERFORM test.assert_rows(
        test.global($$ EXECUTE want(false) $$),
        test.global($$ EXECUTE inactive    $$)
    );
    RAISE EXCEPTION &#x0027;[OK]&#x0027;;
END;
$_$ LANGUAGE plpgsql;
</code></pre>

<p>Note how I've tested both the <code>get_active_users()</code> and the
<code>get_inactive_users()</code> function by passing different values when executing the
<code>want</code> prepared statement. Not bad. I think that this is pretty SQLish, aside
from the necessity for <code>test.global()</code>.</p>

<p>Still, the use of prepared statements with Epic’s <code>assert_rows()</code> is not
without issues. There is still a lot of execution here (to create the
temporary tables and to select from them a number of times). Hell, this last
example reveals an inefficiency in the creation of the temporary tables, as
the two different executions of <code>have</code> create two separate temporary tables
for data that’s already in the <code>users</code> table. If you have a lot of rows to
compare, a lot more memory will be used. And you still can’t check the
ordering of your results, either.</p>

<p>So for small result sets and no need to check the ordering of results, this is
a pretty good approach. But there’s another.</p>

<h3>Result Set Handles</h3>

<p>Rather than passing blocks to be executed by the tests, in many dynamic
testing frameworks you can pass data structures be compared. For example,
<a href="http://search.cpan.org/perldoc?Test::More">Test::More</a>’s <code>is_deeply()</code> assertion allows you to test that two data
structures contain the same values in the same structures:</p>

<pre><code>is_deeply \@got_data, \@want_data, &#x0027;We should have the right stuff&#x0027;;
</code></pre>

<p>This does a deep comparison between the contents of the <code>@got_data</code> array and
<code>@want_data</code>. Similarly, I could imagine a test to check the contents of a
<a href="http://search.cpan.org/perldoc?DBIx::Class">DBIx::Class</a> result set object:</p>

<pre><code>results_are( $got_resultset, $want_resultset );
</code></pre>

<p>In this case, the <code>is_results()</code> function would iterate over the two result
sets, comparing each result to make sure that they were identical. So if
prepared statements in SQL are akin to blocks in dynamic languages, what is
akin to a result set?</p>

<p>The answer, if you're still with me, is <em>cursors</em>.</p>

<p>Now, cursors don’t work with Epic’s SQL-statement style tests, but I could
certainly see how a pgTAP function like this would be useful:</p>

<pre><code>DECLARE want CURSOR FOR SELECT * FROM users WHERE active;
DECLARE have CURSOR FOR SELECT * FROM get_active_users();
SELECT results_are( &#x0027;want&#x0027;, &#x0027;have&#x0027; );
</code></pre>

<p>The nice thing about this approach is that, even more than with prepared
statements, everything is written in SQL. The <code>results_are()</code> function would
simply iterate over each row returned from the two cursors to make sure that
they were the same. In the event that there was a difference, the diagnostic
output would be something like:</p>

<pre><code>#   Failed test 42:
#     Results begin differing at row 3:
#          have: (3,Larry,t)
#          want: (3,Larry,f)
</code></pre>

<p>So there’s a useful diagnostic, ordering is preserved, no temporary tables are
created, and the data is fetched directly from its sources (tables or
functions or whatever) just as it would be in a straight SQL statement. You
still have the overhead of PL/pgSQL’s <code>EXECUTE</code>, and iterating over the
results, but, outside of some sort of <code>NOT INTERSECT</code> operator, I don’t see
any other way around it.</p>

<h3>The Plan</h3>

<p>So I think I'll actually look at adding support for doing this in two ways:
one with prepared statements (or query strings, if that’s what floats your
boat) like Epic does, though I'm going to look at avoiding the necessity for
something like Epic’s <code>global()</code> function. But I'll also add functions to test
cursors. And maybe a few combinations of these things.</p>

<p>So, does an approach like this, especially the cursor solution, address Tom’s
criticism? Does it feel more relational? Just to rewrite the kind of test Tom
originally objected to, it would now look something like this:</p>

<pre><code>DECLARE have CURSOR FOR SELECT name FROM srt ORDER BY name;
DECLARE want CURSOR FOR VALUES (&#x0027;AAA&#x0027;), (&#x0027;aardvark&#x0027;), (&#x0027;aba&#x0027;), (&#x0027;ABC&#x0027;), (&#x0027;abc&#x0027;);
SELECT results_are(
    &#x0027;have&#x0027;, &#x0027;want&#x0027;,
    &#x0027;The words should be case-insensitively sorted&#x0027;
);
</code></pre>

<p>Thoughts? I'm not going to get to it this week, so feedback would be greatly
appreciated.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/comparing-relations.html">old layout</a>.</small></p>


