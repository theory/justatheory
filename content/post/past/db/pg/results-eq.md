--- 
date: 2009-07-01T21:32:28Z
slug: pgtap-results-eq
title: "Committed: pgTAP Result Set Assertion Functions"
aliases: [/computers/databases/postgresql/results_eq.html]
tags: [Postgres, pgTAP, SQL, testing]
type: post
---

Regular readers will know that I've been thinking a lot about [testing SQL
result sets] and how to [how to name result testing functions], and various
[implementation issues]. I am very happy to say that I've now committed the
first three such test functions to the [Git repository]. They've been tested on
8.4 and 8.3. Here's what I came up with.

I had a pretty good idea how to compare sets and how to compare ordered bags,
but ordered sets and unordered bags of results escaped me. During two days of
intense hacking and experimentation, I quickly wrote `set_eq()`, which performs
a set comparison of the results of two queries, and `obag_eq()`, which performs
a row-by-row comparison of the results of two queries. I then set to work on
`bag_eq()`, which would do a set comparison but require the same number of
duplicate rows between the two queries. `set_eq()` was easy because I just
needed to create temporary tables of the two queries and then execute two
`EXCEPT` queries against them to see where they differ, if at all. `bag_eq()`
was getting kind of hairy, though, so I asked about it on the Freenode
\#postgresql channel, where [depesz] looked at my example and pointed out that
`EXCEPT ALL` would do just want I needed.

Hot damn, all it took was the addition a single extra word to the same queries
used by `set_eq()` and I was set. This made me very happy, and such
well-thought-out features are the reason I love PostgreSQL. My main man depesz
made my day.

But `oset_eq()`, which was to compare ordered sets of results was proving much
harder. The relational operators that operate on sets don't care about order, so
I would have to write the code to care myself. And because dupes needed to be
ignored, it got even harder. In fact, it proved just not worth the effort. The
main reason I abandoned this test function, though, was not difficulties of
implementation (which were significant), but ambiguity of interpretation. After
all, if duplicates are allowed but ignored, how does one deal with their effect
on order? For example, say that I have two queries that order people based on
name. One query might order them like so:

    select * from people order by name;
      name  | age 
    --------+-----
     Damian |  19
     Larry  |  53
     Tom    |  35
     Tom    |  44
     Tom    |  35

Another run of the same query could give me a different order:

    select * from people order by name;
      name  | age 
    --------+-----
     Damian |  19
     Larry  |  53
     Tom    |  35
     Tom    |  35
     Tom    |  44

Because I ordered only on “name,” the database was free to sort records with the
same name in an undefined way. Meaning that the rows could be in different
orders. This is known, if I understand correctly, as a “[Partially ordered
set],” or “poset.” Which is all well and good, but from my point of view makes
it damn near impossible to be able to do a row-by-row comparison and ignore
dupes, because they could be in different orders!

So once I gave up on that, I was down to three functions instead of four, and
only one depends on ordering. So I also dropped the idea of having the “o” in
the function names. Instead, I changed `obag_eq()` to `results_eq()`, and now I
think I have three much more descriptive names. To summarize, the functions are:

`results_eq`
:   Compares two result sets row by row, meaning that they must be in the same
    order and have the same number of duplicate rows in the same places.

`set_eq`
:   Compares result sets to ensure they have the same rows, without regard to
    order or duplicate rows.

`bag_eq`
:   Compares result sets without regard to order, but each must have the same
    duplicate rows.

I'm very happy with this, because I was able to give up on the stupid function
names with the word “order” included or implicit in them. Plus, I have different
names for functions that are similar, which is nicely in adherence to the
[principle of distinction]. They all provide nice diagnostics on failure, as
well, like this from `results_eq()`:

    # Failed test 146
    #     Results differ beginning at row 3:
    #         have: (1,Anna)
    #         want: (22,Betty)

Or this from `set_eq()` or `bag_eq()`

    # Failed test 146
    #     Extra records:
    #         (87,Jackson)
    #         (1,Jacob)
    #     Missing records:
    #         (44,Anna)
    #         (86,Angelina)

`set_eq()` and `bag_eq()` also offer up useful diagnostics when the data types
of the rows vary:

    # Failed test 147
    #     Columns differ between queries:
    #         have: (integer,text)
    #         want: (text,integer)

`results_eq()` doesn't have access to such data, though if I can find some tuits
(got any to give me?), I'll write a quick C function that can return an array of
the data types in a `record` object.

Now, as for the issue of arguments, what I settled on is, like [Epic], passing
strings of SQL to these functions. However, unlike Epic, if you pass in a simple
string with no spaces, or a double-quoted string, pgTAP assumes that it's the
name of a prepared statement. The documentation now recommends prepared
statements, which you can use like this:

``` postgres
PREPARE my_test AS SELECT * FROM active_users() WHERE name LIKE 'A%';
PREPARE expect AS SELECT * FROM users WHERE active = $1 AND name LIKE $2;
SELECT results_eq('my_test', 'expect');
```

This allows you to keep your SQL written as SQL, keeping your test, um, SQLish.
But in those cases where you have some really simple SQL, you can just use that,
too:

``` postgres
SELECT set_eq(
    'SELECT * FROM active_users()',
    'SELECT * FROM users ORDER BY id'
);
```

This feels like a good compromise to me, allowing the best of both worlds:
keeping things in pure SQL to avoid quoting ugliness in SQL strings, while
letting users pass in SQL strings if they really want to.

It turns out that I wasn't able to support cursors for `set_eq()` or `bag_eq()`,
because they use the statements passed to them to create temporary tables and
then compare the records in those temporary tables. But `results_eq()` uses
cursors internally. And it turns out that there's a data type for cursors,
`refcursor`. So it was easy to add cursor support to `results_eq()` for those
who want to use it:

``` postgres
DECLARE cwant CURSOR FOR SELECT * FROM active_users();
DECLARE chave CURSOR FOR SELECT * FROM users WHERE active ORDER BY name;
SELECT results_eq('cwant'::refcursor, 'chave'::refcursor );
```

Neat, huh? As I said, I'm very pleased with this approach overall. There are a
few caveats, such as less strict comparisons in `results_eq()` on 8.3 and lower,
and less useful diagnostics for data type differences in `results_eq()`, but
overall, I think that the implementation is pretty good, and that these
functions will be really useful.

So what do you think? Please clone the [Git repository] and take the functions
for a test drive on 8.3 or 8.4. Let me know what you think!

In the meantime, before releasing a new version, I still plan to add:

-   `set_includes()` - Set includes records in another set.
-   `set_excludes()` - Set excludes records in another set.
-   `bag_includes()` - Bag includes records in another bag.
-   `bag_excludes()` - Bag excludes records in another bag.
-   `col_eq()` - Single column result set equivalent to an array of values.
-   `row_eq()` - Single row form a query equivalent to a record.
-   `rowtype_is()` - The data type of the rows in a query is equivalent to an
    array of types.

Hopefully I can find some time to work on those next week. The only challenging
one is `row_eq()`, so I may skip that one for now.

  [testing SQL result sets]: /computers/databases/postgresql/comparing-relations.html
    "Thoughts on Testing SQL Result Sets"
  [how to name result testing functions]: /computers/databases/postgresql/result-testing-function-names.html
    "Need Help Naming Result Set Testing Functions"
  [implementation issues]: /computers/databases/postgresql/set_testing_update.html
    "pgTAP Set-Testing Update"
  [Git repository]: http://github.com/theory/pgtap/tree/master/
    "Get the pgTAP source on GitHub"
  [depesz]: http://www.depesz.com/ "select * from depesz"
  [Partially ordered set]: https://en.wikipedia.org/wiki/Partially_ordered_set
    "Wikipedia: Partially ordered set"
  [principle of distinction]: http://www.perl.com/pub/a/2003/06/25/perl6essentials.html
    "Perl 6 Design Philosophy"
  [Epic]: http://epictest.org/
    "Epic, more full of fail than any other testing tool"
