--- 
date: 2010-01-12T06:12:02Z
slug: somethingest-from-each-entity
title: "SQL Hack: The Something-est From Each Entity"
aliases: [/computers/databases/postgresql/somethingest-from-each-entity.html]
tags: [Postgres, SQL, window functions, common table expressions]
type: post
---

<p>This is a pattern that I have dealt with many times, but never figured out how to adequately handle. Say that you have imported a mailbox into your database, and you want a list of the latest messages between each pair of recipients (sender and receiver — I'm ignoring multiple receivers for the moment). The data might look like this:</p>

<pre>
BEGIN;

CREATE TABLE messages (
   sender   TEXT        NOT NULL,
   receiver TEXT        NOT NULL,
   sent_at  TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),
   body     TEXT        NOT NULL DEFAULT &#x27;&#x27;
);

INSERT INTO messages ( sender, receiver, body )
VALUES (&#x27;Theory&#x27;, &#x27;Strongrrl&#x27;, &#x27;Hi There.&#x27; );

INSERT INTO messages ( sender, receiver, body )
VALUES (&#x27;Strongrrl&#x27;, &#x27;Theory&#x27;, &#x27;Hi yourself.&#x27; );

INSERT INTO messages ( sender, receiver, body )
VALUES (&#x27;Anna&#x27;, &#x27;Theory&#x27;, &#x27;What&#x27;&#x27;s for dinner?&#x27; );

INSERT INTO messages ( sender, receiver, body )
VALUES (&#x27;Theory&#x27;, &#x27;Anna&#x27;, &#x27;Brussels Sprouts.&#x27; );

INSERT INTO messages ( sender, receiver, body )
VALUES (&#x27;Anna&#x27;, &#x27;Theory&#x27;, &#x27;Oh man!&#x27; );

COMMIT;
</pre>

<p>So the goal is to show the most recent message between Theory and Strongrrl and the most recent message between Theory and Anna, without regard to who is the sender and who is the receiver. After running into this many times, today I consulted my <a href="http://www.pgexperts.com/people.html" title="PostgreSQL Experts">colleagues</a>, showing them this dead simple (and wrong!) query to demonstrate what I wanted:</p>

<pre>
SELECT sender, recipient, sent_at, body
  FROM messages
 GROUP BY sender, recipient
HAVING sent_at = max(sent_at);
</pre>

<p>That’s wrong because one can’t have columns in the <code>SELECT</code> expression that are not either aggregate expressions or included in the<code>GROUP BY</code> expression. It’s a violation of the standard (and prone to errors, I suspect). <a href="http://people.planetpostgresql.org/andrew/" title="Andrew's PostgreSQL blog">Andrew</a> immediately said, “Classic case for <code>DISTINCT ON</code>”. This lovely little expression is a PostgreSQL extension not included in the SQL standard. It’s implementation looks like this:</p>

<pre>
SELECT DISTINCT ON (
          CASE WHEN receiver &gt; sender
              THEN receiver || sender
              ELSE sender   || receiver
          END
       ) sender, receiver, sent_at, body
  FROM messages
 ORDER BY CASE WHEN receiver &gt; sender
              THEN receiver || sender
              ELSE sender   || receiver
          END, sent_at DESC;
</pre>

<p>This query is saying, “fetch the rows where the sender and the receiver are distinct, and order by <code>sent_at DESC</code>. THE <code>CASE</code> statement to get a uniform value for the combination of sender and receiver is a bit unfortunate, but it does the trick:</p>

<pre>
  sender   | receiver |            sent_at            |     body     
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
 Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.
</pre>

<p>Great, exactly the data I wanted. And the <code>CASE</code> statement can actually be indexed to speed up filtering. But I wondered if it would be possible to get the same results without the <code>DISTINCT ON</code>. In other words, can this be done with standard SQL? If you're using PostgreSQL 8.4, the answer is “yes.” All you have to do is exploit <a href="http://www.postgresql.org/docs/current/static/tutorial-window.html" title="PostgreSQL Documentation: Window Functions">window functions</a> and a subquery. It looks like this:</p>

<pre>
SELECT sender, receiver, sent_at, body
  FROM (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER ( PARTITION BY 
               CASE WHEN receiver &gt; sender
                   THEN receiver || sender
                   ELSE sender   || receiver
               END
               ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
  ) AS t
 WHERE rnum = 1;
</pre>

<p>Same nasty <code>CASE</code> statement as before (no way around it with this database design, alas), but this is fully conforming SQL. It’s also the first time I've ever used window functions. If you just focus on the <code>row_number() OVER ()</code> expression, it’s simply partitioning the table according to the same value as in the <code>DISTINCT ON</code> value, but it’s ordering it by <code>sent_at</code> directly. The result is a row number, where the first is 1 for the most recent message for each combination of recipients. Then we just filter for that in the <code>WHERE</code> clause.</p>

<p>Not exactly intuitive (I'm really only understanding it now as I explain write it out), but quite straight-forward once you accept the expressivity in this particular <code>OVER</code> expression. It might be easier to understand if we remove some of the cruft. If instead we wanted the most recent message from each sender (regardless of the recipient), we'd write:</p>

<pre>
SELECT sender, receiver, sent_at, body
  FROM (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER (
               PARTITION BY sender ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
  ) AS t
 WHERE rnum = 1;
</pre>

<p>And that yields:</p>

<pre>
  sender   | receiver |            sent_at            |     body     
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
 Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.
 Theory    | Anna     | 2010-01-12 05:00:07.24982+00  | Brussels Sprouts.
</pre>

<p>Furthermore, we can use a <a href="http://www.postgresql.org/docs/current/static/queries-with.html" title="PostgreSQL Documentation: WITH Queries">common table expression</a> to eliminate the subquery. This query is functionally identical to the subquery example (returning to uniqueness for sender and receiver), just with the <code>WITH</code> clause coming before the <code>SELECT</code> clause, setting things up for it:</p>

<pre>
WITH t AS (
    SELECT sender, receiver, sent_at, body,
           row_number() OVER (PARTITION BY CASE
               WHEN receiver &gt; sender
                   THEN receiver || sender
                   ELSE sender   || receiver
                   END
               ORDER BY sent_at DESC
           ) AS rnum
      FROM messages
) SELECT sender, receiver, sent_at, body
    FROM t
   WHERE rnum = 1;
</pre>

<p>So it’s kind of like putting the subquery first, only it’s not a subquery, it’s more like a <em>temporary view</em>. Nice, eh? Either way, the results are the same as before:</p>

<pre>
  sender   | receiver |            sent_at            |     body     
&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;+&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;&#x2d;
 Anna      | Theory   | 2010-01-12 05:00:07.026711+00 | Oh man!
 Strongrrl | Theory   | 2010-01-12 05:00:07.02589+00  | Hi yourself.
</pre>

<p>I hereby dub this “The Entity’s Something-est” pattern (I'm certain someone else has already come up with a good name for it, but this will do). I can see it working any place requiring the highest, lowest, latest, earliest, or something else-est item from each of a list of entities. Perhaps the latest headline from every news source:</p>

<pre>
WITH t AS (
    SELECT source, headline, dateline, row_number() OVER (
               PARTITION BY source ORDER BY dateline DESC
           ) AS rnum
      FROM news
) SELECT source, headline, dateline
    FROM t
   WHERE rnum = 1;
</pre>

<p>Or perhaps the lowest score for for each basketball team over the course of a season:</p>

<pre>
WITH t AS (
    SELECT team, date, score, row_number() OVER (
               PARTITION BY team ORDER BY score
           ) AS rnum
      FROM games
) SELECT team, date, score
    FROM t
   WHERE rnum = 1;
</pre>

<p>Easy! How have you handled a situation like this in your database hacking?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/somethingest-from-each-entity.html">old layout</a>.</small></p>


