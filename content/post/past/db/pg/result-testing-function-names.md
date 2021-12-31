--- 
date: 2009-06-08T00:06:26Z
slug: pgtap-result-testing-function-names
title: Need Help Naming Result Set Testing Functions
aliases: [/computers/databases/postgresql/result-testing-function-names.html]
tags: [Postgres, SQL, pgTAP, Testing, Unit Testing]
type: post
---

I've been thinking more since I posted about [testing SQL result sets], and I
think I've settled on two sets of functions for pgTAP: one that tests two SQL
queries (though you will be encouraged to use a prepared statement), and one to
test two cursors. I'm thinking of naming them:

-   `query_gets()`
-   `cursor_gets()`

I had been planning on `*_returns()` or `*_yields()`, but they didn't feel
right. “Returns” implies that I would be passing a query and a data structure
(to me at least), and while I want to support that, too, it's not what I was
looking for right now. “Yield,” on the other hand, is more related to
set-returning functions in my mind (even if PL/pgSQL doesn't use that term).
Anyway, I like the use of “gets” because it's short and pretty unambiguous.

These function will compare query results as unordered sets, but I want variants
that test ordered sets, as well. I've been struggling to come up with a decent
name for these variants, but not liking any very well. The obvious ones are:

-   `ordered_query_gets()`
-   `ordered_cursor_gets()`

And:

-   `sorted_query_gets()`
-   `sorted_cursor_gets()`

But these are kind of long for functions that will be, I believe, used
frequently. I could just add a character to get the same idea, in the spirit of
`sprintf`:

-   `oquery_gets()`
-   `ocursor_gets()`

Or:

-   `squery_gets()`
-   `scursor_gets()`

I think that these are okay, but might be somewhat confusing. I think that the
“s” variant probably won't fly, since for `sprintf` and friends, the “s” stands
for “string.” So I'm leaning towards the “o” variants.

But I'm throwing it out there for the masses to make suggestions: Got any ideas
for better function names? Are there some relational terms for ordered sets, for
example, that might make more sense? What do you think?

As a side note, I'm also considering:

-   `col_is()` to compare the result of a single column query to an array or
    other query. This would need an ordered variant, as well.
-   `row_is()`, although I have no idea how I'd be able to support passing a row
    expression to a function, since PostgreSQL doesn't allow `RECORD`s to be
    passed to functions.

  [testing SQL result sets]: {{% ref "/post/past/db/pg/comparing-relations" %}}
    "Thoughts on Testing SQL Result Sets"
