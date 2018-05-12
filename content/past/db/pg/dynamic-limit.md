--- 
date: 2009-01-31T07:01:40Z
slug: dynamic-limit
title: Dynamic OFFSETs and LIMITs
aliases: [/computers/databases/postgresql/dynamic-limit.html]
tags: [Postgres, SQL, PL/pgSQL]
type: post
---

<p>I discovered a great hack for dealing with optional offsets and limits in PostgreSQL functions while working for a client, and I wanted to get it down here so that I wouldn't forget it.</p>

<p>The deal is that I was writing tests for functions that returned a set of IDs for objects based on some criterion plus an optional offset and limit. The functions looked something like this:</p>

<pre>
CREATE OR REPLACE FUNCTION get_widgets_for_user_id(
    a_user_id integer,
    a_offset  integer,
    a_limit   integer
) RETURNS SETOF integer AS $$ 
DECLARE  
    l_id    integer;
    l_query text;
BEGIN
    v_query := &#x0027;SELECT id FROM widgets WHERE user_id = &#x0027; || a_user_id
            || &#x0027; ORDER BY created_at DESC&#x0027;;
    IF a_offset IS NOT NULL THEN 
        l_query := l_query || &#x0027; OFFSET &#x0027; || a_offset; 
    END IF; 
    IF a_limit IS NOT NULL THEN 
        l_query := l_query || &#x0027; LIMIT &#x0027; || a_limit; 
    END IF; 

    FOR l_id IN EXECUTE l_query LOOP 
          RETURN NEXT l_id;
    END LOOP; 
     
    RETURN; 
END;
$$ LANGUAGE PLPGSQL;
</pre>

<p>It seemed silly to me that this should be in PL/pgSQL: ultimately, it's such a simple query that I wanted it to be a SQL query. Of course I knew that if <code>a_offset</code> was <code>NULL</code> I could fallback on 0. But what about dealing with a <code>NULL</code> limit?</p>

<p>Well, it turns out that you can pass a <code>CASE</code> statement to the <code>LIMIT</code> clause that optionally returns no value at all and it will just work. Observe:</p>

<pre>
try=% select id from widgets LIMIT CASE WHEN false THEN 3 END;
 id
----
   1
   2
   3
   4
(4 rows)
</pre>

<p>Pretty weird, huh? Well, for my purposes, it's perfect, because I was able to rewrite that function as a pure SQL function, and it's a lot simpler, to boot:</p>

<pre>
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
</pre>

<p>Now isn't that a hell of a lot easier to read? Like I said, it's a little weird, but overall I think it's a pretty good hack. I've tested it with PostgreSQL 8.2 and 8.3. Not sure about other versions, but give it a try!</p>

<p><strong>Update:</strong> Thanks for the comments! With the insight that <code>CASE</code> is ultimately passing a <code>NULL</code> to <code>LIMIT</code> when the value is <code>NULL</code>, I realized that I could switch from <code>CASE</code> to <code>COALESCE</code> for nice parity with the handling of the <code>OFFSET</code> clause. Check it out:</p>

<pre>
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
</pre>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/dynamic-limit.html">old layout</a>.</small></p>


