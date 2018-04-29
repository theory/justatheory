--- 
date: 2013-09-29T14:50:00Z
link: http://www.openscg.com/2013/09/the-power-of-enums/
title: The Power of Enums
aliases: [/pg/2013/09/29/the-power-of-enums/]
tags: [Postgres, Jim Mlodgenski, enums]
categories: [Postgres]
---

Jim Mlodgenski on using [Enums] in place of references to small lookup tables:

> I saw something else I didn’t expect: […] There was a 8% increase
> in performance. I was expecting the test with the enums to be close
> to the baseline, but I wasn’t expecting it to be faster. Thinking
> about it, it makes sense. Enums values are just numbers so we’re
> effectively using surrogate keys under the covers, but the users would
> still the the enum labels when they are looking at the data. It ended
> up being a no brainer to use enums for these static tables. There was
> a increase in performance while still maintaining the integrity of the
> data.

I've been a big fan of Enums since Andrew and Tom Dunstan released a patch for
them during the PostgreSQL 8.2 era. Today they're a core feature, and as of
9.1, you can even modify their values! You're missing out if you're not using
them yet.

[Enums]: http://www.postgresql.org/docs/9.3/static/datatype-enum.html
