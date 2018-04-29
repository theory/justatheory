--- 
date: 2013-10-25T14:36:00Z
title: Indexing Nested hstore
aliases: [/pg/2013/10/25/indexing-nested-hstore/]
tags: [Postgres, hstore]
categories: [Postgres]
---

In my first [Nested hstore] post yesterday, I ran a query against unindexed
hstore data, which required a table scan. But hstore is able to take
advantage of [GIN indexes]. So let's see what that looks like. Connecting to
the same database, I indexed the `review` column:

``` postgres
reviews=# CREATE INDEX idx_reviews_gin ON reviews USING GIN(review);
CREATE INDEX
Time: 360448.426 ms
reviews=# SELECT pg_size_pretty(pg_database_size(current_database()));
 pg_size_pretty 
----------------
 421 MB
```

Well, that takes a while, and makes the database a lot bigger (it was 277 MB
unindexed). But is it worth it? Let's find out. Oleg and Teodor's patch adds
support for a nested hstore value on the right-hand-side of the `@>`
operator. In practice, that means we can specify the full path to a nested
value as an hstore expression. In our case, to query only for Books, instead
of using this expression:

``` postgres
WHERE review #> '{product,group}' = 'Book'
```

We can use an hstore value with the entire path, including the value:

``` postgres
WHERE review @> '{product => {group => Book}}'
```

Awesome, right? Let's give it a try:

``` postgres
reviews=# SELECT
    width_bucket(length(review #> '{product,title}'), 1, 50, 5) title_length_bucket,
    round(avg(review #^> '{review,rating}'), 2) AS review_average,
    count(*)
FROM
    reviews
WHERE
    review @> '{product => {group => Book}}'
GROUP BY
    title_length_bucket
ORDER BY
    title_length_bucket;
 title_length_bucket | review_average | count  
---------------------+----------------+--------
                   1 |           4.42 |  56299
                   2 |           4.33 | 170774
                   3 |           4.45 | 104778
                   4 |           4.41 |  69719
                   5 |           4.36 |  47110
                   6 |           4.43 |  43070
(6 rows)

Time: 849.681 ms
```

That time looks better than yesterday's, but in truth I first ran this query
just before building the GIN index and got about the same result. Must be
that Mavericks is finished indexing my disk or something. At any rate, the
index is not buying us much here.

But hey, we're dealing with 1998 Amazon reviews, so querying against books
probably isn't very selective. I don't blame the planner for deciding that a
table scan is cheaper than an index scan. But what if we try a more selective
value, say "DVD"?

``` postgres
reviews=# SELECT
    width_bucket(length(review #> '{product,title}'), 1, 50, 5) title_length_bucket,
    round(avg(review #^> '{review,rating}'), 2) AS review_average,
    count(*)
FROM
    reviews
WHERE
    review @> '{product => {group => DVD}}'
GROUP BY
    title_length_bucket
ORDER BY
    title_length_bucket;
 title_length_bucket | review_average | count 
---------------------+----------------+-------
                   1 |           4.27 |  2646
                   2 |           4.44 |  4180
                   3 |           4.53 |  1996
                   4 |           4.38 |  2294
                   5 |           4.48 |   943
                   6 |           4.42 |   738
(6 rows)

Time: 73.913 ms
```

Wow! Under 100ms. That's more like it! [Inverted indexing] FTW!

[Nested hstore]: /pg/2013/10/23/testing-nested-hstore/
[GIN indexes]: http://www.postgresql.org/docs/current/static/gin.html
[Inverted indexing]: http://en.wikipedia.org/wiki/Inverted_index

