--- 
date: 2007-11-07T21:03:00Z
slug: postgres-timezone-validation
title: Validating Time Zones in PostgreSQL
aliases: [/computers/databases/postgresql/timezone_validation.html]
tags: [Postgres, Time Zones, PL/pgSQL]
type: post
---

I recently needed to validate that a value stored in a `TEXT`column was a valid
time zone identifier. Why? Because I was using its value inside the database to
[convert timestamp columns from UTC to a valid zone]. So I set about writing a
function I could use in a constraint.

It turns out that PostgreSQL has a pretty nice view that lists all of the time
zones that it recognizes. It's called `pg_timezone_names`:

    try=# select * from pg_timezone_names limit 5;
            name        | abbrev | utc_offset | is_dst 
    --------------------+--------+------------+--------
     Africa/Abidjan     | GMT    | 00:00:00   | f
     Africa/Accra       | GMT    | 00:00:00   | f
     Africa/Addis_Ababa | EAT    | 03:00:00   | f
     Africa/Algiers     | CET    | 01:00:00   | f
     Africa/Asmara      | EAT    | 03:00:00   | f
    (5 rows)

Cool. So all I had to do was to look up the value in this view. My first stab at
creating a time zone validation function therefore looked like this:


``` postgres
CREATE OR REPLACE FUNCTION is_timezone( tz TEXT ) RETURNS BOOLEAN as $$
DECLARE
    bool BOOLEAN;
BEGIN
    SELECT TRUE INTO bool
    FROM pg_timezone_names
    WHERE LOWER(name) = LOWER(tz)
        OR LOWER(abbrev) = LOWER(tz);
    RETURN FOUND;
END;
$$ language plpgsql STABLE;
```

This should pretty well cover anything that PostgreSQL considers valid. So does
it work? You bet:

    sandy_development=# \timing
    Timing is on.
    sandy_development=# select is_timezone('America/Los_Angeles');
     is_timezone 
    -------------
     t
    (1 row)

    Time: 457.096 ms
    sandy_development=# select is_timezone('Foo/Bar');
     is_timezone 
    -------------
     f
    (1 row)

    Time: 472.752 ms

Perfect! Well, except for just one thing: performance is abysmal. A half second
per shot? Not very useful for constraints. And since `pg_timezone_names` is a
view (and, under that, a function), I can't create indexes.

But then I did something dangerous: I started thinking. I realized that I needed
this function when our app started getting errors like this:

    try=# select now() at time zone 'Foo/Bar';
    ERROR:  time zone "Foo/Bar" not recognized

So the underlying C code throws an error when a time zone is invalid. What if I
could just trap the error? Well, PL/pgSQL conveniently has exception handling,
so I could do just that. But there was only one problem. PL/pgSQL's exception
handling syntax requires that you specify an error condition. Here's what the
documentation has:

``` postgres
EXCEPTION
    WHEN condition [ OR condition ... ] THEN
        handler_statements
    [ WHEN condition [ OR condition ... ] THEN
            handler_statements
        ... ]
END;
```

Conditions are [error codes]. But which one corresponds to the invalid time zone
error? I tried a few, but couldn't figure out which one. (Anyone know now to map
errors you see in `psql` to the error codes listed in Appendix A? Let me know!)
But really, my function just needed to do one thing. Couldn't I just trap any
old error?

A careful re-read of the PL/pgSQL documentation reveals that, yes, you can. Use
the condition “OTHERS,” and you can catch almost anything. With this information
in hand, I quickly wrote:

``` postgres
CREATE OR REPLACE FUNCTION is_timezone( tz TEXT ) RETURNS BOOLEAN as $$
DECLARE
    date TIMESTAMPTZ;
BEGIN
    date := now() AT TIME ZONE tz;
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ language plpgsql STABLE;
```

And how well does this one work?

    sandy_development=# select is_timezone('America/Los_Angeles');
     is_timezone 
    -------------
     t
    (1 row)

    Time: 3.009 ms
    sandy_development=# select is_timezone('Foo/Bar');
     is_timezone 
    -------------
     f
    (1 row)

    Time: 1.224 ms

Yes, I'll take 1-3 ms over 400-500 ms any day! I might even [create a domain]
for this and be done with it:

``` postgres
CREATE DOMAIN timezone AS TEXT
CHECK ( is_timezone( value ) );
```

Enjoy!

**Update:** From a comment left by Tom Lane, use `invalid_parameter_value`
rather than `OTHERS`:

``` postgres
CREATE OR REPLACE FUNCTION is_timezone( tz TEXT ) RETURNS BOOLEAN as $$
DECLARE
    date TIMESTAMPTZ;
BEGIN
    date := now() AT TIME ZONE tz;
    RETURN TRUE;
EXCEPTION invalid_parameter_value OTHERS THEN
    RETURN FALSE;
END;
$$ language plpgsql STABLE;
```

  [convert timestamp columns from UTC to a valid zone]: {{% ref "/post/past/db/pg/reducing-view-calculations" %}}
    "Need Help Reducing View Calculations"
  [error codes]: https://www.postgresql.org/docs/current/errcodes-appendix.html
    "PostgreSQL Documentation: Appendix A. PostgreSQL Error Codes"
  [create a domain]: https://www.postgresql.org/docs/current/sql-createdomain.html
    "PostgreSQL Documentation: CREATE DOMAIN"
