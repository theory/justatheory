--- 
date: 2006-04-14T17:49:15Z
slug: plpgsql-declare
title: Use Variables in PL/pgSQL DECLARE Blocks
aliases: [/computers/databases/postgresql/plpgsql_declare.html]
tags: [Postgres, PL/pgSQL]
type: post
---

<p>I'm working on some <a href="http://www.postgresql.org/docs/current/interactive/plpgsql.html" title="Read the PL/pgSQL Docs">PL/pgSQL</a> functions for my application framework and for an upcoming article for the <a href="http://www.oreillynet.com/databases/" title="O'Reilly Databases">O'Reilly Databases site</a>, and was showing some of the code to a PostgreSQL guru. The code looked something like this:</p>

<pre>
CREATE OR REPLACE FUNCTION update_table (
    key_name text,
    pk_id    integer,
    fk_ids   integer[]

) RETURNS VOID AS $$
DECLARE
    table_name text := quote_ident(key_name);
BEGIN
    EXECUTE &#x0027;UPDATE &#x0027; || table_name || &#x0027; SET pk = &#x0027; || pk_id
         || &#x0027; WHERE fk IN(&#x0027; || array_to_string(fk_ids, &#x0027;, &#x0027;)
         || &#x0027;)&#x0027;;
END;
$$ LANGUAGE plpgsql;
</pre>

<p>No, that's not the real code, it's just a dummy example to illustrate something. Illustrate what? Well, my PostgreSQL friend said, <q>Crap, can you really use variables to set other variables in the <code>DECLARE</code> section?</q> The answer is <q>yes,</q> of course. The above does work. I'm new to PostgreSQL functions, so I didn't know any better than to just try it, and it worked. But my friend has been writing PL/pgSQL functions for years. Why didn't he know that you could use variables in a <code>DECLARE</code> block? As he said, <q>Damn, one of the problems with starting with a language 6 years ago is that you get in the habit of coding around the restrictions from 6 years ago.</q></p>

<p>Anyway, I just wanted to share this tidbit, in case there were other PostgreSQL pros who missed it. I don't know when the feature was added, but it works fine for me in 8.1.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/plpgsql_declare.html">old layout</a>.</small></p>


