--- 
date: 2009-07-31T00:47:10Z
slug: test-your-results
title: "pgTAP 0.22: Test Your Results"
aliases: [/computers/databases/postgresql/test-your-results.html]
tags: [Postgres, pgTAP, testing, unit testing]
type: post
---

I'm pleased to announce that, [after][] [much][] [thinking], [committing], and
not an insignificant amount of [hair-pulling], [pgTAP] 0.22 has finally landed.
Download it [here]. Many, *many* thanks to all who commented on my previous
posts, made suggestions, and helped me on IRC to figure out how to get all this
stuff to work. The crazy thing is that it does, quite well, all the way back to
PostgreSQL 8.0.

So here's what I've come up with: ten simple functions. Sound like a lot? Well,
it's simpler than it might at first appear. Here's a quick overview:

`results_eq()`

:   Compares two queries row-for-row. Pass in strings with SQL queries, strings
    with prepared statement names, or cursors. If the query you're testing
    returns a single column, the expected results can be passed as an array. If
    a test fails, you get useful diagnostics:

        # Failed test 146
        #     Results differ beginning at row 3:
        #         have: (1,Anna)
        #         want: (22,Betty)
            

    If a row is missing, the diagnostics will show it as a `NULL`:

        # Failed test 147
        #     Results differ beginning at row 5:
        #         have: (1,Anna)
        #         want: NULL
            

`results_ne()`

:   Just like `results_eq()`, except that it tests that the results of the two
    arguments are \*not\* equivalent. May not be very useful, but it's cute.

`set_eq()`

:   Tests that two queries return the same results, without regard to the order
    of the results or duplicates. Pass in strings with SQL queries or strings
    with prepared statement names. As with `results_eq()` the expected results
    can be passed as an array if the test query returns a single column. Failure
    diagnostics look like this:

        # Failed test 146
        #     Extra records:
        #         (87,Jackson)
        #         (1,Jacob)
        #     Missing records:
        #         (44,Anna)
        #         (86,Angelina)
            

    If the failure is due to incompatible column types, the diagnostics will
    help you out there, too:

        # Failed test 147
        #     Columns differ between queries:
        #         have: (integer,text)
        #         want: (text,integer)
            

`set_ne()`

:   The inverse of `set_eq()`, the test passes if the results of the two queries
    are different, without regard to order or duplicate rows. No diagnostics on
    failure, though; if it fails, it's because the results are the same.

`set_has()`

:   Tests that a query contains a subset of results without regard to order or
    duplicates. Useful if you need to ensure that a query returns at least some
    set of rows. Failure diagnostics are useful again:

        # Failed test 122
        #     Missing records:
        #         (44,Anna)
        #         (86,Angelina)
            

`set_hasnt()`

:   Tests that a query does not contain a subset of results, without regard to
    order or duplicates.

`bag_eq()`

:   Just like `set_eq()`, except that duplicates matter. So if the first query
    has duplicate rows, the second must have the same dupes. Diagnostics are
    equally useful.

`bag_ne()`

:   Just like `set_ne()`, except that duplicates matter.

`bag_has()`

:   Just like `set_has()`, except that duplicates matter.

`bag_hasnt()`

:   Just like `set_hasnt()`, except that duplicates matter.

Be sure to look at my [previous post] for usage examples. Since I wrote it, I've
also added the ability to pass an array as the second argument to these
functions. This is specifically for the case when the query you're testing
results a single column of results; the array just makes it easier to specify
expected values in a common case:

    SELECT results_eq(
        'SELECT * FROM active_user_ids()',
        ARRAY[ 2, 3, 4, 5]
    );

Check the [documentation] for all the details on how to use these functions.

I'm really happy with these functions. It was definitely worth it to really
[think things through], look at [prior art][after], and spend the time to try
different approaches. In the process, I've found an approach that works in
nearly all circumstances.

The one exception is in `results_eq()` and `results_ne()` on PostgreSQL 8.3 and
down. The issue there is that there were no operators to compare two `record`
objects before PostgreSQL 8.4. So for earlier versions, the code has to cast the
`record`s representing each row to text. This means that two rows can be
different but appear to be the same to 8.3 and down. In practice this should be
pretty rare, but I'm glad that record comparisons are more correct in 8.4

The only other issue is performance. Although you can write your tests in SQL,
rather than strings containing SQL, the set and bag functions use the PL/pgSQL
`EXECUTE` statement to execute each SQL statement and insert it into a temporary
table. Then they select the data from the temporary tables once or twice to do
the comparisons. That's a lot more processing than simply running the query
itself, and it slows down the performance significantly.

Similarly, the results functions use cursors and fetch each row one-at-a-time.
The nice thing is that, in the event of a failure for `results_eq()` or a pass
for `results_ne()`, the functions can stop fetching results before reaching the
end of the queries. But either way, a fair bit of processing goes on.

I'm not sure which is slower, the set and bag functions or the results
functions, but, short of adding new syntax to SQL (not an option), I could see
no other way to adequately do the comparisons and emit useful diagnostics.

But those are minor caveats, I think. I'm pretty pleased with the function names
and the interfaces I've created for them. Please [download] the latest and let
me know what you think.

So what's next? Well, there are a few more schema-testing functions I'd like to
add, but after that, I'd like to declare pgTAP stable and start using it in new
projects. I'm thinking about writing a test suite for [database normalization],
starting with testing that all tables [have primary keys].

But that's after my vacation. Back in two weeks.

  [after]: /computers/databases/postgresql/comparing-relations.html
    "Thoughts on Testing SQL Result Sets"
  [much]: /computers/databases/postgresql/result-testing-function-names.html
    "Need Help Naming Result Set Testing Functions"
  [thinking]: /computers/databases/postgresql/set_testing_update.html
    "pgTAP Set-Testing Update"
  [committing]: /computers/databases/postgresql/results_eq.html
    "Committed: pgTAP Result Set Assertion Functions"
  [hair-pulling]: /computers/databases/postgresql/neither-null-nor-not-null.html
    "Neither NULL nor NOT NULL: An SQL
    WTF"
  [pgTAP]: http://pgtap.projects.postgresql.org/
    "pgTAP: Unit Testing for PostgreSQL"
  [here]: http://pgfoundry.org/frs/?group_id=1000389 "Download pgTAP"
  [previous post]: /computers/databases/postgresql/results_eq.html "Committed:
    pgTAP Result Set Assertion Functions"
  [documentation]: http://pgtap.projects.postgresql.org/documentation.html#Pursuing+Your+Query
    "pgTAP Documentation: Pursing Your Query"
  [think things through]: /computers/databases/postgresql/set_testing_update.html
    "pgTAP
    Set-Testing Update"
  [download]: http://pgfoundry.org/frs/?group_id=1000389 "Download
    pgTAP"
  [database normalization]: http://it.toolbox.com/blogs/database-soup/testing-for-normalization-33119
    "Database Soup: “Testing for Normalization”"
  [have primary keys]: http://petereisentraut.blogspot.com/2009/07/how-to-find-all-tables-without-primary.html
    "Peter Eisentraut's Brain Dump: “How to find all tables without primary
    key”"
