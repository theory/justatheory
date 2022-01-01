--- 
date: 2009-09-23T22:10:22Z
slug: postgres-unicode-normalization
title: Unicode Normalization in SQL
aliases: [/computers/databases/postgresql/unicode-normalization.html]
tags: [Postgres, SQL, Unicode, Database Normalization, NFC, NFD, NFKC, NFKD]
type: post
---

I've been peripherally aware of the need for unicode normalization in my code
for a while, but only got around to looking into it today. Although I use
[Encode] to convert text inputs into Perl's internal form and UTF-8 or an
appropriate encoding in all my outputs, it does nothing about normalization.

What's normalization you ask?

Well, UTF-8 allows some characters to be encoded in different ways. For example,
é can be written as either “&\#x00e9;”, which is a “precomposed character,” or
as “&\#x0065;&\#x0301;”, which is a combination of “e” and “́”. This is all well
and good, but the trouble comes when you want to compare values. Observe this
Perl one-liner:

    % perl -le 'print "\x{00e9}" eq "\x{0065}\x{0301}" ? "t" : "f"'
    f

The same issue exists in your database. Here's an example from PostgreSQL:

    try=# select U&'\00E9' = U&'\0065\0301';
     ?column? 
    ----------
     f
    (1 row)

If you have a user enter data in your Web app using combining characters, and
then another does a search with canonical characters, the search will fail. This
won't do at all.

The solution is to [normalize] your Unicode data. In Perl, you can use
[Unicode::Normalize], a C/XS module that uses Perl's internal unicode tables to
convert things as appropriate. For general use the NFC normalization is
[probably best][]:

``` perl
use Unicode::Normalize;
$string = NFC $string;
```

PostgreSQL offers no normalization routines. However, the SQL standard mandates
one (as of SQL 2008, at least). It looks like this:

    <normalize function> ::= NORMALIZE <left paren> <character value expression> [ <comma> <normal form> [ <comma> <normalize function result length> ] ] <right paren>
    <normal form> ::= NFC | NFD | NFKC | NFKD

The second argument defaults to `NFC` and the third, which specifies a maximum
length of the return value, is optional. The fact that it looks like a function
means that we can use PL/PerlU to emulate it in PostgreSQL until a proper
implementation makes it into core. Here's how:

``` postgres
CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT,
    form   TEXT,
    maxlen INT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize 'normalize';
    my ($string, $form, $maxlen) = @_;
    my $ret = normalize($form, $string);
    elog(ERROR, 'Normalized value is too long') if length $ret > $maxlen;
    return $ret;
$$;

CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT,
    form   TEXT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize 'normalize';
    return normalize($_[1], $_[0]);
$$;

CREATE OR REPLACE FUNCTION NORMALIZE(
    string TEXT
) RETURNS TEXT LANGUAGE plperlu AS $$
    use Unicode::Normalize 'normalize';
    return normalize('NFC', shift);
$$;
```

I wrote a few tests to make sure it was sane:

``` postgres
SELECT U&'\0065\0301' as combined,
       char_length(U&'\0065\0301'),
       NORMALIZE(U&'\0065\0301') as normalized,
       char_length(NORMALIZE(U&'\0065\0301'));

SELECT NORMALIZE(U&'\0065\0301', 'NFC')  AS NFC,
       NORMALIZE(U&'\0065\0301', 'NFD')  AS NFD,
       NORMALIZE(U&'\0065\0301', 'NFKC') AS NFKC,
       NORMALIZE(U&'\0065\0301', 'NFKD') AS NFKD
;

SELECT NORMALIZE(U&'\0065\0301', 'NFC', 1)  AS NFC,
       NORMALIZE(U&'\0065\0301', 'NFD', 2)  AS NFD,
       NORMALIZE(U&'\0065\0301', 'NFKC', 1) AS NFKC,
       NORMALIZE(U&'\0065\0301', 'NFKD', 2) AS NFKD;

SELECT NORMALIZE(U&'\0065\0301', 'NFD', 1);
```

And the output

     combined | char_length | normalized | char_length 
    ----------+-------------+------------+-------------
     é        |           2 | é          |           1
    (1 row)

     nfc | nfd | nfkc | nfkd 
    -----+-----+------+------
     é   | é   | é    | é
    (1 row)

     nfc | nfd | nfkc | nfkd 
    -----+-----+------+------
     é   | é   | é    | é
    (1 row)

    psql:try.sql:45: ERROR:  error from Perl function "normalize": Normalized value is too long at line 5.

Cool! So that's fairly close to the standard. The main difference is that the
`form` argument must be a string instead of a constant literal. But PostgreSQL
would likely support both. The length argument is also a literal, and can be
`10 characters` or `64 bytes`, but for our purposes, this is fine. The only
downside to it is that it's slow: PostgreSQL must convert its text value to a
Perl string to pass to the function, and then Unicode::Normalize turns it into a
C string again to do the conversion, then back to a Perl string which, in turn,
is returned to PostgreSQL and converted back into the text form. Not the
quickest process, but may prove useful anyway.

### Update: 1 Hour Later

Note that this issue applies when using [full text search], too. Alas, it does
not normalize unicode characters for you:

    try=# select to_tsvector(U&'\00E9clair') @@ to_tsquery(U&'\0065\0301clair');
     ?column? 
    ----------
     f
    (1 row)

But normalizing with the functions I introduced does work:

    try=# select to_tsvector(U&'\00E9clair') @@ to_tsquery(normalize(U&'\0065\0301clair'));
     ?column? 
    ----------
     t
    (1 row)

So yes, this really can be an issue in your applications.

  [Encode]: https://metacpan.org/pod/Encode "Encode on CPAN"
  [normalize]: https://en.wikipedia.org/wiki/Unicode_normalization
    "Wikipedia: “Unicode equivalence”"
  [Unicode::Normalize]: https://metacpan.org/pod/Unicode::Normalize
    "Unicode::Normalize on CPAN"
  [probably best]: http://unicode.org/faq/normalization.html#2
    "Unicode Normalization FAQ: “Which forms of normalization should I support?”"
  [full text search]: https://www.postgresql.org/docs/current/textsearch.html
    "PostgreSQL Documentation: Full Text Search"
