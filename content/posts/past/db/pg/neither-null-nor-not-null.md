--- 
date: 2009-07-28T19:16:54Z
slug: neither-null-nor-not-null
title: "Neither NULL nor NOT NULL: An SQL WTF"
aliases: [/computers/databases/postgresql/neither-null-nor-not-null.html]
tags: [Postgres, SQL]
---

<p>While working on <a href="/computers/databases/postgresql/results_eq.html"
title="Committed: pgTAP Result Set Assertion Functions">result set testing
functions</a>, I ran into a bit of weirdness when comparing rows between two
cursors. I had code that looked more or less like this:</p>

<pre><code>FETCH have INTO rec_have;
FETCH want INTO rec_want;
WHILE rec_have IS NOT NULL OR rec_want IS NOT NULL LOOP
    IF rec_have IS DISTINCT FROM rec_want THEN
        RETURN FALSE;
    END IF;
    FETCH have INTO rec_have;
    FETCH want INTO rec_want;
END LOOP;
RETURN TRUE;
</code></pre>

<p>Basically, the idea is to return true if the two cursors return equivalent
rows in the same order. However, things started to get weird when any of the
rows included a <code>NULL</code>: it seemed that the loop exited as soon as a <code>NULL</code> was
encountered, even if there were also non-<code>NULL</code> values in the row. I poked
around a bit and discovered, to my astonishment, that such a record is neither
<code>NULL</code> nor <code>NOT NULL</code>:</p>

<pre><code>try=# select ROW(1, NULL) IS NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)

try=# select ROW(1, NULL) IS NOT NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)
</code></pre>

<p>I had thought that a value, even a composite value, had to be either <code>NULL</code> or
<code>NOT NULL</code>, so I thought it was a bug. I mean, this isn't possible, is it? I
dutifully
<a href="http://archives.postgresql.org/pgsql-hackers/2009-07/msg01518.php">asked on the pgsql-hackers</a>
list and was informed, to further astonishment, that this is, in fact,
<a href="http://archives.postgresql.org/pgsql-hackers/2009-07/msg01525.php">mandated by the SQL standard</a>.
WTF? As <a href="http://archives.postgresql.org/pgsql-hackers/2009-07/msg01588.php">Jeff says</a>,
“The standard is what it is. If it says that some <code>NULL</code>s are red and some <code>NULL</code>s
are blue, then we'd probably support it.”</p>

<p>Through the discussion, I learned that a record is considered <code>NULL</code> only if
<em>all</em> of its values are <code>NULL</code>, and it's considered <code>NOT NULL</code> only if <em>none</em>
of it s values are <code>NULL</code>:</p>

<pre><code>try=# select ROW(NULL, NULL) IS NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)

try=# select ROW(1, 1) IS NOT NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
</code></pre>

<p>The upshot is that composite values with at least one <code>NULL</code> and at least
one <code>NOT NULL</code> value are ambiguous. It's insane, but there you have it.</p>

<p>Jeff thought that you could cheat the standard by moving the <code>NOT</code> in front
of the value before checking its <code>NULL</code>ness. I changed my code to reflect
this, and things got better:</p>

<pre><code>FETCH have INTO rec_have;
FETCH want INTO rec_want;
WHILE NOT rec_have IS NULL OR NOT rec_want IS NULL LOOP
    IF rec_have IS DISTINCT FROM rec_want THEN
        RETURN FALSE;
    END IF;
    FETCH have INTO rec_have;
    FETCH want INTO rec_want;
END LOOP;
RETURN TRUE;
</code></pre>

<p>Kind of confusing to read, but at least it's not too ugly. In truth, however, it's still
inconsistent: it just makes it so that such records are both <code>NULL</code> and <code>NOT NULL</code>:</p>

<pre><code>try=# select NOT ROW(1, NULL) IS NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)

try=# select NOT ROW(1, NULL) IS NOT NULL;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)
</code></pre>

<p>But it was good enough for me. For a while. But then I started testing the
pathological scenario where a row contains <em>only</em> <code>NULL</code>s. I call it
pathological because no one should ever have rows with only <code>NULL</code>s. But the
truth is that the SQL standard allows it (despite the objections of
relational theorists) and, I've little doubt, application developers get such
rows all the time.</p>

<p>The problem with such rows is that they are inherently <code>NULL</code>, but, according
to the documentation for the use of
<a href="http://www.postgresql.org/docs/8.4/static/plpgsql-cursors.html">cursors in PL/pgSQL</a>,
when fetching rows from a cursor, “if there is no next row, the target is set
to <code>NULL</code>(s).” The upshot is that, because I'm using a <code>WHILE</code> loop to fetch
rows from a cursor, and rows with only <code>NULL</code>s are themselves considered
<code>NULL</code>, there is no way to tell the difference between a row that contains
<code>NULL</code>s and the end of a cursor.</p>

<p>To demonstrate, I
<a href="http://archives.postgresql.org/pgsql-hackers/2009-07/msg01736.php">sent an example</a>
of two functions that process a cursor, one using a plain PL/pgSQL <code>FOR rec IN
stuff LOOP</code>, which internally detects the difference between rows full of
<code>NULL</code>s and the end of the cursor, and one using the <code>WHILE NOT rec IS NULL
LOOP</code> syntax required by the pgTAP testing functions. The output looked like
this:</p>

<pre><code>    dob     |     ssn
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;-
 1965-12-31 |
            |
            | 932-45-3456
 1963-03-23 | 123-45-6789
(4 rows)

    dob     | ssn
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;-
 1965-12-31 |
(1 row)
</code></pre>

<p>The two functions are processing the same query in cursors, but while the
<code>FOR</code> loop properly returned all four rows, the <code>WHILE</code> loop stopped when it
hit a row with only <code>NULL</code>s. I found this annoying, to say the least.
Fortunately, other folks were paying better attention to the docs, pointing
out that the special PL/pgSQL <code>FOUND</code> variable does just the trick, being set
to <code>TRUE</code> when a row is fetched, even if the row is all <code>NULL</code>s, and false
then there are no more rows in the cursor. In fact, had I read two more
sentences in the
<a href="http://www.postgresql.org/docs/8.3/static/plpgsql-cursors.html#AEN44324">relevant documentation</a>,
I would have noticed that it says, “As with <code>SELECT INTO</code>, the special
variable <code>FOUND</code> can be checked to see whether a row was obtained or not.”
D'oh!</p>

<p>So now my function looks more or less like this:</p>

<pre><code>FETCH have INTO rec_have;
have_found := FOUND;
FETCH want INTO rec_want;
want_found := FOUND;
WHILE have_found OR want_found LOOP
    IF rec_have IS DISTINCT FROM rec_want THEN
        RETURN FALSE;
    END IF;
    FETCH have INTO rec_have;
    have_found := FOUND;
    FETCH want INTO rec_want;
    want_found := FOUND;
END LOOP;
RETURN TRUE;
</code></pre>

<p>Yeah, pretty verbose and full of a lot of explicit processing that I can just
take for granted in more sane languages, but it does the trick. Don'tcha just
love SQL?</p>

<p>That issue behind me, I'll do a bit more hacking on it this week, and
hopefully I'll get a release of pgTAP out with the new result set testing
support before I leave for vacation early next week.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/neither-null-nor-not-null.html">old layout</a>.</small></p>


