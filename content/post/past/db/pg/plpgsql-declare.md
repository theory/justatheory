--- 
date: 2006-04-14T17:49:15Z
slug: plpgsql-declare
title: Use Variables in PL/pgSQL DECLARE Blocks
aliases: [/computers/databases/postgresql/plpgsql_declare.html]
tags: [Postgres, PL/pgSQL]
type: post
---

I'm working on some [PL/pgSQL] functions for my application framework and for an
upcoming article for the [O'Reilly Databases site], and was showing some of the
code to a PostgreSQL guru. The code looked something like this:

``` plpgsql
CREATE OR REPLACE FUNCTION update_table (
    key_name text,
    pk_id    integer,
    fk_ids   integer[]

) RETURNS VOID AS $$
DECLARE
    table_name text := quote_ident(key_name);
BEGIN
    EXECUTE 'UPDATE ' || table_name || ' SET pk = ' || pk_id
            || ' WHERE fk IN(' || array_to_string(fk_ids, ', ')
            || ')';
END;
$$ LANGUAGE plpgsql;
```

No, that's not the real code, it's just a dummy example to illustrate something.
Illustrate what? Well, my PostgreSQL friend said, “Crap, can you really use
variables to set other variables in the `DECLARE` section?” The answer is “yes,”
of course. The above does work. I'm new to PostgreSQL functions, so I didn't
know any better than to just try it, and it worked. But my friend has been
writing PL/pgSQL functions for years. Why didn't he know that you could use
variables in a `DECLARE` block? As he said, “Damn, one of the problems with
starting with a language 6 years ago is that you get in the habit of coding
around the restrictions from 6 years ago.”

Anyway, I just wanted to share this tidbit, in case there were other PostgreSQL
pros who missed it. I don't know when the feature was added, but it works fine
for me in 8.1.

  [PL/pgSQL]: http://www.postgresql.org/docs/current/interactive/plpgsql.html
    "Read the PL/pgSQL Docs"
  [O'Reilly Databases site]: http://www.oreillynet.com/databases/
    "O'Reilly Databases"
