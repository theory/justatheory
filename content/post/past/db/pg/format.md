--- 
date: 2012-11-16T01:31:00Z
slug: format
title: "New in PostgreSQL 9.2: format()"
aliases: [/computers/databases/postgresql/format.html]
tags: [Postgres, SQL]
type: post
---

<p>There’s a new feature in PostgreSQL 9.2 that I don’t recall seeing blogged about elsewhere: the <code>format()</code> function. From <a href="http://www.postgresql.org/docs/current/static/functions-string.html">the docs</a>:</p>

<blockquote><p>Format a string. This function is similar to the C function sprintf; but only the following conversion specifications are recognized: %s interpolates the corresponding argument as a string; %I escapes its argument as an SQL identifier; %L escapes its argument as an SQL literal; %% outputs a literal %. A conversion can reference an explicit parameter position by preceding the conversion specifier with n$, where n is the argument position.</p></blockquote>

<p>If you do a lot of dynamic query building in PL/pgSQL functions, you’ll immediately see the value in <code>format()</code>. Consider this function:</p>

<pre><code>CREATE OR REPLACE FUNCTION make_month_partition(
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
               created_at &gt;= ' || quote_literal(month_start) || '
           AND created_at &lt; '  || quote_literal(month_start + '1 month'::interval) || '
        )) INHERITS (' || quote_ident(schema_name) || '.' || base_table || ')
    ';
    EXECUTE 'GRANT SELECT ON ' || quote_ident(schema_name) || '.' || partition || '  TO dude;';
END;
$_$;
</code></pre>

<p>Lots of concatenation and use of <code>quote_ident()</code> to get things just right. I don’t know about you, but I always found this sort of thing quite difficult to read. But <code>format()</code> allows use to eliminate most of the operators and function calls. Check it:</p>

<pre><code>CREATE OR REPLACE FUNCTION make_month_partition(
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
            CHECK (created_at &gt;= %L AND created_at &lt; %L)
        ) INHERITS (%I.%I)',
        schema_name, partition,
        month_start, month_start + '1 month'::interval,
        schema_name, base_table
    );
    EXECUTE format('GRANT SELECT ON %I.%I TO dude', schema_name, partition);
END;
$_$;
</code></pre>

<p>I don’t know about you, but I find that a <em>lot</em> easier to read. which means it’ll be easier to maintain. So if you do much dynamic query generation inside the database, give <code>format()</code> a try, I think you’ll find it a winner.</p>

<p><em><strong>Update 2012-11-16:</strong> Okay, so I somehow failed to notice that <code>format()</code> was actually introduced in 9.1 and <a href="http://www.depesz.com/2010/11/21/waiting-for-9-1-format/">covered by depesz</a>. D’oh! Well, hopefully my little post will help to get the word out more, at least. Thanks to my commenters.</em></p>
