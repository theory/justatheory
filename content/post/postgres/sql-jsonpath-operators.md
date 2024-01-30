---
title: JSON Path Operator Confusion
slug: sql-jsonpath-operators
date: 2023-10-14T22:39:55Z
lastMod: 2023-10-14T22:39:55Z
description: |
  The relationship between the Postgres SQL/JSON Path operators `@@` and `@?`
  confused me. Here's how I figured out the difference.
tags: [Postgres, JSON Path, SQL/JSON Path, Operators, JSON, JSONB]
type: post
---

The [CipherDoc] service offers a robust [secondary key lookup API] and search
interface powered by [JSON/SQL Path] queries run against a [GIN-indexed] [JSONB]
column. SQL/JSON Path, introduced in [SQL:2016] and added to [Postgres] in
[version 12] in 2019, nicely enables an end-to-end [JSON] workflow and entity
lifecycle. It's a powerful enabler and fundamental technology underpinning
CipherDoc. I'm so happy to have found it.

Confusion
---------

However, the distinction between the SQL/JSON Path operators `@@` and `@?`
confused me. Even as I found that the `@?` operator worked for my needs and `@@`
did not, I tucked the problem into my mental backlog for later study.

The question arose again on a recent work project, and I can take a hint. It's
time to figure this thing out. Let's see where it goes.

[The docs] say:

> `jsonb @? jsonpath → boolean`
> :   Does JSON path return any item for the specified JSON value?
>
> `'{"a":[1,2,3,4,5]}'::jsonb @? '$.a[*] ? (@ > 2)' → t`
>
> ------
>
> `jsonb @@ jsonpath → boolean`
> :   Returns the result of a JSON path predicate check for the specified JSON
>     value. Only the first item of the result is taken into account. If the
>     result is not Boolean, then `NULL` is returned.
> 
> `'{"a":[1,2,3,4,5]}'::jsonb @@ '$.a[*] > 2' → t`

These read quite similarly to me: Both return true if the path query returns an
item. So what's the difference? When should I use `@@` and when `@?`? I went so
far as to [ask Stack Overflow] about it. The [one answer] directed my attention
back to the `jsonb_path_query()` function, which returns the *results* from a
path query.

So let's explore how various SQL/JSON Path queries work, what values various
expressions return.

Queries
-------

[The docs] for `jsonb_path_query` say:[^args]

> `jsonb_path_query ( target jsonb, path jsonpath [, vars jsonb [, silent boolean ]] ) → setof jsonb`
> :   Returns all JSON items returned by the JSON path for the specified JSON
>     value. If the `vars` argument is specified, it must be a JSON object, and
>     its fields provide named values to be substituted into the jsonpath
>     expression. If the `silent` argument is specified and is true, the
>     function suppresses the same errors as the `@?` and `@@` operators do.
> 
> :   ``` postgres
>     select * from jsonb_path_query(
>         '{"a":[1,2,3,4,5]}',
>         '$.a[*] ? (@ >= $min && @ <= $max)',
>         '{"min":2, "max":4}'
>     ) →
>      jsonb_path_query
>     ------------------
>      2
>      3
>      4
>     ```

The first thing to note is that a SQL/JSON Path query may return more than one
value. This feature matters for the `@@` and `@?` operators, which return a
single boolean value based on the values returned by a path query. And path queries
can return a huge variety of values. Let's explore some examples, derived from
the sample JSON value and path query from the docs.[^vars]

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$ ?(@.a[*] > 2)');
    jsonb_path_query    
------------------------
 {"a": [1, 2, 3, 4, 5]}
(1 row)
```

This query returns the entire JSON value, because that's what `$` selects at the
start of the path expression. The `?()` filter returns true because its
predicate expression finds at least one value in the `$.a` array greater than
`2`. Here's what happens when the filter returns false:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$ ?(@.a[*] > 5)');
 jsonb_path_query 
------------------
(0 rows)
```

None of the values in the `$.a` array are greater than five, so the query
returns no value.

To select just the array, append it to the path expression *after* the `?()`
filter:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$ ?(@.a[*] > 2).a');
 jsonb_path_query 
------------------
 [1, 2, 3, 4, 5]
(1 row)
```

### Path Modes

One might think you could select `$.a` at the start of the path query to get the
full array if the filter returns true, but look what happens:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$.a ?(@[*] > 2)');
 jsonb_path_query 
------------------
 3
 4
 5
(3 rows)
```

That's not the array, but the *individual array values that each match the
predicate.* Turns out this is a quirk of the Postgres implementation of [path
modes]. From what I can glean, the [SQL:2016] standard dictates something like
these [SQL Server descriptions][mssql-modes]:

> *   In **lax** mode, the function returns empty values if the path expression
>     contains an error. For example, if you request the value **$.name**, and the
>     JSON text doesn't contain a **name** key, the function returns null, but
>     does not raise an error.
> *   In **strict** mode, the function raises an error if the path expression
>     contains an error.

But the Postgres lax mode does more than suppress errors. From [the docs][path
modes] (emphasis added):

> The lax mode facilitates matching of a JSON document structure and path
> expression if the JSON data does not conform to the expected schema. If an
> operand does not match the requirements of a particular operation, it can be
> automatically wrapped as an SQL/JSON array or unwrapped by converting its
> elements into an SQL/JSON sequence before performing this operation.
> **Besides, comparison operators automatically unwrap their operands in the lax
> mode, so you can compare SQL/JSON arrays out-of-the-box.**

There are a few more details, but this is the crux of it: In lax mode, which is
the default, Postgres *always* unwraps an array. Hence the unexpected list of
results.[^oracle] This could be particularly confusing when querying multiple
rows:

``` postgres
select jsonb_path_query(v, '$.a ?(@[*] > 2)')
        from (values ('{"a":[1,2,3,4,5]}'::jsonb), ('{"a":[3,5,8]}')) x(v);
 jsonb_path_query 
------------------
 3
 4
 5
 3
 5
 8
(6 rows)
```

Switching to strict mode by preprending `strict` to the JSON Path query restores
the expected behavior:

``` postgres
select jsonb_path_query(v, 'strict $.a ?(@[*] > 2)')
        from (values ('{"a":[1,2,3,4,5]}'::jsonb), ('{"a":[3,5,8]}')) x(v);
 jsonb_path_query 
------------------
 [1, 2, 3, 4, 5]
 [3, 5, 8]
(2 rows)
```

Important gotcha to watch for, and a good reason to test path queries thoroughly
to ensure you get the results you expect. Lax mode nicely prevents errors when a
query references a path that doesn't exist, as this simple example demonstrates:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', 'strict $.b');
ERROR:  JSON object does not contain key "b"

select jsonb_path_query('{"a":[1,2,3,4,5]}', 'lax $.b');
 jsonb_path_query 
------------------
(0 rows)
```

In general, I suggest always using strict mode when executing queries. Better
still, perhaps always prefer strict mode with our friends the `@@` and `@?`
operators, which [suppress some errors even in strict mode][errnote]:

> The jsonpath operators `@?` and `@@` suppress the following errors: missing
> object field or array element, unexpected JSON item type, datetime and numeric
> errors. The `jsonpath`-related functions described below can also be told to
> suppress these types of errors. This behavior might be helpful when searching
> JSON document collections of varying structure.

Have a look:

``` postgres
select '{"a":[1,2,3,4,5]}' @? 'strict $.a';
 ?column? 
----------
 t
(1 row)

select '{"a":[1,2,3,4,5]}' @? 'strict $.b';
 ?column? 
----------
 <null>
(1 row)
```

No error for the unknown JSON key `b` in that second query! As for the error
suppression in the `jsonpath`-related functions, that's what the `silent`
argument does. Compare:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', 'strict $.b');
ERROR:  JSON object does not contain key "b"

select jsonb_path_query('{"a":[1,2,3,4,5]}', 'strict $.b', '{}', true);
 jsonb_path_query 
------------------
(0 rows)
```

### Boolean Predicates

The Postgres [SQL/JSON Path Language docs] briefly mention a pretty significant
deviation from the SQL standard:

> A path expression can be a Boolean predicate, although the SQL/JSON standard
> allows predicates only in filters. This is necessary for implementation of the
> `@@` operator. For example, the following `jsonpath` expression is valid in
> PostgreSQL:
>
> `$.track.segments[*].HR < 70`

This pithy statement has pretty significant implications for the return value
of a path query. The SQL standard allows predicate expressions, which are akin
to an SQL `WHERE` expression, only in `?()` filters, as seen previously:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$ ?(@.a[*] > 2)');
    jsonb_path_query    
------------------------
 {"a": [1, 2, 3, 4, 5]}
(1 row)
```

This can be read as "return the path `$` if `@.a[*] > 2` is true. But have a
look at a predicate-only path query:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}', '$.a[*] > 2');
 jsonb_path_query 
------------------
 true
(1 row)
```

This path query can be read as "Return the result of the predicate `$.a[*] > 2`,
which in this case is `true`. This is quite the divergence from the standard,
which returns *contents* from the JSON queried, while a predicate query returns
the result of the predicate expression itself. It's almost like they're two
different things!

Don't confuse the predicate path query return value with selecting a boolean
value from the JSON. Consider this example:

``` postgres
select jsonb_path_query('{"a":[true,false]}', '$.a ?(@[*] == true)');
 jsonb_path_query 
------------------
 true
(1 row)
```

Looks the same as the predicate-only query, right? But it's not, as shown by
adding another `true` value to the `$.a` array:

``` postgres
select jsonb_path_query('{"a":[true,false,true]}', '$.a ?(@[*] == true)');
 jsonb_path_query 
------------------
 true
 true
(2 rows)
```

This path query returns the `true`s it finds in the `$.a` array. The fact that
it returns values from the JSON rather than the filter predicate becomes more
apparent in strict mode, which returns all of `$a` if one or more elements of
the array has the value `true`:

``` postgres
select jsonb_path_query('{"a":[true,false,true]}', 'strict $.a ?(@[*] == true)');
  jsonb_path_query   
---------------------
 [true, false, true]
(1 row)
```

This brief aside, and its mention of the `@@` operator, turns out to be key to
understanding the difference between `@?` and `@@`. Because it's not just that
this feature is "necessary for implementation of the `@@` operator". No, I would
argue that it's **the only kind of expression usable with the `@@` operator**

Match vs. Exists
----------------

Let's get back to the `@@` operator. We can use a boolean predicate JSON Path
like so:

``` postgres
select '{"a":[1,2,3,4,5]}'::jsonb @@ '$.a[*] > 2';
 ?column? 
----------
 t
(1 row)
```

It returns true because the predicate JSON path query `$.a[*] > 2` returns true.
And when it returns false?

``` postgres
select '{"a":[1,2,3,4,5]}'::jsonb @@ '$.a[*] > 6';
 ?column? 
----------
 f
(1 row)
```

So far so good. What happens when we try to use a filter expression that returns
a `true` value selected from the JSONB?

``` postgres
select '{"a":[true,false]}'::jsonb @@ '$.a ?(@[*] == true)';
 ?column? 
----------
 t
(1 row)
```

Looks right, doesn't it? But recall that this query returns all of the
`true` values from `$.@`, but `@@` wants only a single boolean. What happens
when we add another?

``` postgres
select '{"a":[true,false,true]}'::jsonb @@ 'strict $.a ?(@[*] == true)';
 ?column? 
----------
 <null>
(1 row)
```

Now it returns `NULL`, even though it's clearly true that `@[*] == true`
matches. This is because it returns *all* of the values it matches, as
`jsonb_path_query()` demonstrates:

``` postgres
select jsonb_path_query('{"a":[true,false,true]}'::jsonb, '$.a ?(@[*] == true)');
 jsonb_path_query 
------------------
 true
 true
(2 rows)
```

This clearly violates the `@@` documentation claim that "Only the first item of
the result is taken into account". If that were true, it would see the first
value is `true` and return true. But it doesn't. Turns out, the corresponding
`jsonb_path_match()` function shows why:

``` postgres
select jsonb_path_match('{"a":[true,false,true]}'::jsonb, '$.a ?(@[*] == true)');
ERROR:  single boolean result is expected
```

Conclusion: The documentation is inaccurate. Only a single boolean is expected
by `@@`. Anything else is an error.

Futhermore, it's dangerous, at best, to use an SQL standard JSON Path expression
with `@@`. If you need to use it with a filter expression, you can turn it into
a boolean predicate by wrapping it in `exists()`:

``` postgres
select jsonb_path_match('{"a":[true,false,true]}'::jsonb, 'exists($.a ?(@[*] == true))');
 jsonb_path_match 
------------------
 t
(1 row)
```

But there's no reason to do so, because that's effectively what the `@?`
operator (and the corresponding, cleverly-named `jsonb_path_exists()` function
does): it returns true if the SQL standard JSON Path expression contains any
results:

``` postgres
select '{"a":[true,false,true]}'::jsonb @? '$.a ?(@[*] == true)';
 ?column? 
----------
 t
(1 row)
```

Here's the key thing about `@?`: you don't want to use a boolean predicate path
query with it, either. Consider this predicate-only query:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}'::jsonb, '$.a[*] > 6');
 jsonb_path_query 
------------------
 false
(1 row)
```

But see what happens when we use it with `@?`:

``` postgres
select '{"a":[1,2,3,4,5]}'::jsonb @? '$.a[*] > 6';
 ?column? 
----------
 t
(1 row)
```

It returns true even though the query itself returns false! Why? Because `false`
is a value that exists and is returned by the query. Even a query that returns
`null` is considered to exist, as it will when a strict query encounters an
error:

``` postgres
select jsonb_path_query('{"a":[1,2,3,4,5]}'::jsonb, 'strict $[*] > 6');
 jsonb_path_query 
------------------
 null
(1 row)

select '{"a":[1,2,3,4,5]}'::jsonb @? 'strict $[*] > 6';
 ?column? 
----------
 t
(1 row)
```

The key thing to know about the `@?` operator is that it returns true if
*anything* is returned by the path query, and returns false only if nothing is
selected at all.

The Difference
--------------

In summary, the difference between the `@?` and `@@` JSONB operators is this:

*   `@?` (and `jsonb_path_exists()`) returns true if the path query returns any
    values --- even `false` or `null` --- and false if it returns no values.
    This operator should be used *only* with SQL-standard JSON path queries that
    select data from the JSONB. Do not use predicate-only JSON path expressions
    with `@?`.
*   `@@` (and `jsonb_path_match()`) returns true if the path query returns the
    single boolean value `true` and false otherwise. This operator should be
    used *only* with Postgres-specific boolean predicate JSON path queries,
    that return data from the predicate expression. Do not use SQL-standard JSON
    path expressions with `@@`.

This difference of course assumes awareness of this distinction between
predicate path queries and SQL standard path queries. To that end, I [submitted
a patch] that expounds the difference between these types of JSON Path
queries, and plan to submit another linking these differences in the docs for
`@@` and `@?`.

Oh, and probably another to explain the difference in return values between
strict and lax queries due to array unwrapping.

Thanks
------

Many thanks to [Erik Wienhold] for patiently answering my [pgsql-hackers
questions] and linking me to a detailed [pgsql-general thread] in which the
oddities of `@@` were previously discussed in detail.

  [^args]: Well almost. The docs for `jsonb_path_query` actually say, about the
    last two arguments, "The optional `vars` and `silent` arguments act the same
    as for `jsonb_path_exists`." I replaced that sentence with the relevant
    sentences from the `jsonb_path_exists` docs, about which more later.

  [^vars]: Though omitting the `vars` argument, as variable interpolation just
    gets in the way of understanding basic query result behavior.

  [^oracle]: In fairness, the [Oracle docs] also discuss "implicit array
    wrapping and unwrapping", but I don't have a recent Oracle server to
    experiment with at the moment.

  [CipherDoc]: {{% ref "/post/postgres/cipherdoc" %}}
    "CipherDoc: A Searchable, Encrypted JSON Document Service on Postgres"
  [secondary key lookup API]: {{% ref "/post/tech/rfc-restful-secondary-key-api.md" %}}
  [JSON/SQL Path]: https://www.postgresql.org/docs/12/datatype-json.html#DATATYPE-JSONPATH
    "PostgreSQL Docs: jsonpath Type"
  [GIN-indexed]: https://www.postgresql.org/docs/current/gin.html
    "PostgreSQL Docs: GIN Indexes"
  [JSONB]: https://www.postgresql.org/docs/current/datatype-json.html
    "PostgresSQL Docs: JSON Types"
  [SQL:2016]: https://en.wikipedia.org/wiki/SQL:2016 "Wikipedia: “SQL:2016”"
  [Postgres]: https://www.postgresql.org/
    "PostgreSQL: The World's Most Advanced Open Source Relational Database"
  [version 12]: https://www.postgresql.org/docs/12/release-12.html
    "PostgreSQL Docs: Release 12 Release Notes"
  [JSON]: https://json.org "ECMA-404 The JSON Data Interchange Standard"
  [ask Stack Overflow]: https://stackoverflow.com/q/77046554/79202
    "Stack Overflow: What's the difference between the PostgreSQL @? and @@ JSONB Operators?"
  [one answer]: https://stackoverflow.com/a/77046858/79202
  [the docs]: https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSON-PROCESSING-TABLE
    "PostgresSQL Docs: JSON Functions and Operators"
  [path modes]: https://www.postgresql.org/docs/current/functions-json.html#STRICT-AND-LAX-MODES
    "PostgresSQL Docs: Strict and Lax modes"
  [mssql-modes]: https://learn.microsoft.com/en-us/sql/relational-databases/json/json-path-expressions-sql-server?view=sql-server-ver16#PATHMODE
    "JSON Path Expressions (SQL Server): Path mode"
  [Oracle docs]: https://docs.oracle.com/en/database/oracle/oracle-database/21/adjsn/json-path-expressions.html#GUID-8656CAB9-C293-4A99-BB62-F38F3CFC4C13
    "Oracle Database JSON Developer’s Guide: SQL/JSON Path Expression Syntax Relaxation"
  [errnote]: https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-JSONB-OP-TABLE
    "PostgreSQL Docs: Additional jsonb Operators"
  [SQL/JSON Path Language docs]: https://www.postgresql.org/docs/current/functions-json.html#FUNCTIONS-SQLJSON-PATH
  [submitted a patch]: https://www.postgresql.org/message-id/7262A188-59CA-4A8A-AAD7-83D4FF0B9758%40justatheory.com
    "pgsql-hackers — Patch: Improve Boolean Predicate JSON Path Docs"
  [Erik Wienhold]: https://github.com/ewie "GitHub: Erik Wienhold"
  [pgsql-hackers questions]: https://www.postgresql.org/message-id/flat/15DD78A5-B5C4-4332-ACFE-55723259C07F%40justatheory.com
    "pgsql-hackers — JSON Path and GIN Questions"
  [pgsql-general thread]: https://www.postgresql.org/message-id/flat/CACJufxE01sxgvtG4QEvRZPzs_roggsZeVvBSGpjM5tzE5hMCLA%40mail.gmail.com
    "pgsql-general — ​jsonb @@ jsonpath operator doc: ​Only the first item of the result is taken into account"
