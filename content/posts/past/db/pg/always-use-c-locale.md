--- 
date: 2004-08-23T23:16:25Z
slug: always-use-c-locale
title: Always use the C Locale with PostgreSQL
aliases: [/computers/databases/postgresql/always_use_c_locale.html]
tags: [Postgres, character sets, locales, Unicode, UTF-8, Bricolage]
---

<p>I ran into the weirdest bug with Bricolage today. We use the <code>LIKE</code>
operator to do string comparisons throughout Bricolage. In one usage, the
code checks to see if there's a record in the <q>keyword</q> table before
creating it. This is because keyword names are unique. So it looks for a keyword
record like this:</p>

<pre>SELECT name, screen_name, sort_name, active
FROM   keyword
WHERE  LOWER(name) LIKE ?</pre>

<p>If it finds a keyword, it creates a relationship between it and a story
document. If it doesn't find it, it creates a new keyword record and then
associates the new keyword with a story document.</p>

<p>However, one of our customers was getting SQL errors when attempting to add
keywords to a story, and it took me a while to figure out what the problem
was. This is because I couldn't replicate the problem until I started trying
to create multibyte keywords. Now, Bricolage uses a UTF-8 PostgreSQL database,
but something very odd was going on. When I attempted to add the
keyword <q>북한의</q>, it didn't find an existing keyword, but then threw an
error when the unique index thought it existed already! Running tests
in <code>psql</code>, I found that <code>=</code> would find the existing
record, but <code>LIKE</code> wouldn't!</p>

<p>Once I posted <a href="http://archives.postgresql.org/pgsql-general/2004-08/msg01079.php" title="I ask about the issue">a query</a> on the pgsql-general list, someone noticed that the record returned
when using <code>=</code> actually had a <em>different</em> value than was actually
queried for. I had searched for <q>북한의</q>, but the database found <q>국방비</q>. It seems that <code>=</code> compares bytes, while <code>LIKE</code> compares
characters. The error I was getting meant that the unique index was also using bytes. And
because of the locale used when <code>initdb</code> was run, PostgreSQL thought that they
actually <em>were</em> the same!</p>

<p>The solution to this problem, it turns out, was to dump the database, shut down
PostgreSQL, move the old data directory, and create a new one with <code>initdb &#x002d;locale=C</code>.
I then restored the database, and suddenly <code>=</code> and <code>LIKE</code> (and the unique
index) were doing the same thing. Hallelujah!</p>

<p>Naturally, I'm <a href="http://archives.postgresql.org/pgsql-general/2004-08/msg01118.php" title="Tatsuo Ishii sets the record straight">not the first</a> to notice this issue. It's particularly an issue with RedHat Linux
installations, since RedHat has lately decided to set a system-wide locale. In my case, it was <q>en_US.UTF-8.</q> This apparently can break collations in other languages, and this affects indices, of course. So I
was led to <a href="http://archives.postgresql.org/pgsql-general/2004-08/msg01120.php" title="I pop the locale question">wonder</a> if <code>initdb</code> shouldn't default to a locale of <code>C</code> instead of
the system default. What do you think?</p>

<p>You can read the whole thread <a href="http://archives.postgresql.org/pgsql-general/2004-08/threads.php#01079"
title="The full discussion">here</a>.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/always_use_c_locale.html">old layout</a>.</small></p>


