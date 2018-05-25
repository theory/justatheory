--- 
date: 2006-04-20T16:36:27Z
slug: sql-ordering-poll
title: What Name Do You Use for an Order Column?
aliases: [/computers/databases/ordering_poll.html]
tags: [Databases, SQL, Databases]
type: post
---

Quick poll.

Say that you have a join table mapping blog entries to tags, and you want the
tags to be ordered for each entry. The table might look something like this:

``` postgres
CREATE TABLE entry_join_tag (
    entry_id integer REFERENCES entry(id)
                    ON UPDATE CASCADE
                    ON DELETE CASCADE,
    tag_id   integer REFERENCES tag(id)
                    ON UPDATE CASCADE
                    ON DELETE CASCADE,
    ord       smallint,
    PRIMARY KEY (entry_id, tag_id)
);
```

It's the `ord` column I'm talking about here, wherein to order tags for each
blog entry, you'd do a select like this:

``` postgres
SELECT entry_id, tag_id
  FROM   entry_join_tag
 ORDER BY entry_id, ord;
```

So my question is this: What name do you typically give to the ordering column,
since “order” itself isn't available in SQL (it's a reserved word, of course).
Some of the options I can think of:

-   ord
-   ordr
-   seq
-   place
-   rank
-   tag\_ord
-   tag\_order
-   tag\_place
-   tag\_rank
-   tag\_seq

Leave a comment to let me know. Thanks!
