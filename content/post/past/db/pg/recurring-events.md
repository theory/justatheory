--- 
date: 2008-01-30T20:04:22Z
description: ~
slug: recurring-events
title: How to Generate Recurring Events in the Database
aliases: [/computers/databases/postgresql/recurring_events.html]
tags: [Postgres, database, SQL, PL/pgSQL]
type: post
---

<p>This is a followup to
my <a href="/computers/databases/postgresql/reducing_view_calculations.html"
title="Need Help Reducing View Calculations">request for help</a> fixing the
performance of a database view that generated recurrences for events. This was
an essential feature of <a href="http://iwantsandy.com" title="Sandy — your
free personal assistant">Sandy</a>, and thus important to get right. The idea
when I started was simple:</p>

<ul>
  <li>Add a <code>recurrence</code> domain to the database that supports a
  number of different values, including <q>daily</q>, <q>weekly</q>,
  and <q>monthly</q>.</li>
  <li>Add a <code>recurrence</code> column to the <code>events</code> table
  that identify how an event recurs.</li>
  <li>Add a <code>recurrence_dates</code> table that contains a pre-generated
  list of recurrences for a given date. I'd populated this table with five
  years of dates, each one mapped to five years worth of recurrence dates (see
  the original<a
  href="/computers/databases/postgresql/reducing_view_calculations.html"
  title="Need Help Reducing View Calculations">blog entry</a> for more on the
  format of this table.</li>
  <li>Create a view that maps each <code>events</code> row to its date and
  recurrence in the <code>recurrence_dates</code> table.</li>
  <li>Profit.</li>
</ul>

<p>It was this last bullet point that didn't quite work out: although the data
was perfectly accurate, queries for a lot of events in the view were
<em>very</em> expensive. I mean, the query could run for 3-4 minutes. It was
just crazy! I couldn't figure out the problem, so I posted my <a
href="/computers/databases/postgresql/reducing_view_calculations.html"
title="Need Help Reducing View Calculations">request for help</a>. It was
through discussions that followed with <a href="http://www.depesz.com/"
title="&lt;/depesz&gt; blog">depesz</a> that I finally figured out what the
problem was: Although I was usually selecting only a week's or months worth of
events, the view was calculating rows for all five years worth of data for all
of the events for a given user. Um, <em>not efficient.</em></p>

<p>So here I finally document how, with a lot of help and example code from
depesz, I solved the problem. The trick was to use a function instead of a
view to generate the recurring event rows, and to limit it only to the dates
we're interested in. For convenience sake, I broke this down into two PL/pgSQL
functions: one to generate recurring dates and one to return the recurring
event rows. But first, here's the <code>recurrence</code> domain and the
<code>events</code> table, both of which are unchanged from the original
approach:</p>

<pre>
CREATE DOMAIN recurrence AS TEXT
CHECK ( VALUE IN ( &#x0027;none&#x0027;, &#x0027;daily&#x0027;, &#x0027;weekly&#x0027;, &#x0027;monthly&#x0027; ) );

CREATE TABLE events (
    id         SERIAL     PRIMARY KEY,
    user_id    INTEGER    NOT NULL,
    starts_at  TIMESTAMP  NOT NULL,
    start_tz   TEXT       NOT NULL,
    ends_at    TIMESTAMP,
    end_tz     TEXT       NOT NULL,
    recurrence RECURRENCE NOT NULL DEFAULT &#x0027;none&#x0027;
);
</pre>

<p>Just assume the <code>user_id</code> is a foreign key. Now let's populate
this table with some data. For the purposes of this demonstration, I'm going
to create one event per day for 1000 days, evenly divided between daily,
weekly, monthly, and no recurrences, as well as five different times of day
and six different durations:</p>

<pre>
INSERT INTO events (user_id, starts_at, start_tz, ends_at, end_tz, recurrence)
SELECT 1,
       ts::timestamp,
       &#x0027;PST8PDT&#x0027;,
       ts::timestamp + dur::interval,
       &#x0027;PST8PDT&#x0027;,
       recur
  FROM (
    SELECT &#x0027;2007-12-19&#x0027;::date + i || &#x0027; &#x0027; || CASE i % 5
               WHEN 0 THEN &#x0027;06:00&#x0027;
               WHEN 1 THEN &#x0027;10:00&#x0027;
               WHEN 2 THEN &#x0027;14:00&#x0027;
               WHEN 3 THEN &#x0027;18:00&#x0027;
               ELSE        &#x0027;22:30&#x0027;
               END,
           CASE i % 6
               WHEN 0 THEN &#x0027;2 hours&#x0027;
               WHEN 1 THEN &#x0027;1 hour&#x0027;
               WHEN 2 THEN &#x0027;45 minutes&#x0027;
               WHEN 3 THEN &#x0027;3.5 hours&#x0027;
               WHEN 4 THEN &#x0027;15 minutes&#x0027;
               ELSE        &#x0027;30 minutes&#x0027;
               END,
           CASE i % 4
               WHEN 0 THEN &#x0027;daily&#x0027;
               WHEN 1 THEN &#x0027;weekly&#x0027;
               WHEN 2 THEN &#x0027;monthly&#x0027;
               ELSE        &#x0027;none&#x0027;
               END
    FROM generate_series(1, 1000) as gen(i)
  ) AS ser( ts, dur, recur);
</pre>

<p>This gives us some nicely distributed data:</p>

<pre>
try=# select * from events limit 10;
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
    1 |       1 | 2007-12-20 10:00:00 | PST8PDT  | 2007-12-20 11:00:00 | PST8PDT | weekly
    2 |       1 | 2007-12-21 14:00:00 | PST8PDT  | 2007-12-21 14:45:00 | PST8PDT | monthly
    3 |       1 | 2007-12-22 18:00:00 | PST8PDT  | 2007-12-22 21:30:00 | PST8PDT | none
    4 |       1 | 2007-12-23 22:30:00 | PST8PDT  | 2007-12-23 22:45:00 | PST8PDT | daily
    5 |       1 | 2007-12-24 06:00:00 | PST8PDT  | 2007-12-24 06:30:00 | PST8PDT | weekly
    6 |       1 | 2007-12-25 10:00:00 | PST8PDT  | 2007-12-25 12:00:00 | PST8PDT | monthly
    7 |       1 | 2007-12-26 14:00:00 | PST8PDT  | 2007-12-26 15:00:00 | PST8PDT | none
    8 |       1 | 2007-12-27 18:00:00 | PST8PDT  | 2007-12-27 18:45:00 | PST8PDT | daily
    9 |       1 | 2007-12-28 22:30:00 | PST8PDT  | 2007-12-29 02:00:00 | PST8PDT | weekly
   10 |       1 | 2007-12-29 06:00:00 | PST8PDT  | 2007-12-29 06:15:00 | PST8PDT | monthly
(10 rows)
</pre>

<p>Now let's get to the recurring date function:</p>

<pre>
CREATE OR REPLACE FUNCTION  generate_recurrences(
    recurs RECURRENCE, 
    start_date DATE,
    end_date DATE
)
    RETURNS setof DATE
    LANGUAGE plpgsql IMMUTABLE
    AS $BODY$
DECLARE
    next_date DATE := start_date;
    duration  INTERVAL;
    day       INTERVAL;
    check     TEXT;
BEGIN
    IF recurs = &#x0027;none&#x0027; THEN
        &#x002d;&#x002d; Only one date ever.
        RETURN next next_date;
    ELSIF recurs = &#x0027;weekly&#x0027; THEN
        duration := &#x0027;7 days&#x0027;::interval;
        WHILE next_date &lt;= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
        END LOOP;
    ELSIF recurs = &#x0027;daily&#x0027; THEN
        duration := &#x0027;1 day&#x0027;::interval;
        WHILE next_date &lt;= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
        END LOOP;
    ELSIF recurs = &#x0027;monthly&#x0027; THEN
        duration := &#x0027;27 days&#x0027;::interval;
        day      := &#x0027;1 day&#x0027;::interval;
        check    := to_char(start_date, &#x0027;DD&#x0027;);
        WHILE next_date &lt;= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
            WHILE to_char(next_date, &#x0027;DD&#x0027;) &lt;&gt; check LOOP
                next_date := next_date + day;
            END LOOP;
        END LOOP;
    ELSE
        &#x002d;&#x002d; Someone needs to update this function, methinks.
        RAISE EXCEPTION &#x0027;Recurrence % not supported by generate_recurrences()&#x0027;, recurs;
    END IF;
END;
$BODY$;
</pre>

<p>The idea here is pretty simple: pass in a recurrence (<q>daily</q>,
<q>weekly</q>, or <q>monthly</q>), a start date, and an end date, and get
back a set of all the recurrence dates between the start and end dates:</p>

<pre>
try=# \timing
Timing is on.
try=# select * from  generate_recurrences(&#x0027;daily&#x0027;, &#x0027;2008&#x002d;01&#x002d;29&#x0027;, &#x0027;2008&#x002d;02&#x002d;05&#x0027;);
 generate_recurrences 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 2008&#x002d;01&#x002d;29
 2008&#x002d;01&#x002d;30
 2008&#x002d;01&#x002d;31
 2008&#x002d;02&#x002d;01
 2008&#x002d;02&#x002d;02
 2008&#x002d;02&#x002d;03
 2008&#x002d;02&#x002d;04
 2008&#x002d;02&#x002d;05
(8 rows)

Time: 0.548 ms
try=# select * from  generate_recurrences(&#x0027;weekly&#x0027;, &#x0027;2008&#x002d;01&#x002d;29&#x0027;, &#x0027;2008&#x002d;03&#x002d;05&#x0027;);
 generate_recurrences 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 2008&#x002d;01&#x002d;29
 2008&#x002d;02&#x002d;05
 2008&#x002d;02&#x002d;12
 2008&#x002d;02&#x002d;19
 2008&#x002d;02&#x002d;26
 2008&#x002d;03&#x002d;04
(6 rows)

Time: 0.670 ms
try=# select * from  generate_recurrences(&#x0027;monthly&#x0027;, &#x0027;2008&#x002d;01&#x002d;29&#x0027;, &#x0027;2008&#x002d;05&#x002d;05&#x0027;);
 generate_recurrences 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 2008&#x002d;01&#x002d;29
 2008&#x002d;02&#x002d;29
 2008&#x002d;03&#x002d;29
 2008&#x002d;04&#x002d;29
(4 rows)

Time: 0.644 ms
</pre>

<p>Not bad, eh? And PostgreSQL's date and interval calculation operators are
<a
href="http://www.depesz.com/index.php/2007/12/27/how-many-1sts-of-any-month-were-sundays-since-1901-01-01/"
title="&lt;depesz/&gt;: how many 1sts of any month were sundays - since
1901-01-01?"><em>wicked fast</em></a>. Check out how long it dates to generate
two years worth of daily recurrence dates:</p>

<pre>
try=# select * from  generate_recurrences(&#x0027;daily&#x0027;, &#x0027;2008-01-29&#x0027;, &#x0027;2010-02-05&#x0027;);
 generate_recurrences 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 2008-01-29
 2008-01-30
 2008-01-31
...
 2010-02-03
 2010-02-04
 2010-02-05
(739 rows)

Time: 4.982 ms
</pre>

<p>Awesome. And the great thing about this function is that any time I need to
add new recurrences (yearly, biweekly, quarterly, weekends, weekdays, etc.), I
just modify the domain and this function and we're ready to go.</p>

<p>And now, part two: the recurring event function:</p>

<pre>
CREATE OR REPLACE FUNCTION recurring_events_for(
   for_user_id INTEGER,
   range_start TIMESTAMP,
   range_end   TIMESTAMP
)
   RETURNS SETOF events
   LANGUAGE plpgsql STABLE
   AS $BODY$
DECLARE
   event events;
   start_date TIMESTAMPTZ;
   start_time TEXT;
   ends_at    TIMESTAMPTZ;
   next_date  DATE;
   recurs_at  TIMESTAMPTZ;
BEGIN
   FOR event IN 
       SELECT *
         FROM events
        WHERE user_id = for_user_id
          AND (
                  recurrence &lt;&gt; &#x0027;none&#x0027;
              OR  (
                     recurrence = &#x0027;none&#x0027;
                 AND starts_at BETWEEN range_start AND range_end
              )
          )
    LOOP
       IF event.recurrence = &#x0027;none&#x0027; THEN
         RETURN NEXT event;
         CONTINUE;
       END IF;

       start_date := event.starts_at::timestamptz AT TIME ZONE event.start_tz;
       start_time := start_date::time::text;
       ends_at    := event.ends_at::timestamptz AT TIME ZONE event.end_tz;

       FOR next_date IN
           SELECT *
             FROM generate_recurrences(
                      event.recurrence,
                      start_date::date,
                      (range_end AT TIME ZONE event.start_tz)::date
             )
       LOOP
           recurs_at := (next_date || &#x0027; &#x0027; || start_time)::timestamp
               AT TIME ZONE event.start_tz;
           EXIT WHEN recurs_at &gt; range_end;
           CONTINUE WHEN recurs_at &lt; range_start AND ends_at &lt; range_start;
           event.starts_at := recurs_at;
           event.ends_at   := ends_at;
           RETURN NEXT event;
       END LOOP;
   END LOOP;
   RETURN;
END;
$BODY$;
</pre>

<p>The idea here is to select the appropriate events for a given user between
two dates, and for each event iterate over all of the recurrences between the
two dates and return a row for each one. So the lines starting with <code>FOR
event IN</code> and ending with <code>LOOP</code> select the original events,
looking for either recurring events or non-recurring events that are between
the two dates. Note that if you needed to, you could easily refine this query
for your particular application, or even use
PL/pgSQL's <a href="http://www.postgresql.org/docs/8.3/static/plpgsql-control-structures.html#PLPGSQL-RECORDS-ITERATING"
title="PL/pgSQL: Looping Through Query Results"><code>EXECUTE</code></a>
operator to dynamically generate queries to suit particular application
needs.</p>

<p>Next, the block starting with <code>IF event.recurrence =
&#x0027;none&#x0027; THEN</code> simply returns any non-recurring events.
Although the next block already handles this case, adding this optimization
eliminates a fair bit of calculation for the common case of non-recurring
events.</p>

<p>Then the lines starting with <code>FOR next_date IN</code> and ending with
<code>LOOP</code> select all of the dates for the recurrence in question,
using the <code>generate_recurrences()</code> function created earlier. From
<code>LOOP</code> to <code>END LOOP;</code>, the function generates the start
and end timestamps, exiting the loop when the start date falls after the range
or when it falls before the range and the end date falls after the range.
There are many other tweaks one could make here to modify which recurrences
are included and which are excluded. For example, if you had a column in the
<code>events</code> table such as <code>exclude_dates TIMESTAMP[] NOT NULL
DEFAULT '{}'</code> that stored an array of dates to ignore when generating
recurrences, you could just add this line to go ahead and exclude them from
the results returned by the function:</p>

<pre>
           CONTINUE WHEN recurs_at = ANY( exclude_dates );
</pre>

<p>But enough of the details: let's see how it works! Here's a query for a
week's worth of data:</p>

<pre>
try=# select * from recurring_events_for(1, &#x0027;2007-12-19&#x0027;, &#x0027;2007-12-26&#x0027;);
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
    1 |       1 | 2007-12-20 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    2 |       1 | 2007-12-21 14:00:00 | PST8PDT  | 2007-12-21 06:45:00 | PST8PDT | monthly
    3 |       1 | 2007-12-22 18:00:00 | PST8PDT  | 2007-12-22 21:30:00 | PST8PDT | none
    4 |       1 | 2007-12-23 22:30:00 | PST8PDT  | 2007-12-23 14:45:00 | PST8PDT | daily
    4 |       1 | 2007-12-24 22:30:00 | PST8PDT  | 2007-12-23 14:45:00 | PST8PDT | daily
    4 |       1 | 2007-12-25 22:30:00 | PST8PDT  | 2007-12-23 14:45:00 | PST8PDT | daily
    5 |       1 | 2007-12-24 06:00:00 | PST8PDT  | 2007-12-23 22:30:00 | PST8PDT | weekly
    6 |       1 | 2007-12-25 10:00:00 | PST8PDT  | 2007-12-25 04:00:00 | PST8PDT | monthly
(8 rows)

Time: 51.890 ms
</pre>

<p>Note the time it took to execute this query. 52 ms is a <em>hell</em> of a
lot faster than the several minutes it took to run a similar query using the
old view. Plus, I'm not limited to just the recurrence dates I've
pre-calculated in the old <code>recurrence_dates</code> table. Now we can use
whatever dates are supported by PostgreSQL. It's even fast when we look at a
year's worth of data:</p>

<pre>
try=# select * from recurring_events_for(1, &#x0027;2007-12-19&#x0027;, &#x0027;2008-12-19&#x0027;);
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
    1 |       1 | 2007-12-20 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2007-12-27 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2008-01-03 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2008-01-10 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2008-01-17 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2008-01-24 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
    1 |       1 | 2008-01-31 10:00:00 | PST8PDT  | 2007-12-20 03:00:00 | PST8PDT | weekly
...
  364 |       1 | 2008-12-17 22:30:00 | PST8PDT  | 2008-12-17 14:45:00 | PST8PDT | daily
  364 |       1 | 2008-12-18 22:30:00 | PST8PDT  | 2008-12-17 14:45:00 | PST8PDT | daily
  365 |       1 | 2008-12-18 06:00:00 | PST8PDT  | 2008-12-17 22:30:00 | PST8PDT | weekly
(19691 rows)

Time: 837.759 ms
</pre>

<p>Not stellar, but still respectable. Given that for a typical application, a
user will be looking at only a day's or a week's or a month's events at a time,
this seems to be an acceptable trade-off. I mean, how often will your users
need to see a list of 20,000 events? And even if a user <em>was</em>looking at
a year's worth of data, it's unlikely that 75% of them would be recurring as
in the example data here.</p>

<p>I was fucking <em>pumped</em> with this solution, and Sandy has hummed
along nicely since we put it into production. If you're interested in trying
it for yourself, I've you can get all the SQL from this blog entry <a
href="/code/recurring_events.sql" title="Download the code for this blog
entry">here</a>.</p>

<p>The only thing I would like to have been able to do differently was to
encapsulate the <code>recurring_events_for()</code> function in a view. Such
would have made it much easier to actually <em>use</em> this solution in
Rails. If you know how to do that, please do leave a comment. As for how I
hacked Rails to use the function, well, that's a blog post for another
day.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/recurring_events.html">old layout</a>.</small></p>


