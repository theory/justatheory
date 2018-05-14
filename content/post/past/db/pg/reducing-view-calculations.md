--- 
date: 2007-11-07T05:22:00Z
slug: reducing-view-calculations
title: Need Help Reducing View Calculations
aliases: [/computers/databases/postgresql/reducing_view_calculations.html]
tags: [Postgres, time zones]
type: post
---

<p>I could use some advice and suggestions for how to solve a performance
problem due to the highly redundant calculation of values in a view. Sorry for
the longish explanation. I wanted to make sure that I omitted no details in
describing the problem.</p>

<p>In order to support recurring events in an application I'm working on, we
have a lookup table that maps dates to their daily, weekly, monthly, and
yearly recurrences. It looks something like this:</p>

<pre>
try=# \d recurrence_dates
   Table &quot;public.recurrence_dates&quot;
   Column   |    Type    | Modifiers 
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 date       | date       | not null
 recurrence | recurrence | not null
 next_date  | date       | not null
Indexes:
    &quot;recurrence_dates_pkey&quot; PRIMARY KEY, btree (date, recurrence, next_date)
    &quot;index_recurrence_dates_on_date_and_recurrence&quot; btree (date, recurrence)

try=# select * from recurrence_dates
try-# where date = &#x0027;2007-11-04&#x0027;
try-# order by recurrence, next_date;
    date    | recurrence | next_date  
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;+&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
 2007-11-04 | daily      | 2007-11-04
 2007-11-04 | daily      | 2007-11-05
 2007-11-04 | daily      | 2007-11-06
 2007-11-04 | weekly     | 2007-11-04
 2007-11-04 | weekly     | 2007-11-11
 2007-11-04 | weekly     | 2007-11-18
 2007-11-04 | monthly    | 2007-11-04
 2007-11-04 | monthly    | 2007-12-04
 2007-11-04 | monthly    | 2008-01-04
 2007-11-04 | annually   | 2007-11-04
 2007-11-04 | annually   | 2008-11-04
 2007-11-04 | annually   | 2009-11-04
 2007-11-04 | none       | 2007-11-04
</pre>

<p>To get all of the permutations of recurring events, we simply select from a
view rather than from the <code>events</code> table that contains the actual
event data. The view joins <code>events</code>
to <code>recurrence_dates</code> table like so:</p>

<pre>
CREATE OR REPLACE VIEW recurring_events AS
SELECT id, name, user_id, duration,
       (rd.next_date || &#x0027; &#x0027; ||
       (starts_at::timestamptz at time zone start_tz)::time)::timestamp
       at time zone start_tz AS starts_at,
       start_tz
  FROM events LEFT JOIN recurrence_dates rd
    ON (events.starts_at::timestamptz at time zone events.start_tz)::date = rd.date
   AND events.recurrence = rd.recurrence;
</pre>

<p>Then, to get all of the recurrences of events for a user within a week, we
do something like this in the client code:</p>

<pre>
SELECT *
  FROM recurring_events
 WHERE user_id = 2
   AND starts_at BETWEEN &#x0027;2007-11-04 07:00:00&#x0027; AND &#x0027;2007-11-10 07:59:59&#x0027;;
</pre>

<p>This works perfectly, as all of our dates and times are stored in UTC
in <code>timestamp</code> columns. We pass UTC times for the appropriate
offset to the query (Pacific Time in this example) and, because the view does
the right thing in mapping the <code>starts_at</code> time for each event to
its proper time zone, we get all of the events within the date range, even if
they are recurrences of an earlier event, and with their times properly
set.</p>

<p>The trouble we're having, however, is all of those conversions. Until last
week, the view just kept everything in UTC and left it to the client to
convert to the proper zone in the <code>start_tz</code> column. But that
didn't work so well when an event's <code>starts_at</code> was during daylight
savings time and recurrences were in standard time: the standard time
recurrences were all an hour off! So I added the repeated instances
of <code>events.starts_at::timestamptz at time zone events.start_tz</code>.
But now the view is <em>really</em> slow.</p>

<p>Since the only thing that has changed is the addition of the time zone
conversions, I believe that the performance penalty is because of them. The
calculation executes multiple times per row: once for the join and once again
for the <code>starts_at</code> column. We can have an awful lot of events for
a given user, and an awful lot of recurrences of a given event. If, for
example, an event recurs daily for 2 years, there will be around 730 rows for
that one event. And the calculation has to be executed for every one of them
before the <code>WHERE</code> clause can be properly evaluated. Ouch! Worse
still, we actually have <em>three</em> columns that do this in our
application, not just one as in the example here.</p>

<p>So what I need is a way to execute that calculation just once for each
row in the <code>events</code> table, rather than once for each row in the
<code>recurring_events</code> view. I figure 1 calculation will be a heck of a
lot faster than 730! So the question is, how do I do this? How do I get the
view to execute the conversion of the <code>starts_at</code> to
the <code>start_tz</code> time zone only once for each row
in <code>events</code>, regardless of how many rows it ends up generating in
the <code>recurring_events</code> view?</p>

<p>Suggestions warmly welcomed. This is a bit of a tickler for me, and
since the query performance on these views is killing us, I need to get
this adjusted post haste!</p>

<p>Meanwhile, tomorrow I'll post a cool hack I came up with for validating
time zones in the database. Something to look forward to as you ponder my
little puzzle, eh?</p>

<p><strong>Update 2008-01-30:</strong> <em>Thanks to help from depesz, I came
figured out what the underling problem was and solved it much more elegantly
using PL/pgSQL. I've now <a href="/computers/databases/postgresql/recurring_events.html" title="How to Generate Recurring Events in the Database">written up the basic recipe.
Enjoy!</em></p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/reducing_view_calculations.html">old layout</a>.</small></p>


