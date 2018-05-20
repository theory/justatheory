--- 
date: 2009-07-28T19:16:54Z
slug: neither-null-nor-not-null
title: "Neither NULL nor NOT NULL: An SQL WTF"
aliases: [/computers/databases/postgresql/neither-null-nor-not-null.html]
tags: [Postgres, SQL]
type: post
---

While working on [result set testing functions], I ran into a bit of weirdness
when comparing rows between two cursors. I had code that looked more or less
like this:

    FETCH have INTO rec_have;
    FETCH want INTO rec_want;
    WHILE rec_have IS NOT NULL OR rec_want IS NOT NULL LOOP
        IF rec_have IS DISTINCT FROM rec_want THEN
            RETURN FALSE;
        END IF;
        FETCH have INTO rec_have;
        FETCH want INTO rec_want;
    END LOOP;
    RETURN TRUE;

Basically, the idea is to return true if the two cursors return equivalent rows
in the same order. However, things started to get weird when any of the rows
included a `NULL`: it seemed that the loop exited as soon as a `NULL` was
encountered, even if there were also non-`NULL` values in the row. I poked
around a bit and discovered, to my astonishment, that such a record is neither
`NULL` nor `NOT NULL`:

    try=# select ROW(1, NULL) IS NULL;
     ?column? 
    ----------
     f
    (1 row)

    try=# select ROW(1, NULL) IS NOT NULL;
     ?column? 
    ----------
     f
    (1 row)

I had thought that a value, even a composite value, had to be either `NULL` or
`NOT NULL`, so I thought it was a bug. I mean, this isn't possible, is it? I
dutifully [asked on the pgsql-hackers] list and was informed, to further
astonishment, that this is, in fact, [mandated by the SQL standard]. WTF? As
[Jeff says], “The standard is what it is. If it says that some `NULL`s are red
and some `NULL`s are blue, then we'd probably support it.”

Through the discussion, I learned that a record is considered `NULL` only if
*all* of its values are `NULL`, and it's considered `NOT NULL` only if *none* of
it s values are `NULL`:

    try=# select ROW(NULL, NULL) IS NULL;
     ?column? 
    ----------
     t
    (1 row)

    try=# select ROW(1, 1) IS NOT NULL;
     ?column? 
    ----------
     t

The upshot is that composite values with at least one `NULL` and at least one
`NOT NULL` value are ambiguous. It's insane, but there you have it.

Jeff thought that you could cheat the standard by moving the `NOT` in front of
the value before checking its `NULL`ness. I changed my code to reflect this, and
things got better:

    FETCH have INTO rec_have;
    FETCH want INTO rec_want;
    WHILE NOT rec_have IS NULL OR NOT rec_want IS NULL LOOP
        IF rec_have IS DISTINCT FROM rec_want THEN
            RETURN FALSE;
        END IF;
        FETCH have INTO rec_have;
        FETCH want INTO rec_want;
    END LOOP;
    RETURN TRUE;

Kind of confusing to read, but at least it's not too ugly. In truth, however,
it's still inconsistent: it just makes it so that such records are both `NULL`
and `NOT NULL`:

    try=# select NOT ROW(1, NULL) IS NULL;
     ?column? 
    ----------
     t
    (1 row)

    try=# select NOT ROW(1, NULL) IS NOT NULL;
     ?column? 
    ----------
     t
    (1 row)

But it was good enough for me. For a while. But then I started testing the
pathological scenario where a row contains *only* `NULL`s. I call it
pathological because no one should ever have rows with only `NULL`s. But the
truth is that the SQL standard allows it (despite the objections of relational
theorists) and, I've little doubt, application developers get such rows all the
time.

The problem with such rows is that they are inherently `NULL`, but, according to
the documentation for the use of [cursors in PL/pgSQL], when fetching rows from
a cursor, “if there is no next row, the target is set to `NULL`(s).” The upshot
is that, because I'm using a `WHILE` loop to fetch rows from a cursor, and rows
with only `NULL`s are themselves considered `NULL`, there is no way to tell the
difference between a row that contains `NULL`s and the end of a cursor.

To demonstrate, I [sent an example] of two functions that process a cursor, one
using a plain PL/pgSQL `FOR rec IN stuff LOOP`, which internally detects the
difference between rows full of `NULL`s and the end of the cursor, and one using
the `WHILE NOT rec IS NULL LOOP` syntax required by the pgTAP testing functions.
The output looked like this:

        dob     |     ssn
    ------------+-------------
     1965-12-31 |
                |
                | 932-45-3456
     1963-03-23 | 123-45-6789
    (4 rows)

        dob     | ssn
    ------------+-----
     1965-12-31 |
    (1 row)

The two functions are processing the same query in cursors, but while the `FOR`
loop properly returned all four rows, the `WHILE` loop stopped when it hit a row
with only `NULL`s. I found this annoying, to say the least. Fortunately, other
folks were paying better attention to the docs, pointing out that the special
PL/pgSQL `FOUND` variable does just the trick, being set to `TRUE` when a row is
fetched, even if the row is all `NULL`s, and false then there are no more rows
in the cursor. In fact, had I read two more sentences in the [relevant
documentation], I would have noticed that it says, “As with `SELECT INTO`, the
special variable `FOUND` can be checked to see whether a row was obtained or
not.” D'oh!

So now my function looks more or less like this:

    FETCH have INTO rec_have;
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

Yeah, pretty verbose and full of a lot of explicit processing that I can just
take for granted in more sane languages, but it does the trick. Don'tcha just
love SQL?

That issue behind me, I'll do a bit more hacking on it this week, and hopefully
I'll get a release of pgTAP out with the new result set testing support before I
leave for vacation early next week.

  [result set testing functions]: /computers/databases/postgresql/results_eq.html
    "Committed: pgTAP Result Set Assertion Functions"
  [asked on the pgsql-hackers]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg01518.php
  [mandated by the SQL standard]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg01525.php
  [Jeff says]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg01588.php
  [cursors in PL/pgSQL]: http://www.postgresql.org/docs/8.4/static/plpgsql-cursors.html
  [sent an example]: http://archives.postgresql.org/pgsql-hackers/2009-07/msg01736.php
  [relevant documentation]: http://www.postgresql.org/docs/8.3/static/plpgsql-cursors.html#AEN44324
