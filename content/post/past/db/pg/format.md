--- 
date: 2012-11-16T01:31:00Z
slug: format
title: "New in PostgreSQL 9.2: format()"
aliases: [/computers/databases/postgresql/format.html]
tags: [Postgres, SQL]
type: post
---

There’s a new feature in PostgreSQL 9.2 that I don’t recall seeing blogged about
elsewhere: the `format()` function. From [the docs][]:

> Format a string. This function is similar to the C function sprintf; but only
> the following conversion specifications are recognized: %s interpolates the
> corresponding argument as a string; %I escapes its argument as an SQL
> identifier; %L escapes its argument as an SQL literal; %% outputs a literal %.
> A conversion can reference an explicit parameter position by preceding the
> conversion specifier with n$, where n is the argument position.

If you do a lot of dynamic query building in PL/pgSQL functions, you’ll
immediately see the value in `format()`. Consider this function:

    CREATE OR REPLACE FUNCTION make_month_partition(
        base_table   TEXT,
        schema_name  TEXT,
        month        TIMESTAMP
    ) RETURNS VOID LANGUAGE plpgsql AS $_$
    DECLARE
        partition TEXT := quote_ident(base_table || '_' || to_char(month, '"y"YYYY"m"MM'));
        month_start TIMESTAMP := date_trunc('month', month);
    BEGIN
        EXECUTE '
            CREATE TABLE ' || quote_ident(schema_name) || '.' || partition || ' (CHECK (
                   created_at >= ' || quote_literal(month_start) || '
               AND created_at < '  || quote_literal(month_start + '1 month'::interval) || '
            )) INHERITS (' || quote_ident(schema_name) || '.' || base_table || ')
        ';
        EXECUTE 'GRANT SELECT ON ' || quote_ident(schema_name) || '.' || partition || '  TO dude;';
    END;
    $_$;

Lots of concatenation and use of `quote_ident()` to get things just right. I
don’t know about you, but I always found this sort of thing quite difficult to
read. But `format()` allows use to eliminate most of the operators and function
calls. Check it:

    CREATE OR REPLACE FUNCTION make_month_partition(
        base_table   TEXT,
        schema_name  TEXT,
        month        TIMESTAMP
    ) RETURNS VOID LANGUAGE plpgsql AS $_$
    DECLARE
        partition TEXT := base_table || '_' || to_char(month, '"y"YYYY"m"MM');
        month_start TIMESTAMP := date_trunc('month', month);
    BEGIN
        EXECUTE format(
            'CREATE TABLE %I.%I (
                CHECK (created_at >= %L AND created_at < %L)
            ) INHERITS (%I.%I)',
            schema_name, partition,
            month_start, month_start + '1 month'::interval,
            schema_name, base_table
        );
        EXECUTE format('GRANT SELECT ON %I.%I TO dude', schema_name, partition);
    END;
    $_$;

I don’t know about you, but I find that a *lot* easier to read. which means
it’ll be easier to maintain. So if you do much dynamic query generation inside
the database, give `format()` a try, I think you’ll find it a winner.

***Update 2012-11-16:** Okay, so I somehow failed to notice that `format()` was
actually introduced in 9.1 and [covered by depesz]. D’oh! Well, hopefully my
little post will help to get the word out more, at least. Thanks to my
commenters.*

  [the docs]: http://www.postgresql.org/docs/current/static/functions-string.html
  [covered by depesz]: http://www.depesz.com/2010/11/21/waiting-for-9-1-format/
