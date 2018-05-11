--- 
date: 2006-09-15T22:50:27Z
slug: pgsql-batch-updates
title: Batch Updates with PL/pgSQL
aliases: [/computers/databases/postgresql/pgsql_batch_updates.html]
tags: [Postgres, PL/pgSQL]
---

<p>The third in my series of articles about PL/pgSQL, <q>Batch Updates with
PL/pgSQL</q> has been published on <a href="http://www.oreillynet.com/pub/a/databases/2006/09/07/plpgsql-batch-updates.html" title="Batch Updates with PL/pgSQL">The O'Reilly Network</a>. Actually it was published last week, but I've not been very attentive to my blog lately. Sorry about that. Anyway, it improves upon the code in the second article in the series, <q><a href="http://www.onlamp.com/pub/a/onlamp/2006/06/29/many-to-many-with-plpgsql.html" title="Managing Many-to-Many Relationships with PL/pgSQL">Managing Many-to-Many Relationships with PL/pgSQL</a>,</q> by modifying the updating functions to use PostgreSQL batch query syntax. This means that the number of database calls in a given call to a function are constant, no matter how many IDs are passed to it.</p>

<p>So <a href="http://www.oreillynet.com/pub/a/databases/2006/09/07/plpgsql-batch-updates.html" title="Batch Updates with PL/pgSQL">check it out</a>!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/postgresql/pgsql_batch_updates.html">old layout</a>.</small></p>


