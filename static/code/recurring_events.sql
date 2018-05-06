/*

Copyright and License
---------------------

Copyright (c) 2008 by David E. Wheeler. All Rights Reserved.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose, without fee, and without a written agreement is
hereby granted, provided that the above copyright notice and this paragraph
and the following two paragraphs appear in all copies.

IN NO EVENT SHALL DAVID E. WHEELER BE LIABLE TO ANY PARTY FOR DIRECT,
INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING LOST
PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN
IF DAVID E. WHEELER HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

DAVID E. WHEELER SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS" BASIS,
AND DAVID E. WHEELER HAS NO OBLIGATIONS TO PROVIDE MAINTENANCE, SUPPORT,
UPDATES, ENHANCEMENTS, OR MODIFICATIONS.

*/

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
       END loop;
   END LOOP;
   RETURN;
END;
$BODY$;
