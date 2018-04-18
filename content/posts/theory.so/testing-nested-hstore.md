--- 
date: 2013-10-23T10:26:00Z
title: Testing Nested hstore
url: /pg/2013/10/23/testing-nested-hstore/

categories: [pg]
---

I've been helping Oleg Bartunov and Teodor Sigaev with documentation for the
forthcoming [nested hstore] patch for [PostgreSQL]. It adds support for
arrays, numeric and boolean types, and of course arbitrarily nested data
structures. This gives it feature parity with [JSON], but unlike the
[JSON type], its values are stored in a binary representation, which makes it
much more efficient to query. The support for [GiST] and [GIN] indexes to
speed up path searches doesn't hurt, either.

As part of the documentation, we wanted to include a short tutorial, something
to show off the schemaless flexibility of the new hstore. The [CitusDB] guys
were kind enough to show off their [json_fdw] with some Amazon review data in
a [blog post] a few months back; it even includes an interesting query against
the data. Let's see what we can do with it. First, load it:

``` bash Load Amazon Reviews as hstore
> createdb reviews
> psql -d reviews -c '
    CREATE EXTENSION HSTORE;
    CREATE TABLE reviews(review hstore);
'
CREATE TABLE
> gzcat customer_reviews_nested_1998.json.gz | sed -e 's/\\/\\\\/g' \
 | sed -e "s/'/''/g" | sed -e 's/":/" =>/g' > /tmp/hstore.copy
> time psql -d reviews -c "COPY reviews FROM '/tmp/hstore.copy'"
COPY 589859
       0.00s user 0.00s system 0% cpu 13.059 total
```

13 seconds to load 589,859 records from a file -- a little over 45k records
per second. Not bad. Let's see what the storage looks like:

``` bash How Big is the hstore Data?
> psql -d reviews -c 'SELECT pg_size_pretty(pg_database_size(current_database()));'
 pg_size_pretty 
----------------
 277 MB
```

The original, uncompressed data is 208 MB on disk, so roughly a third bigger
given the overhead of the database. Just for fun, let's compare it to JSON:

``` bash Load Amazon Reviews as JSON
> createdb reviews_js
> psql -d reviews_js -c 'CREATE TABLE reviews(review json);'
CREATE TABLE
> gzcat customer_reviews_nested_1998.json.gz | sed -e 's/\\/\\\\/g' \
 | sed -e "s/'/''/g" | > /tmp/json.copy
> time psql -d reviews_js -c "COPY reviews FROM '/tmp/json.copy'"
COPY 589859
       0.00s user 0.00s system 0% cpu 7.434 total
> psql -d reviews_js -c 'SELECT pg_size_pretty(pg_database_size(current_database()));'
 pg_size_pretty 
----------------
 239 MB
```

Almost 80K records per second, faster, I'm guessing, because the JSON type
doesn't convert the data to binary representation its way in. JSON currently
uses less overhead for storage, aw well; I wonder if that's the benefit of
[TOAST storage]?

Let's try querying these guys. I adapted the query from the CitusDB [blog
post] and ran it on my 2013 MacBook Air (1.7 GHz Intel Core i7) with iTunes
and a bunch of other apps running in the background [yeah, I'm lazy]). Check
out those operators, by the way! Given a path, `#^>` returns a numeric value:

``` sql Query the hstore-encoded reviews
reviews=# SELECT
    width_bucket(length(review #> '{product,title}'), 1, 50, 5) title_length_bucket,
    round(avg(review #^> '{review,rating}'), 2) AS review_average,
    count(*)
FROM
    reviews
WHERE
    review #> '{product,group}' = 'Book'
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

Time: 2301.620 ms
```

The benefit of the native type is pretty apparent here. I ran this query
several times, and the time was always between 2.3 and 2.4 seconds. The Citus
[json_fdw] query took "about 6 seconds on a 3.1 GHz CPU core." Let's see how
well the JSON type does (pity there is no operator to fetch a value as
numeric; we have to cast from text):

``` sql Query the JSON-encoded reviews
reviews_js=# SELECT
    width_bucket(length(review #>> '{product,title}'), 1, 50, 5) title_length_bucket,
    round(avg((review #>> '{review,rating}')::numeric), 2) AS review_average,
    count(*)
FROM
    reviews
WHERE
    review #>> '{product,group}' = 'Book'
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

Time: 5530.120 ms
```

A little faster than the [json_fdw] version, but comparable. But takes well
over twice as long as the hstore version, though. For queries, hstore is the
clear winner. Yes, you pay up-front for loading and storage, but the payoff at
query time is substantial. Ideally, of course, we would have the insert and
storage benefits of JSON *and* the query performance of hstore. There was talk
last spring at PGCon of using the same representation for JSON and hstore;
perhaps that can still come about.

Meanwhile, I expect to play with some other data sets over the next week;
watch this spot for more!

[nested hstore]: http://www.sai.msu.su/~megera/postgres/talks/hstore-pgcon-2013.pdf
[PostgreSQL]: http://www.posrgresql.org/
[JSON]: http://json.org/
[JSON type]: http://www.postgresql.org/docs/current/static/datatype-json.html
[GiST]: http://www.postgresql.org/docs/current/static/gist.html
[GIN]: http://www.postgresql.org/docs/current/static/gin.html
[CitusDB]: http://citusdata.com/
[json_fdw]: https://github.com/citusdata/json_fdw
[blog post]: http://citusdata.com/blog/65-run-sql-on-json-files-without-any-data-loads
[TOAST storage]: http://www.postgresql.org/docs/current/static/storage-toast.html

