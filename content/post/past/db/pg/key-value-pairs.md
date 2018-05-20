--- 
date: 2010-08-09T13:00:00Z
slug: key-value-pairs
title: Managing Key/Value Pairs in PostgreSQL
aliases: [/computers/databases/postgresql/key-value-pairs.html]
tags: [Postgres, nosql, SQL]
type: post
---

Let's say that you've been following the [latest research] in key/value data
storage and are interested in managing such data in a PostgreSQL database. You
want to have functions to store and retrieve pairs, but there is no natural way
to represent pairs in SQL. Many languages have hashes or or data dictionaries to
fulfill this role, and you can pass them to functional interfaces. SQL's got
nothin’. In PostgreSQL, have two options: use nested arrays (simple, fast) or
use a custom composite data type (sugary, legible).

Let's assume you have this table for storing your pairs:

    CREATE TEMPORARY TABLE kvstore (
        key        TEXT PRIMARY KEY,
        value      TEXT,
        expires_at TIMESTAMPTZ DEFAULT NOW() + '12 hours'::interval
    );

To store pairs, you can use nested arrays like so:

    SELECT store(ARRAY[ ['foo', 'bar'], ['baz', 'yow'] ]);

Not too bad, and since SQL arrays are a core feature of PostgreSQL, there's
nothing special to do. Here's the `store()` function:

    CREATE OR REPLACE FUNCTION store(
        params text[][]
    ) RETURNS VOID LANGUAGE plpgsql AS $$
    BEGIN
        FOR i IN 1 .. array_upper(params, 1) LOOP
            UPDATE kvstore
               SET value      = params[i][2],
                   expires_at = NOW() + '12 hours'::interval
             WHERE key        = param[i][1];
            CONTINUE WHEN FOUND;
            INSERT INTO kvstore (key, value)
            VALUES (params[i][1], params[i][2]);
        END LOOP;
    END;
    $$;

I've seen worse. The trick is to iterate over each nested array, try an update
for each, and insert when no row is updated. Alas, you have no control over how
many elements a user might include in a nested array. One might call it as:

    SELECT store(ARRAY[ ['foo', 'bar', 'baz'] ]);

Or:

    SELECT store(ARRAY[ ['foo'] ]);

No errors will be thrown in either case. In the first the "baz" will be ignored,
and in the second the value will default to `NULL`. If you really didn't like
these behaviors, you could add some code to throw an exception if
`array_upper(params, 2)` returns anything other than 2.

Let's look at fetching values for keys. PostgreSQL 8.4 added variadic function
arguments, so it's easy to provide a nice interface for retrieving one or more
values. The obvious one fetches a single value:

    CREATE OR REPLACE FUNCTION getval(
        text
    ) RETURNS TEXT LANGUAGE SQL AS $$
        SELECT value FROM kvstore WHERE key = $1;
    $$;

Nice and simple:

    SELECT getval('baz');

     getval 
    --------'
     yow

The variadic version looks like this:

    CREATE OR REPLACE FUNCTION getvals(
        variadic text[]
    ) RETURNS SETOF text LANGUAGE SQL AS $$
        SELECT value
          FROM kvstore
          JOIN (SELECT generate_subscripts($1, 1)) AS f(i)
            ON kvstore.key = $1[i]
         ORDER BY i;
    $$;

Note the use of `ORDER BY i` to ensure that the values are returned in the same
order as the keys are passed to the function. So if I've got the key/value pairs
`'foo' => 'bar'` and `'baz' => 'yow'`, the output is:

    SELECT * FROM getvals('foo', 'baz');

     getvals 
    ---------
     bar
     yow

If we want to the rows to have the keys and values together, we can return them
as arrays, like so:

    CREATE OR REPLACE FUNCTION getpairs(
        variadic text[]
    ) RETURNS SETOF text[] LANGUAGE SQL AS $$
        SELECT ARRAY[key, value]
          FROM kvstore
          JOIN unnest($1) AS k ON kvstore.key = k
    $$;

Here I'm assuming that order isn't important, which means we can use [`unnest`]
to "flatten" the array, instead of the slightly more baroque
[`generate_subscripts()`] with array access. The output:

    SELECT * FROM getpairs('foo', 'baz');

      getpairs   
    -------------
     {baz,yow}
     {foo,bar}

Now, this is good as far as it goes, but the use of nested arrays to represent
key/value pairs is not exactly ideal: just looking at the use of a function,
there's nothing to indicate that you're using key/value pairs. What *would* be
ideal is to use [row constructors] to pass arbitrary pairs:

    SELECT store( ROW('foo', 'bar'), ROW('baz', 42) );

Alas, one cannot pass `RECORD` values (the data type returned by `ROW()`) to
non-C functions in PostgreSQL.[^key-value-hackers] But if you don't mind your
keys and values always being `TEXT`, we can get almost all the way there by
creating an "ordered pair" data type as a [composite type] like so:

    CREATE TYPE pair AS ( k text, v text );

Then we can create `store()` with a signature of `VARIADIC pair[]` and pass in
any number of these suckers:

    CREATE OR REPLACE FUNCTION store(
        params variadic pair[]
    ) RETURNS VOID LANGUAGE plpgsql AS $$
    DECLARE
        param pair;
    BEGIN
        FOR param IN SELECT * FROM unnest(params) LOOP
            UPDATE kvstore
               SET value = param.v,
                   expires_at = NOW() + '12 hours'::interval
             WHERE key = param.k;
            CONTINUE WHEN FOUND;
            INSERT INTO kvstore (key, value) VALUES (param.k, param.v);
        END LOOP;
    END;
    $$;

Isn't it nice how we can access keys and values as `param.k` and `param.v`? Call
the function like this:

    SELECT store( ROW('foo', 'bar')::pair, ROW('baz', 'yow')::pair );

Of course, that can get a bit old, casting to `pair` all the time, so let's
create some `pair` constructor functions to simplify things:

    CREATE OR REPLACE FUNCTION pair(anyelement, text)
    RETURNS pair LANGUAGE SQL AS 'SELECT ROW($1, $2)::pair';

    CREATE OR REPLACE FUNCTION pair(text, anyelement)
    RETURNS pair LANGUAGE SQL AS 'SELECT ROW($1, $2)::pair';

    CREATE OR REPLACE FUNCTION pair(anyelement, anyelement)
    RETURNS pair LANGUAGE SQL AS 'SELECT ROW($1, $2)::pair';

    CREATE OR REPLACE FUNCTION pair(text, text)
    RETURNS pair LANGUAGE SQL AS 'SELECT ROW($1, $2)::pair;';

I've created four variants here to allow for the most common combinations of
types. So any of the following will work:

    SELECT pair('foo', 'bar');
    SELECT pair('foo', 1);
    SELECT pair(12.3, 'foo');
    SELECT pair(1, 43);

Alas, you can't mix any other types, so this will fail:

    SELECT pair(1, 12.3);

    ERROR:  function pair(integer, numeric) does not exist
    LINE 1: SELECT pair(1, 12.3);

We could create a whole slew of additional constructors, but since we're using a
key/value store, it's likely that the keys will usually be text anyway. So now
we can call `store()` like so:

    SELECT store( pair('foo', 'bar'), pair('baz', 'yow') );

Better, eh? Hell, we can go all the way and create a nice binary operator to
make it still more sugary. Just map each of the `pair` functions to the operator
like so:

    CREATE OPERATOR -> (
        LEFTARG   = text,
        RIGHTARG  = anyelement,
        PROCEDURE = pair
    );

    CREATE OPERATOR -> (
        LEFTARG   = anyelement,
        RIGHTARG  = text,
        PROCEDURE = pair
    );

    CREATE OPERATOR -> (
        LEFTARG   = anyelement,
        RIGHTARG  = anyelement,
        PROCEDURE = pair
    );

    CREATE OPERATOR -> (
        LEFTARG   = text,
        RIGHTARG  = text,
        PROCEDURE = pair
    );

Looks like a lot of repetition, I know, but checkout the new syntax:

    SELECT store( 'foo' -> 'bar', 'baz' -> 1 );

Cute, eh? I chose to use `->` because `=>` is deprecated as an operator in
PostgreSQL 9.0: SQL 2011 reserves that operator for named parameter
assignment.[^key-value-params]

As a last twist, let's rewrite `getpairs()` to return `pair`s instead of arrays:

    CREATE OR REPLACE FUNCTION getpairs(
        variadic text[]
    ) RETURNS SETOF pair LANGUAGE SQL AS $$
        SELECT key -> value
          FROM kvstore
          JOIN unnest($1) AS k ON kvstore.key = k
    $$;

Cute, eh? Its use is just like before, only now the output is more table-like:

    SELECT * FROM getpairs('foo', 'baz');

      k  |   v   
    -----+-------
     baz | yow
     foo | bar

You can also get them back as composites by omitting `* FROM`:

    SELECT getpairs('foo', 'baz');

      getpairs   
    -------------
     (foo,bar)
     (baz,yow)

Anyway, just something to consider the next time you need a function that allows
any number of key/value pairs to be passed. It's not perfect, but it's pretty
sweet.

  [^key-value-hackers]: In the [recent pgsql-hackers discussion] that inspired
    this post, Pavel Stehule suggested adding something like [Oracle `COLLECTIONs`]
    to address this shortcoming. I don't know how far this idea will get, but
    it sure would be nice to be able to pass objects with varying kinds of
    data, rather than be limited to data all of one type (values in an SQL
    array must all be of the same type).

  [^key-value-params]: No, you won't be able to use named parameters for this
    application because named parameters are inherently non-variadic. That is,
    you can only pre-declare so many named parameters: you can't anticipate
    every parameter that's likely to be wanted as a key in our key/value store.

  [latest research]: http://it.toolbox.com/blogs/database-soup/runningwithscissorsdb-39879
    "RunningWithScissorsDB"
  [`unnest`]: http://www.postgresql.org/docs/current/static/functions-array.html
    "PostgreSQL Documentation: Array Functions and Operators"
  [`generate_subscripts()`]: http://www.postgresql.org/docs/current/static/functions-srf.html#FUNCTIONS-SRF-SUBSCRIPTS
    "PostgreSQL Documentation: Set Returning Functions"
  [row constructors]: http://www.postgresql.org/docs/current/static/sql-expressions.html#SQL-SYNTAX-ROW-CONSTRUCTORS
    "PostgreSQL Documentation: Row Constructors"
  [composite type]: http://www.postgresql.org/docs/current/static/sql-createtype.html
    "PostgreSQL Documentation: CREATE TYPE"
  [recent pgsql-hackers discussion]: http://archives.postgresql.org/pgsql-hackers/2010-08/msg00520.php
  [Oracle `COLLECTIONs`]: http://download.oracle.com/docs/cd/B19306_01/appdev.102/b14261/collections.htm