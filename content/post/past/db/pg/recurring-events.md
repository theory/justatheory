--- 
date: 2008-01-30T20:04:22Z
description: ~
slug: postgres-recurring-events
title: How to Generate Recurring Events in the Database
aliases: [/computers/databases/postgresql/recurring_events.html]
tags: [Postgres, databases, SQL, PL/pgSQL]
type: post
---

This is a followup to my [request for help] fixing the performance of a database
view that generated recurrences for events. This was an essential feature of
[Sandy], and thus important to get right. The idea when I started was simple:

-   Add a `recurrence` domain to the database that supports a number of
    different values, including “daily”, “weekly”, and “monthly”.
-   Add a `recurrence` column to the `events` table that identify how an event
    recurs.
-   Add a `recurrence_dates` table that contains a pre-generated list of
    recurrences for a given date. I'd populated this table with five years of
    dates, each one mapped to five years worth of recurrence dates (see the
    original [blog entry][request for help] for more on the format of this table.
-   Create a view that maps each `events` row to its date and recurrence in the
    `recurrence_dates` table.
-   Profit.

It was this last bullet point that didn't quite work out: although the data was
perfectly accurate, queries for a lot of events in the view were *very*
expensive. I mean, the query could run for 3-4 minutes. It was just crazy! I
couldn't figure out the problem, so I posted my [request for help]. It was
through discussions that followed with [depesz] that I finally figured out what
the problem was: Although I was usually selecting only a week's or months worth
of events, the view was calculating rows for all five years worth of data for
all of the events for a given user. Um, *not efficient.*

So here I finally document how, with a lot of help and example code from depesz,
I solved the problem. The trick was to use a function instead of a view to
generate the recurring event rows, and to limit it only to the dates we're
interested in. For convenience sake, I broke this down into two PL/pgSQL
functions: one to generate recurring dates and one to return the recurring event
rows. But first, here's the `recurrence` domain and the `events` table, both of
which are unchanged from the original approach:

``` postgres
CREATE DOMAIN recurrence AS TEXT
CHECK ( VALUE IN ( 'none', 'daily', 'weekly', 'monthly' ) );

CREATE TABLE events (
    id         SERIAL     PRIMARY KEY,
    user_id    INTEGER    NOT NULL,
    starts_at  TIMESTAMP  NOT NULL,
    start_tz   TEXT       NOT NULL,
    ends_at    TIMESTAMP,
    end_tz     TEXT       NOT NULL,
    recurrence RECURRENCE NOT NULL DEFAULT 'none'
);
```

Just assume the `user_id` is a foreign key. Now let's populate this table with
some data. For the purposes of this demonstration, I'm going to create one event
per day for 1000 days, evenly divided between daily, weekly, monthly, and no
recurrences, as well as five different times of day and six different durations:

``` postgres
INSERT INTO events (user_id, starts_at, start_tz, ends_at, end_tz, recurrence)
SELECT 1,
       ts::timestamp,
       'PST8PDT',
       ts::timestamp + dur::interval,
       'PST8PDT',
       recur
  FROM (
    SELECT '2007-12-19'::date + i || ' ' || CASE i % 5
               WHEN 0 THEN '06:00'
               WHEN 1 THEN '10:00'
               WHEN 2 THEN '14:00'
               WHEN 3 THEN '18:00'
               ELSE        '22:30'
               END,
           CASE i % 6
               WHEN 0 THEN '2 hours'
               WHEN 1 THEN '1 hour'
               WHEN 2 THEN '45 minutes'
               WHEN 3 THEN '3.5 hours'
               WHEN 4 THEN '15 minutes'
               ELSE        '30 minutes'
               END,
           CASE i % 4
               WHEN 0 THEN 'daily'
               WHEN 1 THEN 'weekly'
               WHEN 2 THEN 'monthly'
               ELSE        'none'
               END
    FROM generate_series(1, 1000) as gen(i)
  ) AS ser( ts, dur, recur);
```

This gives us some nicely distributed data:

``` postgres
try=# select * from events limit 10;
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
------+---------+---------------------+----------+---------------------+---------+------------
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
```

Now let's get to the recurring date function:

``` postgres
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
    IF recurs = 'none' THEN
        -- Only one date ever.
        RETURN next next_date;
    ELSIF recurs = 'weekly' THEN
        duration := '7 days'::interval;
        WHILE next_date <= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
        END LOOP;
    ELSIF recurs = 'daily' THEN
        duration := '1 day'::interval;
        WHILE next_date <= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
        END LOOP;
    ELSIF recurs = 'monthly' THEN
        duration := '27 days'::interval;
        day      := '1 day'::interval;
        check    := to_char(start_date, 'DD');
        WHILE next_date <= end_date LOOP
            RETURN NEXT next_date;
            next_date := next_date + duration;
            WHILE to_char(next_date, 'DD') <> check LOOP
                next_date := next_date + day;
            END LOOP;
        END LOOP;
    ELSE
        -- Someone needs to update this function, methinks.
        RAISE EXCEPTION 'Recurrence % not supported by generate_recurrences()', recurs;
    END IF;
END;
$BODY$;
```

The idea here is pretty simple: pass in a recurrence (“daily”, “weekly”, or
“monthly”), a start date, and an end date, and get back a set of all the
recurrence dates between the start and end dates:

``` postgres
try=# \timing
Timing is on.
try=# select * from generate_recurrences('daily', '2008-01-29', '2008-02-05');
 generate_recurrences 
----------------------
 2008-01-29
 2008-01-30
 2008-01-31
 2008-02-01
 2008-02-02
 2008-02-03
 2008-02-04
 2008-02-05
(8 rows)

Time: 0.548 ms
try=# select * from generate_recurrences('weekly', '2008-01-29', '2008-03-05');
 generate_recurrences 
----------------------
 2008-01-29
 2008-02-05
 2008-02-12
 2008-02-19
 2008-02-26
 2008-03-04
(6 rows)

Time: 0.670 ms
try=# select * from generate_recurrences('monthly', '2008-01-29', '2008-05-05');
 generate_recurrences 
----------------------
 2008-01-29
 2008-02-29
 2008-03-29
 2008-04-29
(4 rows)

Time: 0.644 ms
```

Not bad, eh? And PostgreSQL's date and interval calculation operators are
[*wicked fast*]. Check out how long it dates to generate two years worth of
daily recurrence dates:

``` postgres
try=# select * from  generate_recurrences('daily', '2008-01-29', '2010-02-05');
 generate_recurrences 
----------------------
 2008-01-29
 2008-01-30
 2008-01-31
...
 2010-02-03
 2010-02-04
 2010-02-05
(739 rows)

Time: 4.982 ms
```

Awesome. And the great thing about this function is that any time I need to add
new recurrences (yearly, biweekly, quarterly, weekends, weekdays, etc.), I just
modify the domain and this function and we're ready to go.

And now, part two: the recurring event function:

``` postgres
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
                   recurrence <> 'none'
               OR  (
                      recurrence = 'none'
                  AND starts_at BETWEEN range_start AND range_end
               )
           )
    LOOP
        IF event.recurrence = 'none' THEN
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
            recurs_at := (next_date || ' ' || start_time)::timestamp
                AT TIME ZONE event.start_tz;
            EXIT WHEN recurs_at > range_end;
            CONTINUE WHEN recurs_at < range_start AND ends_at < range_start;
            event.starts_at := recurs_at;
            event.ends_at   := ends_at;
            RETURN NEXT event;
        END LOOP;
    END LOOP;
    RETURN;
END;
$BODY$;
```

The idea here is to select the appropriate events for a given user between two
dates, and for each event iterate over all of the recurrences between the two
dates and return a row for each one. So the lines starting with `FOR event IN`
and ending with `LOOP` select the original events, looking for either recurring
events or non-recurring events that are between the two dates. Note that if you
needed to, you could easily refine this query for your particular application,
or even use PL/pgSQL's [`EXECUTE`] operator to dynamically generate queries to
suit particular application needs.

Next, the block starting with `IF event.recurrence = 'none' THEN` simply returns
any non-recurring events. Although the next block already handles this case,
adding this optimization eliminates a fair bit of calculation for the common
case of non-recurring events.

Then the lines starting with `FOR next_date IN` and ending with `LOOP` select
all of the dates for the recurrence in question, using the
`generate_recurrences()` function created earlier. From `LOOP` to `END LOOP;`,
the function generates the start and end timestamps, exiting the loop when the
start date falls after the range or when it falls before the range and the end
date falls after the range. There are many other tweaks one could make here to
modify which recurrences are included and which are excluded. For example, if
you had a column in the `events` table such as
`exclude_dates TIMESTAMP[] NOT NULL DEFAULT '{}'` that stored an array of dates
to ignore when generating recurrences, you could just add this line to go ahead
and exclude them from the results returned by the function:

``` postgres
            CONTINUE WHEN recurs_at = ANY( exclude_dates );
```

But enough of the details: let's see how it works! Here's a query for a week's
worth of data:

``` postgres
try=# select * from recurring_events_for(1, '2007-12-19', '2007-12-26');
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
------+---------+---------------------+----------+---------------------+---------+------------
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
```

Note the time it took to execute this query. 52 ms is a *hell* of a lot faster
than the several minutes it took to run a similar query using the old view.
Plus, I'm not limited to just the recurrence dates I've pre-calculated in the
old `recurrence_dates` table. Now we can use whatever dates are supported by
PostgreSQL. It's even fast when we look at a year's worth of data:

``` postgres
try=# select * from recurring_events_for(1, '2007-12-19', '2008-12-19');
  id  | user_id |      starts_at      | start_tz |       ends_at       | end_tz  | recurrence 
------+---------+---------------------+----------+---------------------+---------+------------
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
```

Not stellar, but still respectable. Given that for a typical application, a user
will be looking at only a day's or a week's or a month's events at a time, this
seems to be an acceptable trade-off. I mean, how often will your users need to
see a list of 20,000 events? And even if a user *was*looking at a year's worth
of data, it's unlikely that 75% of them would be recurring as in the example
data here.

I was fucking *pumped* with this solution, and Sandy has hummed along nicely
since we put it into production. If you're interested in trying it for yourself,
I've you can get all the SQL from this blog entry [here].

The only thing I would like to have been able to do differently was to
encapsulate the `recurring_events_for()` function in a view. Such would have
made it much easier to actually *use* this solution in Rails. If you know how to
do that, please do leave a comment. As for how I hacked Rails to use the
function, well, that's a blog post for another day.

  [request for help]: /computers/databases/postgresql/reducing_view_calculations.html
    "Need Help Reducing View Calculations"
  [Sandy]: http://iwantsandy.com "Sandy — your free personal assistant"
  [depesz]: http://www.depesz.com/ "</depesz> blog"
  [*wicked fast*]: http://www.depesz.com/index.php/2007/12/27/how-many-1sts-of-any-month-were-sundays-since-1901-01-01/
    "<depesz/>: how many 1sts of any month were sundays - since 1901-01-01?"
  [`EXECUTE`]: http://www.postgresql.org/docs/8.3/static/plpgsql-control-structures.html#PLPGSQL-RECORDS-ITERATING
    "PL/pgSQL: Looping Through Query Results"
  [here]: /code/recurring_events.sql "Download the code for this blog entry"
