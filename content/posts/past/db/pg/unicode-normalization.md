--- 
date: 2009-09-23T22:10:22Z
slug: unicode-normalization
title: Unicode Normalization in SQL
aliases: [/computers/databases/postgresql/unicode-normalization.html]
tags: [Postgres, SQL, Unicode, database normalization, NFC, NFD, NFKC, NFKD]
---

<p>I've been peripherally aware of the need for unicode normalization in my
code for a while, but only got around to looking into it today. Although I
use <a href="http://search.cpan.org/perldoc?Encode" title="Encode on
CPAN">Encode</a> to convert text inputs into Perl's internal form and UTF-8 or
an appropriate encoding in all my outputs, it does nothing about
normalization.</p>

<p>What's normalization you ask?</p>

<p>Well, UTF-8 allows some characters to be encoded in different ways. For
example, é can be written as either “&amp;#x00e9;”, which is a “precomposed
character,” or as “&amp;#x0065;&amp;#x0301;”, which is a combination of
“&#x0065;” and “&#x0301;”. This is all well and good, but the trouble comes
when you want to compare values. Observe this Perl one-liner:</p>

<pre>
% perl -le &#x0027;print &quot;\x{00e9}&quot; eq &quot;\x{0065}\x{0301}&quot; ? &quot;t&quot; : &quot;f&quot;&#x0027;
f
</pre>

<p>The same issue exists in your database. Here's an example from
PostgreSQL:</p>

<pre>
try=# select U&amp;&#x0027;\00E9&#x0027; = U&amp;&#x0027;\0065\0301&#x0027;;
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)
</pre>

<p>If you have a user enter data in your Web app using combining characters,
and then another does a search with canonical characters, the search will
fail. This won't do at all.</p>

<p>The solution is to
<a href="http://en.wikipedia.org/wiki/Unicode_normalization" title="Wikipedia:
“Unicode equivalence”">normalize</a> your Unicode data. In Perl, you can use
<a href="http://search.cpan.org/perldoc?Unicode::Normalize"
title="Unicode::Normalize on CPAN">Unicode::Normalize</a>, a C/XS module that
uses Perl's internal unicode tables to convert things as appropriate. For
general use the NFC normalization
is <a href="http://unicode.org/faq/normalization.html#2" title="Unicode
Normalization FAQ: “Which forms of normalization should I support?”">probably
best</a>:</p>

<pre>
use Unicode::Normalize;
$string = NFC $string;
</pre>

<p>PostgreSQL offers no normalization routines. However, the SQL standard
mandates one (as of SQL 2008, at least). It looks like this:</p>

<pre>
&lt;normalize function&gt; ::= NORMALIZE &lt;left paren&gt; &lt;character value expression&gt; [ &lt;comma&gt; &lt;normal form&gt; [ &lt;comma&gt; &lt;normalize function result length&gt; ] ] &lt;right paren&gt;
&lt;normal form&gt; ::= NFC | NFD | NFKC | NFKD
</pre>

<p>The second argument defaults to <code>NFC</code> and the third, which
specifies a maximum length of the return value, is optional. The fact that it
looks like a function means that we can use PL/PerlU to emulate it in
PostgreSQL until a proper implementation makes it into core. Here's how:</p>

<pre>
CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT,
    form   TEXT,
    maxlen INT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize &#x0027;normalize&#x0027;;
    my ($string, $form, $maxlen) = @_;
    my $ret = normalize($form, $string);
    elog(ERROR, &#x0027;Normalized value is too long&#x0027;) if length $ret > $maxlen;
    return $ret;
$$;

CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT,
    form   TEXT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize &#x0027;normalize&#x0027;;
    return normalize($_[1], $_[0]);
$$;

CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize &#x0027;normalize&#x0027;;
    return normalize(&#x0027;NFC&#x0027;, shift);
$$;
</pre>

<p>I wrote a few tests to make sure it was sane:</p>

<pre>
SELECT U&amp;&#x0027;\0065\0301&#x0027; as combined,
       char_length(U&amp;&#x0027;\0065\0301&#x0027;),
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;) as normalized,
       char_length(NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;));

SELECT NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFC&#x0027;)  AS NFC,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFD&#x0027;)  AS NFD,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFKC&#x0027;) AS NFKC,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFKD&#x0027;) AS NFKD
;

SELECT NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFC&#x0027;, 1)  AS NFC,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFD&#x0027;, 2)  AS NFD,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFKC&#x0027;, 1) AS NFKC,
       NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFKD&#x0027;, 2) AS NFKD;

SELECT NORMALIZE(U&amp;&#x0027;\0065\0301&#x0027;, &#x0027;NFD&#x0027;, 1);
</pre>

<p>And the output</p>

<pre>
 combined | char_length | normalized | char_length 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;-+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;-
 é        |           2 | é          |           1
(1 row)

 nfc | nfd | nfkc | nfkd 
&#x002d;&#x002d;&#x002d;&#x002d;-+&#x002d;&#x002d;&#x002d;&#x002d;-+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 é   | é   | é    | é
(1 row)

 nfc | nfd | nfkc | nfkd 
&#x002d;&#x002d;&#x002d;&#x002d;-+&#x002d;&#x002d;&#x002d;&#x002d;-+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 é   | é   | é    | é
(1 row)

psql:try.sql:45: ERROR:  error from Perl function &quot;normalize&quot;: Normalized value is too long at line 5.
</pre>

<p>Cool! So that's fairly close to the standard. The main difference is that
the <code>form</code> argument must be a string instead of a constant literal. But
PostgreSQL would likely support both. The length argument is also a literal,
and can be <code>10 characters</code> or <code>64 bytes</code>, but for our
purposes, this is fine. The only downside to it is that it's slow: PostgreSQL
must convert its text value to a Perl string to pass to the function, and then
Unicode::Normalize turns it into a C string again to do the conversion, then
back to a Perl string which, in turn, is returned to PostgreSQL and converted
back into the text form. Not the quickest process, but may prove useful
anyway.</p>

<h3>Update: 1 Hour Later</h3>

<p>Note that this issue applies when
using <a href="http://www.postgresql.org/docs/current/static/textsearch.html" title="PostgreSQL Documentation: Full Text Search">full text search</a>, too.
Alas, it does not normalize unicode characters for you:</p>

<pre>
try=# select to_tsvector(U&amp;&#x0027;\00E9clair&#x0027;) @@ to_tsquery(U&amp;&#x0027;\0065\0301clair&#x0027;);
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)
</pre>

<p>But normalizing with the functions I introduced does work:</p>

<pre>
try=# select to_tsvector(U&amp;&#x0027;\00E9clair&#x0027;) @@ to_tsquery(normalize(U&amp;&#x0027;\0065\0301clair&#x0027;));
 ?column? 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)
</pre>

<p>So yes, this really can be an issue in your applications.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/unicode-normalization.html">old layout</a>.</small></p>


