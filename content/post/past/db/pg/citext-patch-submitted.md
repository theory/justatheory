--- 
date: 2008-06-30T19:49:53Z
slug: citext-patch-submitted
title: CITEXT Patch Submitted to PostgreSQL Contrib
aliases: [/computers/databases/postgresql/citext-patch-submitted.html]
tags: [Postgres, Text, Case-Insensitivity, Unicode, UTF-8, citext]
type: post
---

On Friday, I [submitted a patch] to add a locale-aware case-insensitive text
type as a PostgreSQL contrib module. This has been among my top requests as a
feature for PostgreSQL ever since I started using it. And as I started work on
yet another application recently, I decided to look into what it would take to
just make it happen myself. I'm hopeful that everyone will be able to benefit
from this bit of [yak shaving].

I started out by trying to use the [citext project on pgFoundry], but
immediately identified two issues with it:

1.  It does not install properly on PostgreSQL 8.3 (it uses a lot of casts that
    were removed in 8.3); and
2.  It only case-insensitively compared ASCII characters. So accented multibyte
    characters work just as they do in the text type.

So I set about trying to create my own, new type, originally called “lctext”,
since what it does is not true case-insensitive comparisons, but lowercases text
and then compares, just as millions of us developers already do by using
`LOWER()` on both sides of a query:

``` postgres
SELECT *
  FROM tab
 WHERE lower(col) = LOWER(?);
```

I just finally got fed up with this. The last straw for me was wanting to create
a primary key that would be stored case-insensitively, which would have required
that I create two indexes for it: One created for the primary key by default,
the other a functional `UNIQUE INDEX` on `LOWER(col)`, which would just be
stupid.

So [this patch][submitted a patch] is the culmination of my work to make a
locale-aware case-insensitive text type. It's locale-aware in that it uses the
same locale-aware string comparison code as that used for the text type, and it
uses the same C function as `LOWER()` uses. The nice thing is that it works just
as if you had used `LOWER()` in all your SQL, but now you don't have to.

So while this is not a *true* case-insensitive text type, in the sense that it
doesn't do a case-insensitive comparison, but changes the cases and *then*
compares, it is likely more efficient than the `LOWER()` workaround that we've
all been using for years, and it neater, too. Using this type, it will now be
much easier to create, e.g, an [email domain], like so:

``` postgres
CREATE OR REPLACE FUNCTION is_email(text)
RETURNS BOOLEAN
AS $$
    use Email::Valid;
    return TRUE if Email::Valid->address( $_[0] );
    return FALSE;
$$ LANGUAGE 'plperlu' STRICT IMMUTABLE;

CREATE DOMAIN email AS CITEXT CHECK ( is_email( value ) );
```

No more nasty workarounds to account for the lack of case-insensitive
comparisons for text types. It works great for time zones and other data types
that are defined to compare case-insensitively:

``` postgres
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
```

And that should just work!

I'm hoping that this is accepted during the [July CommitFest]. Of course I will
welcome suggestions for how to improve it. Since I sent the patch, for example,
I've been thinking that I should suggest in the documentation that it is best
used for short text entries (say, up to 256 characters), rather than longer
entries (like email bodies or journal articles), and that for longer entries,
one should really make use of [tsearch2], instead. There are other notes and
caveats in the [patch submission][submitted a patch]. Please do let me know what
you think.

  [submitted a patch]: http://archives.postgresql.org/message-id/4013F1AE-FE1B-427B-8C23-1A5681DA297E@kineticode.com
    "PATCH: CITEXT 2.0"
  [yak shaving]: http://en.wiktionary.org/wiki/yak_shaving
    "Wiktionary: “yak shaving”"
  [citext project on pgFoundry]: http://pgfoundry.org/projects/citext/
  [email domain]: http://www.varlena.com/GeneralBits/128.php
    "PostgreSQL General Bits: “Base Type using Domains”"
  [July CommitFest]: http://wiki.postgresql.org/index.php?title=CommitFest:2008-07
    "PostgreSQL CommitFest:2008-07"
  [tsearch2]: http://www.postgresql.org/docs/current/static/textsearch.html
    "PostgreSQL Documentation: Chapter 12. Full Text Search"
