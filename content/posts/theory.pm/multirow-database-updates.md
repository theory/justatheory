--- 
date: 2013-09-09T17:47:00Z
link: http://techblog.net-a-porter.com/2013/08/dbixmultirow-updating-multiple-database-rows-quickly-and-easily/
title: Multirow Database Updates
url: /sql/2013/09/09/multirow-database-updates/
tags: [sql, William Blunn, PostgreSQL, SQLite, Oracle, MySQL]
---

William Blunn:

> So, given a list of updates to apply we could effect them using the
> following steps:
>
> 1. Use CREATE TEMPORARY TABLE to create a temporary table to hold the
>    updates
> 2. Use INSERT to populate the temporary table with the updates
> 3. Use UPDATE … FROM to update the target table using updates in the
>    temporary table
> 4. Use DROP TABLE to drop the temporary table
>
> So in the example above we can reduce five statements to four. This isn’t a
> significant improvement in this case. But now the number of statements is no
> longer directly dependent on the number of rows requiring updates.
>
> **Even if we wanted to update a thousand rows with different values, we
> could still do it with four statements.**

Or you could just use one statement. Here's how to do it with a [CTE] on
PostgreSQL 9.2 and higher:

``` postgres
WITH up(name, salary) AS ( VALUES
     ('Jane',  1200),
     ('Frank', 1100),
     ('Susan', 1175),
     ('John',  1150)
)
UPDATE staff
   SET salary = up.salary
  FROM up
 WHERE staff.name = up.name;
```

Still on PostgreSQL 9.1 or lower? Use a subselect in the `FROM` clause
instead:

``` postgres
UPDATE staff
   SET salary = up.salary
   FROM (VALUES
       ('Jane',  1200),
       ('Frank', 1100),
       ('Susan', 1175),
       ('John',  1150)
   ) AS up(name, salary)
 WHERE staff.name = up.name;
```

Stuck with MySQL or Oracle? Use a `UNION` query in a second table:

``` postgres
UPDATE staff, (
         SELECT 'Jane' AS name, 1200 AS salary
   UNION SELECT 'Frank',        1100
   UNION SELECT 'Susan',        1175
   UNION SELECT 'John',         1150
) AS up
   SET staff.salary = up.salary
 WHERE staff.name = up.name;
```

Using SQLite? Might make sense to use a temporary table for thousands or
millions of rows. But for just a few, use a `CASE` expression:

``` postgres
UPDATE staff
   SET salary = CASE name
       WHEN 'Jane'  THEN 1200
       WHEN 'Frank' THEN 1100
       WHEN 'Susan' THEN 1175
       WHEN 'John'  THEN 1150
   END
 WHERE name in ('Jane', 'Frank', 'Susan', 'John');
```

If you need to support multiple database architectures, sure, use something
like [DBIx::MultiRow] to encapsulate things. But if, like most of us, you're
on one database for an app, I can't recommend stongly enough how well it pays
to get to know your database well.

[CTE]: http://www.postgresql.org/docs/current/static/queries-with.html "PostgreSQL Documentation: WITH Queries (Common Table Expressions)"
[DBIx::MultiRow]: https://github.com/hochgurgler/DBIx-MultiRow "DBIx::MultiRow on GitHub"
