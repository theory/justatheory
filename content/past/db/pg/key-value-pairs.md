--- 
date: 2010-08-09T13:00:00Z
slug: key-value-pairs
title: Managing Key/Value Pairs in PostgreSQL
aliases: [/computers/databases/postgresql/key-value-pairs.html]
tags: [Postgres, nosql, SQL]
type: post
---

<p>Let's say that you've been following the <a href="http://it.toolbox.com/blogs/database-soup/runningwithscissorsdb-39879" title="RunningWithScissorsDB">latest research</a> in key/value data storage and are interested in managing such data in a PostgreSQL database. You want to have functions to store and retrieve pairs, but there is no natural way to represent pairs in SQL. Many languages have hashes or or data dictionaries to fulfill this role, and you can pass them to functional interfaces. SQL's got nothin’. In PostgreSQL, have two options: use nested arrays (simple, fast) or use a custom composite data type (sugary, legible).</p>

<p>Let's assume you have this table for storing your pairs:</p>

<pre>
CREATE TEMPORARY TABLE kvstore (
    key        TEXT PRIMARY KEY,
    value      TEXT,
    expires_at TIMESTAMPTZ DEFAULT NOW() + &#x0027;12 hours&#x0027;::interval
);
</pre>

<p>To store pairs, you can use nested arrays like so:</p>

<pre>
SELECT store(ARRAY[ [&#x0027;foo&#x0027;, &#x0027;bar&#x0027;], [&#x0027;baz&#x0027;, &#x0027;yow&#x0027;] ]);
</pre>

<p>Not too bad, and since SQL arrays are a core feature of PostgreSQL, there's nothing special to do. Here's the <code>store()</code> function:</p>

<pre>
CREATE OR REPLACE FUNCTION store(
    params text[][]
) RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    FOR i IN 1 .. array_upper(params, 1) LOOP
        UPDATE kvstore
           SET value      = params[i][2],
               expires_at = NOW() + &#x0027;12 hours&#x0027;::interval
         WHERE key        = param[i][1];
        CONTINUE WHEN FOUND;
        INSERT INTO kvstore (key, value)
        VALUES (params[i][1], params[i][2]);
    END LOOP;
END;
$$;
</pre>

<p>I've seen worse. The trick is to iterate over each nested array, try an update for each, and insert when no row is updated. Alas, you have no control over how many elements a user might include in a nested array. One might call it as:</p>

<pre>
SELECT store(ARRAY[ [&#x0027;foo&#x0027;, &#x0027;bar&#x0027;, &#x0027;baz&#x0027;] ]);
</pre>

<p>Or:</p>

<pre>
SELECT store(ARRAY[ [&#x0027;foo&#x0027;] ]);
</pre>

<p>No errors will be thrown in either case. In the first the "baz" will be ignored, and in the second the value will default to <code>NULL</code>. If you really didn't like these behaviors, you could add some code to throw an exception if <code>array_upper(params, 2)</code> returns anything other than 2.</p>

<p>Let's look at fetching values for keys. PostgreSQL 8.4 added variadic function arguments, so it's easy to provide a nice interface for retrieving one or more values. The obvious one fetches a single value:</p>

<pre>
CREATE OR REPLACE FUNCTION getval(
    text
) RETURNS TEXT LANGUAGE SQL AS $$
    SELECT value FROM kvstore WHERE key = $1;
$$;
</pre>

<p>Nice and simple:</p>

<pre>
SELECT getval(&#x0027;baz&#x0027;);

 getval 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;'
 yow
</pre>

<p>The variadic version looks like this:</p>

<pre>
CREATE OR REPLACE FUNCTION getvals(
    variadic text[]
) RETURNS SETOF text LANGUAGE SQL AS $$
    SELECT value
      FROM kvstore
      JOIN (SELECT generate_subscripts($1, 1)) AS f(i)
        ON kvstore.key = $1[i]
     ORDER BY i;
$$;
</pre>

<p>Note the use of <code>ORDER BY i</code> to ensure that the values are returned in the same order as the keys are passed to the function. So if I've got the key/value pairs <code>'foo' =&gt; 'bar'</code> and <code>'baz' =&gt; 'yow'</code>, the output is:</p>

<pre>
SELECT * FROM getvals(&#x0027;foo&#x0027;, &#x0027;baz&#x0027;);

 getvals 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 bar
 yow
</pre>

<p>If we want to the rows to have the keys and values together, we can return them as arrays, like so:</p>

<pre>
CREATE OR REPLACE FUNCTION getpairs(
    variadic text[]
) RETURNS SETOF text[] LANGUAGE SQL AS $$
    SELECT ARRAY[key, value]
      FROM kvstore
      JOIN unnest($1) AS k ON kvstore.key = k
$$;
</pre>

<p>Here I'm assuming that order isn't important, which means we can use <a href="http://www.postgresql.org/docs/current/static/functions-array.html" title="PostgreSQL Documentation: Array Functions and Operators"><code>unnest</code></a> to "flatten" the array, instead of the slightly more baroque <a href="http://www.postgresql.org/docs/current/static/functions-srf.html#FUNCTIONS-SRF-SUBSCRIPTS" title="PostgreSQL Documentation: Set Returning Functions"><code>generate_subscripts()</code></a> with array access. The output:</p>

<pre>
SELECT * FROM getpairs(&#x0027;foo&#x0027;, &#x0027;baz&#x0027;);

  getpairs   
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 {baz,yow}
 {foo,bar}
</pre>

<p>Now, this is good as far as it goes, but the use of nested arrays to represent key/value pairs is not exactly ideal: just looking at the use of a function, there's nothing to indicate that you're using key/value pairs. What <em>would</em> be ideal is to use <a href="http://www.postgresql.org/docs/current/static/sql-expressions.html#SQL-SYNTAX-ROW-CONSTRUCTORS" title="PostgreSQL Documentation: Row Constructors">row constructors</a> to pass arbitrary pairs:</p>

<pre>
SELECT store( ROW(&#x0027;foo&#x0027;, &#x0027;bar&#x0027;), ROW(&#x0027;baz&#x0027;, 42) );
</pre>

<p>Alas, one cannot pass <code>RECORD</code> values (the data type returned by <code>ROW()</code>) to non-C functions in PostgreSQL.<sup id="fnr1-2010-08-09"><a href="#fn1-2010-08-09">1</a></sup> But if you don't mind your keys and values always being <code>TEXT</code>, we can get almost all the way there by creating an "ordered pair" data type as a <a href="http://www.postgresql.org/docs/current/static/sql-createtype.html" title="PostgreSQL Documentation: CREATE TYPE">composite type</a> like so:</p>

<pre>
CREATE TYPE pair AS ( k text, v text );
</pre>

<p>Then we can create <code>store()</code> with a signature of <code>VARIADIC pair[]</code> and pass in any number of these suckers:</p>

<pre>
CREATE OR REPLACE FUNCTION store(
    params variadic pair[]
) RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE
    param pair;
BEGIN
    FOR param IN SELECT * FROM unnest(params) LOOP
        UPDATE kvstore
           SET value = param.v,
               expires_at = NOW() + &#x0027;12 hours&#x0027;::interval
         WHERE key = param.k;
        CONTINUE WHEN FOUND;
        INSERT INTO kvstore (key, value) VALUES (param.k, param.v);
    END LOOP;
END;
$$;
</pre>

<p>Isn't it nice how we can access keys and values as <code>param.k</code> and <code>param.v</code>? Call the function like this:</p>

<pre>
SELECT store( ROW(&#x0027;foo&#x0027;, &#x0027;bar&#x0027;)::pair, ROW(&#x0027;baz&#x0027;, &#x0027;yow&#x0027;)::pair );
</pre>

<p>Of course, that can get a bit old, casting to <code>pair</code> all the time, so let's create some <code>pair</code> constructor functions to simplify things:</p>

<pre>
CREATE OR REPLACE FUNCTION pair(anyelement, text)
RETURNS pair LANGUAGE SQL AS &#x0027;SELECT ROW($1, $2)::pair&#x0027;;

CREATE OR REPLACE FUNCTION pair(text, anyelement)
RETURNS pair LANGUAGE SQL AS &#x0027;SELECT ROW($1, $2)::pair&#x0027;;

CREATE OR REPLACE FUNCTION pair(anyelement, anyelement)
RETURNS pair LANGUAGE SQL AS &#x0027;SELECT ROW($1, $2)::pair&#x0027;;

CREATE OR REPLACE FUNCTION pair(text, text)
RETURNS pair LANGUAGE SQL AS &#x0027;SELECT ROW($1, $2)::pair;&#x0027;;
</pre>

<p>I've created four variants here to allow for the most common combinations of types. So any of the following will work:</p>

<pre>
SELECT pair(&#x0027;foo&#x0027;, &#x0027;bar&#x0027;);
SELECT pair(&#x0027;foo&#x0027;, 1);
SELECT pair(12.3, &#x0027;foo&#x0027;);
SELECT pair(1, 43);
</pre>

<p>Alas, you can't mix any other types, so this will fail:</p>

<pre>
SELECT pair(1, 12.3);

ERROR:  function pair(integer, numeric) does not exist
LINE 1: SELECT pair(1, 12.3);
</pre>

<p>We could create a whole slew of additional constructors, but since we're using a key/value store, it's likely that the keys will usually be text anyway. So now we can call <code>store()</code> like so:</p>

<pre>
SELECT store( pair(&#x0027;foo&#x0027;, &#x0027;bar&#x0027;), pair(&#x0027;baz&#x0027;, &#x0027;yow&#x0027;) );
</pre>

<p>Better, eh? Hell, we can go all the way and create a nice binary operator to make it still more sugary. Just map each of the <code>pair</code> functions to the operator like so:</p>

<pre>
CREATE OPERATOR -&gt; (
    LEFTARG   = text,
    RIGHTARG  = anyelement,
    PROCEDURE = pair
);

CREATE OPERATOR -&gt; (
    LEFTARG   = anyelement,
    RIGHTARG  = text,
    PROCEDURE = pair
);

CREATE OPERATOR -&gt; (
    LEFTARG   = anyelement,
    RIGHTARG  = anyelement,
    PROCEDURE = pair
);

CREATE OPERATOR -&gt; (
    LEFTARG   = text,
    RIGHTARG  = text,
    PROCEDURE = pair
);
</pre>

<p>Looks like a lot of repetition, I know, but checkout the new syntax:</p>

<pre>
SELECT store( &#x0027;foo&#x0027; -&gt; &#x0027;bar&#x0027;, &#x0027;baz&#x0027; -&gt; 1 );
</pre>

<p>Cute, eh? I chose to use <code>-&gt;</code> because <code>=&gt;</code> is deprecated as an operator in PostgreSQL 9.0: SQL 2011 reserves that operator for named parameter assignment.<sup id="fnr2-2010-08-09"><a href="#fn1-2010-08-09">2</a></sup></p>

<p>As a last twist, let's rewrite <code>getpairs()</code> to return <code>pair</code>s instead of arrays:</p>

<pre>
CREATE OR REPLACE FUNCTION getpairs(
    variadic text[]
) RETURNS SETOF pair LANGUAGE SQL AS $$
    SELECT key -&gt; value
      FROM kvstore
      JOIN unnest($1) AS k ON kvstore.key = k
$$;
</pre>

<p>Cute, eh? Its use is just like before, only now the output is more table-like:</p>

<pre>
SELECT * FROM getpairs(&#x0027;foo&#x0027;, &#x0027;baz&#x0027;);

  k  |   v   
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 baz | yow
 foo | bar
</pre>

<p>You can also get them back as composites by omitting <code>* FROM</code>:</p>

<pre>
SELECT getpairs(&#x0027;foo&#x0027;, &#x0027;baz&#x0027;);

  getpairs   
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 (foo,bar)
 (baz,yow)
</pre>

<p>Anyway, just something to consider the next time you need a function that allows any number of key/value pairs to be passed. It's not perfect, but it's pretty sweet.</p>

<div class="footnotes">
  <hr />
  <ol>
  <li id="fn1-2010-08-09">
    <p>In the <a href="http://archives.postgresql.org/pgsql-hackers/2010-08/msg00520.php">recent pgsql-hackers discussion</a> that inspired this post, Pavel Stehule suggested adding something like <a href="http://download.oracle.com/docs/cd/B19306_01/appdev.102/b14261/collections.htm">Oracle <code>COLLECTION</code>s</a> to address this shortcoming. I don't know how far this idea will get, but it sure would be nice to be able to pass objects with varying kinds of data, rather than be limited to data all of one type (values in an SQL array must all be of the same type). <a href="#fnr1-2010-08-09"  class="footnoteBackLink"  title="Jump back to footnote 1 in the text.">&#8617;</a></p>
  </li>
  <li id="fn2-2010-08-09">
     <p>No, you won't be able to use named parameters for this application because named parameters are inherently non-variadic. That is, you can only pre-declare so many named parameters: you can't anticipate every parameter that's likely to be wanted as a key in our key/value store. <a href="#fnr2-2010-08-09"  class="footnoteBackLink"  title="Jump back to footnote 2 in the text.">&#8617;</a></p>
  </li>
  </ol>
  </div>
  

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/key-value-pairs.html">old layout</a>.</small></p>


