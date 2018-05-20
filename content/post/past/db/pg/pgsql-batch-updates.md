--- 
date: 2006-09-15T22:50:27Z
slug: pgsql-batch-updates
title: Batch Updates with PL/pgSQL
aliases: [/computers/databases/postgresql/pgsql_batch_updates.html]
tags: [Postgres, PL/pgSQL]
type: post
---

The third in my series of articles about PL/pgSQL, “Batch Updates with PL/pgSQL”
has been published on [The O'Reilly Network]. Actually it was published last
week, but I've not been very attentive to my blog lately. Sorry about that.
Anyway, it improves upon the code in the second article in the series,
“[Managing Many-to-Many Relationships with PL/pgSQL],” by modifying the updating
functions to use PostgreSQL batch query syntax. This means that the number of
database calls in a given call to a function are constant, no matter how many
IDs are passed to it.

So [check it out][The O'Reilly Network]!

  [The O'Reilly Network]: http://www.oreillynet.com/pub/a/databases/2006/09/07/plpgsql-batch-updates.html
    "Batch Updates with PL/pgSQL"
  [Managing Many-to-Many Relationships with PL/pgSQL]: http://www.onlamp.com/pub/a/onlamp/2006/06/29/many-to-many-with-plpgsql.html
    "Managing Many-to-Many Relationships with PL/pgSQL"
