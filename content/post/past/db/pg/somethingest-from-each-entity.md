--- 
date: 2010-01-12T06:12:02Z
slug: somethingest-from-each-entity
title: "SQL Hack: The Something-est From Each Entity"
aliases: [/computers/databases/postgresql/somethingest-from-each-entity.html]
tags: [Postgres, SQL, Window Functions, Common Table Expressions]
type: post
---

This is a pattern that I have dealt with many times, but never figured out how
to adequately handle. Say that you have imported a mailbox into your database,
and you want a list of the latest messages between each pair of recipients
(sender and receiver — I'm ignoring multiple receivers for the moment). The data
might look like this:

``` postgres
BEGIN;

CREATE TABLE messages (
    sender   TEXT        NOT NULL,
    receiver TEXT        NOT NULL,
    sent_at  TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
    body     TEXT        NOT NULL DEFAULT ''
);

INSERT INTO messages ( sender, receiver, body )
VALUES ('Theory', 'Strongrrl', 'Hi There.' );

INSERT INTO messages ( sender, receiver, body )
VALUES ('Strongrrl', 'Theory', 'Hi yourself.' );

INSERT INTO messages ( sender, receiver, body )
VALUES ('Anna', 'Theory', 'What''s for dinner?' );

INSERT INTO messages ( sender, receiver, body )
VALUES ('Theory', 'Anna', 'Brussels Sprouts.' );

INSERT INTO messages ( sender, receiver, body )
VALUES ('Anna', 'Theory', 'Oh man!' );

COMMIT;
```

So the goal is to show the most recent message between Theory and Strongrrl and
the most recent message between Theory and Anna, without regard to who is the
sender and who is the receiver. After running into this many times, today I
consulted my [colleagues], showing them this dead simple (and wrong!) query to
demonstrate what I wanted:

``` postgres
SELECT sender, recipient, sent_at, body
  FROM messages
 GROUP BY sender, recipient
HAVING sent_at = max(sent_at);
```

That’s wrong because one can’t have columns in the `SELECT` expression that are
not either aggregate expressions or included in the`GROUP BY` expression. It’s a
violation of the standard (and prone to errors, I suspect). [Andrew] immediately
said, “Classic case for `DISTINCT ON`”. This lovely little expression is a
PostgreSQL extension not included in the SQL standard. It’s implementation looks
like this:

``` postgres
SELECT DISTINCT ON (
          CASE WHEN receiver > sender
               THEN receiver || sender
               ELSE sender   || receiver
          END
       ) sender, receiver, sent_at, body
  FROM messages
 ORDER BY CASE WHEN receiver > sender
               THEN receiver || sender
               ELSE sender   || receiver
          END, sent_at DESC;
```

This query is saying, “fetch the rows where the sender and the receiver are
distinct, and order by `sent_at DESC`. THE `CASE` statement to get a uniform
value for the combination of sender and receiver is a bit unfortunate, but it
does the trick:

      sender   | receiver |            sent_at            |     body     
    -----------+----------+-------------------------------+--------------
     Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
     Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.

Great, exactly the data I wanted. And the `CASE` statement can actually be
indexed to speed up filtering. But I wondered if it would be possible to get the
same results without the `DISTINCT ON`. In other words, can this be done with
standard SQL? If you're using PostgreSQL 8.4, the answer is “yes.” All you have
to do is exploit [window functions] and a subquery. It looks like this:

``` postgres
SELECT sender, receiver, sent_at, body
  FROM (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER ( PARTITION BY 
               CASE WHEN receiver > sender
                    THEN receiver || sender
                    ELSE sender   || receiver
               END
               ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
  ) AS t
 WHERE rnum = 1;
```

Same nasty `CASE` statement as before (no way around it with this database
design, alas), but this is fully conforming SQL. It’s also the first time I've
ever used window functions. If you just focus on the `row_number() OVER ()`
expression, it’s simply partitioning the table according to the same value as in
the `DISTINCT ON` value, but it’s ordering it by `sent_at` directly. The result
is a row number, where the first is 1 for the most recent message for each
combination of recipients. Then we just filter for that in the `WHERE` clause.

Not exactly intuitive (I'm really only understanding it now as I explain write
it out), but quite straight-forward once you accept the expressivity in this
particular `OVER` expression. It might be easier to understand if we remove some
of the cruft. If instead we wanted the most recent message from each sender
(regardless of the recipient), we'd write:

``` postgres
SELECT sender, receiver, sent_at, body
  FROM (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER (
               PARTITION BY sender ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
  ) AS t
 WHERE rnum = 1;
```

And that yields:

      sender   | receiver |            sent_at            |     body     
    -----------+----------+-------------------------------+--------------
     Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
     Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.
     Theory    | Anna     | 2010-01-12 05:00:07.24982+00  | Brussels Sprouts.

Furthermore, we can use a [common table expression] to eliminate the subquery.
This query is functionally identical to the subquery example (returning to
uniqueness for sender and receiver), just with the `WITH` clause coming before
the `SELECT` clause, setting things up for it:

``` postgres
WITH t AS (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER (PARTITION BY CASE
               WHEN receiver > sender
                   THEN receiver || sender
                   ELSE sender   || receiver
                   END
               ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
) SELECT sender, receiver, sent_at, body
    FROM t
   WHERE rnum = 1;
```

So it’s kind of like putting the subquery first, only it’s not a subquery, it’s
more like a *temporary view*. Nice, eh? Either way, the results are the same as
before:

      sender   | receiver |            sent_at            |     body     
    -----------+----------+-------------------------------+--------------
     Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
     Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.

I hereby dub this “The Entity’s Something-est” pattern (I'm certain someone else
has already come up with a good name for it, but this will do). I can see it
working any place requiring the highest, lowest, latest, earliest, or something
else-est item from each of a list of entities. Perhaps the latest headline from
every news source:

``` postgres
WITH t AS (
    SELECT source, headline, dateline, row_number() OVER (
               PARTITION BY source ORDER BY dateline DESC
           ) AS rnum
      FROM news
) SELECT source, headline, dateline
    FROM t
   WHERE rnum = 1;
```

Or perhaps the lowest score for for each basketball team over the course of a
season:

``` postgres
WITH t AS (
    SELECT team, date, score, row_number() OVER (
               PARTITION BY team ORDER BY score
           ) AS rnum
      FROM games
) SELECT team, date, score
    FROM t
   WHERE rnum = 1;
```

Easy! How have you handled a situation like this in your database hacking?

  [colleagues]: http://www.pgexperts.com/people.html "PostgreSQL Experts"
  [Andrew]: http://people.planetpostgresql.org/andrew/
    "Andrew's PostgreSQL blog"
  [window functions]: http://www.postgresql.org/docs/current/static/tutorial-window.html
    "PostgreSQL Documentation: Window Functions"
  [common table expression]: http://www.postgresql.org/docs/current/static/queries-with.html
    "PostgreSQL Documentation: WITH Queries"
