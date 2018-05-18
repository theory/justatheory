--- 
date: 2008-06-30T19:49:53Z
slug: citext-patch-submitted
title: CITEXT Patch Submitted to PostgreSQL Contrib
aliases: [/computers/databases/postgresql/citext-patch-submitted.html]
tags: [Postgres, text, case-insensitivity, Unicode, UTF-8, citext]
type: post
---

<p>On Friday, I <a href="http://archives.postgresql.org/message-id/4013F1AE-FE1B-427B-8C23-1A5681DA297E@kineticode.com" title="PATCH: CITEXT 2.0">submitted a patch</a> to add a locale-aware case-insensitive text type as a PostgreSQL contrib module. This has been among my top requests as a feature for PostgreSQL ever since I started using it. And as I started work on yet another application recently, I decided to look into what it would take to just make it happen myself. I'm hopeful that everyone will be able to benefit from this bit of <a href="http://en.wiktionary.org/wiki/yak_shaving" title="Wiktionary: “yak shaving”">yak shaving</a>.</p>

<p>I started out by trying to use the <a href="http://pgfoundry.org/projects/citext/" title="">citext project on pgFoundry</a>, but immediately identified two issues with it:</p>

<ol>
  <li>It does not install properly on PostgreSQL 8.3 (it uses a lot of casts that were removed in 8.3); and </li>
  <li>It only case-insensitively compared ASCII characters. So accented multibyte characters work just as they do in the text type.</li>
</ol>

<p>So I set about trying to create my own, new type, originally called “lctext”, since what it does is not true case-insensitive comparisons, but lowercases text and then compares, just as millions of us developers already do by using <code>LOWER()</code> on both sides of a query:</p>

<pre>
SELECT *
  FROM tab
 WHERE lower(col) = LOWER(?);
</pre>

<p>I just finally got fed up with this. The last straw for me was wanting to create a primary key that would be stored case-insensitively, which would have required that I create two indexes for it: One created for the primary key by default, the other a functional <code>UNIQUE INDEX</code> on <code>LOWER(col)</code>, which would just be stupid.</p>

<p>So <a href="http://archives.postgresql.org/message-id/4013F1AE-FE1B-427B-8C23-1A5681DA297E@kineticode.com" title="PATCH: CITEXT 2.0">this patch</a> is the culmination of my work to make a locale-aware case-insensitive text type. It's locale-aware in that it uses the same locale-aware string comparison code as that used for the text type, and it uses the same C function as <code>LOWER()</code> uses. The nice thing is that it works just as if you had used <code>LOWER()</code> in all your SQL, but now you don't have to.</p>

<p>So while this is not a <em>true</em> case-insensitive text type, in the sense that it doesn't do a case-insensitive comparison, but changes the cases and <em>then</em> compares, it is likely more efficient than the <code>LOWER()</code> workaround that we've all been using for years, and it neater, too. Using this type, it will now be much easier to create, e.g, an <a href="http://www.varlena.com/GeneralBits/128.php" title="PostgreSQL General Bits: “Base Type using Domains”">email domain</a>, like so:</p>

<pre>
CREATE OR REPLACE FUNCTION is_email(text)
RETURNS BOOLEAN
AS $$
    use Email::Valid;
    return TRUE if Email::Valid->address( $_[0] );
    return FALSE;
$$ LANGUAGE 'plperlu' STRICT IMMUTABLE;

CREATE DOMAIN email AS CITEXT CHECK ( is_email( value ) );
</pre>

<p>No more nasty workarounds to account for the lack of case-insensitive comparisons for text types. It works great for time zones and other data types that are defined to compare case-insensitively:</p>

<pre>
CREATE OR REPLACE FUNCTION is_timezone( tz TEXT ) RETURNS BOOLEAN as $$
BEGIN
  PERFORM now() AT TIME ZONE tz;
  RETURN TRUE;
EXCEPTION WHEN invalid_parameter_value THEN
  RETURN FALSE;
END;
$$ language plpgsql STABLE;

CREATE DOMAIN timezone AS CITEXT
CHECK ( is_timezone( value ) );
</pre>

<p>And that should just work!</p>

<p>I'm hoping that this is accepted during the <a href="http://wiki.postgresql.org/index.php?title=CommitFest:2008-07" title="PostgreSQL CommitFest:2008-07">July CommitFest</a>. Of course I will welcome suggestions for how to improve it. Since I sent the patch, for example, I've been thinking that I should suggest in the documentation that it is best used for short text entries (say, up to 256 characters), rather than longer entries (like email bodies or journal articles), and that for longer entries, one should really make use of <a href="http://www.postgresql.org/docs/current/static/textsearch.html" title="PostgreSQL Documentation: Chapter 12. Full Text Search">tsearch2</a>, instead. There are other notes and caveats in the <a href="http://archives.postgresql.org/message-id/4013F1AE-FE1B-427B-8C23-1A5681DA297E@kineticode.com" title="PATCH: CITEXT 2.0">patch submission</a>. Please do let me know what you think.</p>
