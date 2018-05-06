--- 
date: 2007-11-07T21:03:00Z
slug: timezone-validation
title: Validating Time Zones in PostgreSQL
aliases: [/computers/databases/postgresql/timezone_validation.html]
tags: [Postgres, time zones, PL/pgSQL]
---

<p>I recently needed to validate that a value stored in
a <code>TEXT</code>column was a valid time zone identifier. Why? Because I was
using its value inside the database to
<a href="/computers/databases/postgresql/reducing_view_calculations.html"
title="Need Help Reducing View Calculations">convert timestamp columns from
UTC to a valid zone</a>. So I set about writing a function I could use in a
constraint.</p>

<p>It turns out that PostgreSQL has a pretty nice view that lists all of the
time zones that it recognizes. It's called <code>pg_timezone_names</code>:</p>

<pre>
try=# select * from pg_timezone_names limit 5;
        name        | abbrev | utc_offset | is_dst 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 Africa/Abidjan     | GMT    | 00:00:00   | f
 Africa/Accra       | GMT    | 00:00:00   | f
 Africa/Addis_Ababa | EAT    | 03:00:00   | f
 Africa/Algiers     | CET    | 01:00:00   | f
 Africa/Asmara      | EAT    | 03:00:00   | f
(5 rows)
</pre>

<p>Cool. So all I had to do was to look up the value in this view. My first
stab at creating a time zone validation function therefore looked like
this:</p>

<pre>
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
</pre>

<p>This should pretty well cover anything that PostgreSQL considers valid. So
does it work? You bet:</p>

<pre>
sandy_development=# \timing
Timing is on.
sandy_development=# select is_timezone('America/Los_Angeles');
 is_timezone 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)

Time: 457.096 ms
sandy_development=# select is_timezone('Foo/Bar');
 is_timezone 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)

Time: 472.752 ms
</pre>

<p>Perfect! Well, except for just one thing: performance is abysmal. A half
second per shot? Not very useful for constraints. And since
<code>pg_timezone_names</code> is a view (and, under that, a function), I
can't create indexes.</p>

<p>But then I did something dangerous: I started thinking. I realized that I
needed this function when our app started getting errors like this:</p>

<pre>
try=# select now() at time zone 'Foo/Bar';
ERROR:  time zone "Foo/Bar" not recognized
</pre>

<p>So the underlying C code throws an error when a time zone is invalid. What
if I could just trap the error? Well, PL/pgSQL conveniently has exception
handling, so I could do just that. But there was only one problem. PL/pgSQL's
exception handling syntax requires that you specify an error condition. Here's
what the documentation has:</p>

<pre>
EXCEPTION
    WHEN condition [ OR condition ... ] THEN
        handler_statements
    [ WHEN condition [ OR condition ... ] THEN
          handler_statements
      ... ]
END;
</pre>

<p>Conditions are
<a href="http://www.postgresql.org/docs/current/static/errcodes-appendix.html"
title="PostgreSQL Documentation: Appendix A. PostgreSQL Error Codes">error
codes</a>. But which one corresponds to the invalid time zone error? I tried a
few, but couldn't figure out which one. (Anyone know now to map errors you see
in <code>psql</code> to the error codes listed in Appendix A? Let me know!)
But really, my function just needed to do one thing. Couldn't I just trap any
old error?</p>

<p>A careful re-read of the PL/pgSQL documentation reveals that, yes, you can.
Use the condition <q>OTHERS,</q> and you can catch almost anything. With this
information in hand, I quickly wrote:</p>

<pre>
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
</pre>

<p>And how well does this one work?</p>

<pre>
sandy_development=# select is_timezone('America/Los_Angeles');
 is_timezone 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 t
(1 row)

Time: 3.009 ms
sandy_development=# select is_timezone('Foo/Bar');
 is_timezone 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 f
(1 row)

Time: 1.224 ms
</pre>

<p>Yes, I'll take 1-3 ms over 400-500 ms any day! I might even
<a href="http://www.postgresql.org/docs/current/static/sql-createdomain.html" title="PostgreSQL Documentation: CREATE DOMAIN">create a domain</a> for this
and be done with it:</p>

<pre>
CREATE DOMAIN timezone AS TEXT
CHECK ( is_timezone( value ) );
</pre>

<p>Enjoy!</p>


<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/timezone_validation.html">old layout</a>.</small></p>


