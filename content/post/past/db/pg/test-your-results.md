--- 
date: 2009-07-31T00:47:10Z
slug: test-your-results
title: "pgTAP 0.22: Test Your Results"
aliases: [/computers/databases/postgresql/test-your-results.html]
tags: [Postgres, pgTAP, testing, unit testing]
type: post
---

<p>I'm pleased to announce that,
<a href="/computers/databases/postgresql/comparing-relations.html" title="Thoughts on Testing SQL Result Sets">after</a>
<a href="/computers/databases/postgresql/result-testing-function-names.html" title="Need Help Naming Result Set Testing Functions">much</a>
<a href="/computers/databases/postgresql/set_testing_update.html" title="pgTAP Set-Testing Update">thinking</a>,
<a href="/computers/databases/postgresql/results_eq.html" title="Committed: pgTAP Result Set Assertion Functions">committing</a>,
and not an insignificant amount of
<a href="/computers/databases/postgresql/neither-null-nor-not-null.html" title="Neither NULL nor NOT NULL: An SQL
WTF">hair-pulling</a>,
<a href="http://pgtap.projects.postgresql.org/" title="pgTAP: Unit Testing for PostgreSQL">pgTAP</a> 0.22 has finally landed. Download it
<a href="http://pgfoundry.org/frs/?group_id=1000389" title="Download pgTAP">here</a>. Many, <em>many</em> thanks to all who commented on my
previous posts, made suggestions, and helped me on IRC to figure out how to
get all this stuff to work. The crazy thing is that it does, quite well, all
the way back to PostgreSQL 8.0.</p>

<p>So here's what I've come up with: ten simple functions. Sound like a lot?
Well, it's simpler than it might at first appear. Here's a quick overview:</p>

<dl>
  <dt><code>results_eq()</code></dt>
  <dd>
    <p>Compares two queries row-for-row. Pass in strings with SQL queries,
    strings with prepared statement names, or cursors. If the query you're
    testing returns a single column, the expected results can be passed as an
    array. If a test fails, you get useful diagnostics:</p>

    <pre>
# Failed test 146
#     Results differ beginning at row 3:
#         have: (1,Anna)
#         want: (22,Betty)
    </pre>

    <p>If a row is missing, the diagnostics will show it as
    a <code>NULL</code>:</p>

    <pre>
# Failed test 147
#     Results differ beginning at row 5:
#         have: (1,Anna)
#         want: NULL
    </pre>

  </dd>

  <dt><code>results_ne()</code></dt>
  <dd>
    <p>Just like <code>results_eq()</code>, except that it tests that the
    results of the two arguments are *not* equivalent. May not be very useful,
    but it's cute.</p>
  </dd>

  <dt><code>set_eq()</code></dt>
  <dd>
    <p>Tests that two queries return the same results, without regard to the
    order of the results or duplicates. Pass in strings with SQL queries or
    strings with prepared statement names. As with <code>results_eq()</code>
    the expected results can be passed as an array if the test query returns a
    single column. Failure diagnostics look like this:</p>

    <pre>
# Failed test 146
#     Extra records:
#         (87,Jackson)
#         (1,Jacob)
#     Missing records:
#         (44,Anna)
#         (86,Angelina)
    </pre>

    <p>If the failure is due to incompatible column types, the diagnostics
    will help you out there, too:</p>

    <pre>
# Failed test 147
#     Columns differ between queries:
#         have: (integer,text)
#         want: (text,integer)
    </pre>

  </dd>

  <dt><code>set_ne()</code></dt>
  <dd>
    <p>The inverse of <code>set_eq()</code>, the test passes if the results of
    the two queries are different, without regard to order or duplicate rows.
    No diagnostics on failure, though; if it fails, it's because the results
    are the same.</p>
  </dd>

  <dt><code>set_has()</code></dt>
  <dd>
    <p>Tests that a query contains a subset of results without regard to order
    or duplicates. Useful if you need to ensure that a query returns at least some
    set of rows. Failure diagnostics are useful again:</p>

    <pre>
# Failed test 122
#     Missing records:
#         (44,Anna)
#         (86,Angelina)
    </pre>
  </dd>

  <dt><code>set_hasnt()</code></dt>
  <dd>
    <p>Tests that a query does not contain a subset of results, without regard to order
      or duplicates.</p>
  </dd>

  <dt><code>bag_eq()</code></dt>
  <dd>
    <p>Just like <code>set_eq()</code>, except that duplicates matter. So if
    the first query has duplicate rows, the second must have the same
    dupes. Diagnostics are equally useful.</p>
  </dd>

  <dt><code>bag_ne()</code></dt>
  <dd>
    <p>Just like <code>set_ne()</code>, except that duplicates matter.</p>
  </dd>

  <dt><code>bag_has()</code></dt>
  <dd>
    <p>Just like <code>set_has()</code>, except that duplicates matter.</p>
  </dd>

  <dt><code>bag_hasnt()</code></dt>
  <dd>
    <p>Just like <code>set_hasnt()</code>, except that duplicates matter.</p>
  </dd>
</dl>

<p>Be sure to look at my
<a href="/computers/databases/postgresql/results_eq.html" title="Committed:
pgTAP Result Set Assertion Functions">previous post</a> for usage examples.
Since I wrote it, I've also added the ability to pass an array as the second
argument to these functions. This is specifically for the case when the query
you're testing results a single column of results; the array just makes it
easier to specify expected values in a common case:</p>

<pre>
SELECT results_eq(
    &#x0027;SELECT * FROM active_user_ids()&#x0027;,
    ARRAY[ 2, 3, 4, 5]
);
</pre>

<p>Check the
<a href="http://pgtap.projects.postgresql.org/documentation.html#Pursuing+Your+Query"
title="pgTAP Documentation: Pursing Your Query">documentation</a> for all the
details on how to use these functions.</p>

<p>I'm really happy with these functions. It was definitely worth it to really
<a href="/computers/databases/postgresql/set_testing_update.html" title="pgTAP
Set-Testing Update">think things through</a>, look at
<a href="/computers/databases/postgresql/comparing-relations.html"
title="Thoughts on Testing SQL Result Sets">prior art</a>, and spend the time
to try different approaches. In the process, I've found an approach that works
in nearly all circumstances.</p>

<p>The one exception is in <code>results_eq()</code>
and <code>results_ne()</code> on PostgreSQL 8.3 and down. The issue there
is that there were no operators to compare two <code>record</code>
objects before PostgreSQL 8.4. So for earlier versions, the code has to
cast the <code>record</code>s representing each row to text. This means
that two rows can be different but appear to be the same to 8.3 and
down. In practice this should be pretty rare, but I'm glad that record
comparisons are more correct in 8.4</p>

<p>The only other issue is performance. Although you can write your tests in
SQL, rather than strings containing SQL, the set and bag functions use the
PL/pgSQL <code>EXECUTE</code> statement to execute each SQL statement and
insert it into a temporary table. Then they select the data from the temporary
tables once or twice to do the comparisons. That's a lot more processing than
simply running the query itself, and it slows down the performance
significantly.</p>

<p>Similarly, the results functions use cursors and fetch each row one-at-a-time.
The nice thing is that, in the event of a failure for <code>results_eq()</code>
or a pass for <code>results_ne()</code>, the functions can stop fetching
results before reaching the end of the queries. But either way, a fair bit of
processing goes on.</p>

<p>I'm not sure which is slower, the set and bag functions or the results
functions, but, short of adding new syntax to SQL (not an option), I could see
no other way to adequately do the comparisons and emit useful diagnostics.</p>

<p>But those are minor caveats, I think. I'm pretty pleased with the function
names and the interfaces I've created for them. Please
<a href="http://pgfoundry.org/frs/?group_id=1000389" title="Download
pgTAP">download</a> the latest and let me know what you think.</p>

<p>So what's next? Well, there are a few more schema-testing functions I'd
like to add, but after that, I'd like to declare pgTAP stable and start using
it in new projects. I'm thinking about writing a test suite for
<a href="http://it.toolbox.com/blogs/database-soup/testing-for-normalization-33119" title="Database Soup: “Testing for Normalization”">database normalization</a>,
starting with testing that all tables
<a href="http://petereisentraut.blogspot.com/2009/07/how-to-find-all-tables-without-primary.html" title="Peter Eisentraut's Brain Dump: “How to find all tables without primary
key”">have primary keys</a>.</p>

<p>But that's after my vacation. Back in two weeks.</p>
