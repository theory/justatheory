--- 
date: 2004-08-23T23:16:25Z
slug: always-use-c-locale
title: Always use the C Locale with PostgreSQL
aliases: [/computers/databases/postgresql/always_use_c_locale.html]
tags: [Postgres, character sets, locales, Unicode, UTF-8, Bricolage]
type: post
---

I ran into the weirdest bug with Bricolage today. We use the `LIKE` operator to
do string comparisons throughout Bricolage. In one usage, the code checks to see
if there's a record in the “keyword” table before creating it. This is because
keyword names are unique. So it looks for a keyword record like this:

    SELECT name, screen_name, sort_name, active
    FROM   keyword
    WHERE  LOWER(name) LIKE ?

If it finds a keyword, it creates a relationship between it and a story
document. If it doesn't find it, it creates a new keyword record and then
associates the new keyword with a story document.

However, one of our customers was getting SQL errors when attempting to add
keywords to a story, and it took me a while to figure out what the problem was.
This is because I couldn't replicate the problem until I started trying to
create multibyte keywords. Now, Bricolage uses a UTF-8 PostgreSQL database, but
something very odd was going on. When I attempted to add the keyword “북한의”,
it didn't find an existing keyword, but then threw an error when the unique
index thought it existed already! Running tests in `psql`, I found that `=`
would find the existing record, but `LIKE` wouldn't!

Once I posted [a query] on the pgsql-general list, someone noticed that the
record returned when using `=` actually had a *different* value than was
actually queried for. I had searched for “북한의”, but the database found
“국방비”. It seems that `=` compares bytes, while `LIKE` compares characters.
The error I was getting meant that the unique index was also using bytes. And
because of the locale used when `initdb` was run, PostgreSQL thought that they
actually *were* the same!

The solution to this problem, it turns out, was to dump the database, shut down
PostgreSQL, move the old data directory, and create a new one with
`initdb -locale=C`. I then restored the database, and suddenly `=` and `LIKE`
(and the unique index) were doing the same thing. Hallelujah!

Naturally, I'm [not the first] to notice this issue. It's particularly an issue
with RedHat Linux installations, since RedHat has lately decided to set a
system-wide locale. In my case, it was “en\_US.UTF-8.” This apparently can break
collations in other languages, and this affects indices, of course. So I was led
to [wonder] if `initdb` shouldn't default to a locale of `C` instead of the
system default. What do you think?

You can read the whole thread [here].

  [a query]: http://archives.postgresql.org/pgsql-general/2004-08/msg01079.php
    "I ask about the issue"
  [not the first]: http://archives.postgresql.org/pgsql-general/2004-08/msg01118.php
    "Tatsuo Ishii sets the record straight"
  [wonder]: http://archives.postgresql.org/pgsql-general/2004-08/msg01120.php
    "I pop the locale question"
  [here]: http://archives.postgresql.org/pgsql-general/2004-08/threads.php#01079
    "The full discussion"
