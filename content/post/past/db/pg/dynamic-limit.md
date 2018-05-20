--- 
date: 2009-01-31T07:01:40Z
slug: dynamic-limit
title: Dynamic OFFSETs and LIMITs
aliases: [/computers/databases/postgresql/dynamic-limit.html]
tags: [Postgres, SQL, PL/pgSQL]
type: post
---

I discovered a great hack for dealing with optional offsets and limits in
PostgreSQL functions while working for a client, and I wanted to get it down
here so that I wouldn't forget it.

The deal is that I was writing tests for functions that returned a set of IDs
for objects based on some criterion plus an optional offset and limit. The
functions looked something like this:

    CREATE OR REPLACE FUNCTION get_widgets_for_user_id(
        a_user_id integer,
        a_offset  integer,
        a_limit   integer
    ) RETURNS SETOF integer AS $$ 
    DECLARE  
        l_id    integer;
        l_query text;
    BEGIN
        v_query := 'SELECT id FROM widgets WHERE user_id = ' || a_user_id
                || ' ORDER BY created_at DESC';
        IF a_offset IS NOT NULL THEN 
            l_query := l_query || ' OFFSET ' || a_offset; 
        END IF; 
        IF a_limit IS NOT NULL THEN 
            l_query := l_query || ' LIMIT ' || a_limit; 
        END IF; 

        FOR l_id IN EXECUTE l_query LOOP 
              RETURN NEXT l_id;
        END LOOP; 
         
        RETURN; 
    END;
    $$ LANGUAGE PLPGSQL;

It seemed silly to me that this should be in PL/pgSQL: ultimately, it's such a
simple query that I wanted it to be a SQL query. Of course I knew that if
`a_offset` was `NULL` I could fallback on 0. But what about dealing with a
`NULL` limit?

Well, it turns out that you can pass a `CASE` statement to the `LIMIT` clause
that optionally returns no value at all and it will just work. Observe:

    try=% select id from widgets LIMIT CASE WHEN false THEN 3 END;
     id
    ----
       1
       2
       3
       4
    (4 rows)

Pretty weird, huh? Well, for my purposes, it's perfect, because I was able to
rewrite that function as a pure SQL function, and it's a lot simpler, to boot:

    CREATE OR REPLACE FUNCTION get_widgets_for_user_id(
        a_user_id integer,
        a_offset  integer,
        a_limit   integer
    ) RETURNS SETOF integer AS $$ 
        SELECT id
          FROM widgets
         WHERE user_id = $1
         ORDER BY created_at DESC
        OFFSET COALESCE( $2, 0 )
         LIMIT CASE WHEN $3 IS NOT NULL THEN $3 END
    $$ LANGUAGE SQL;

Now isn't that a hell of a lot easier to read? Like I said, it's a little weird,
but overall I think it's a pretty good hack. I've tested it with PostgreSQL 8.2
and 8.3. Not sure about other versions, but give it a try!

**Update:** Thanks for the comments! With the insight that `CASE` is ultimately
passing a `NULL` to `LIMIT` when the value is `NULL`, I realized that I could
switch from `CASE` to `COALESCE` for nice parity with the handling of the
`OFFSET` clause. Check it out:

    CREATE OR REPLACE FUNCTION get_widgets_for_user_id(
        a_user_id integer,
        a_offset  integer,
        a_limit   integer
    ) RETURNS SETOF integer AS $$ 
        SELECT id
          FROM widgets
         WHERE user_id = $1
         ORDER BY created_at DESC
        OFFSET COALESCE( $2, 0 )
         LIMIT COALESCE( $3, NULL )
    $$ LANGUAGE SQL;
