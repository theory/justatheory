--- 
date: 2010-11-24T22:30:53Z
slug: postgres-fk-locks-project
title: Fixing Foreign Key Deadlocks in PostgreSQL
aliases: [/computers/databases/postgresql/fk-locks-project.html]
tags: [Postgres, SQL, Deadlocks, fossexperts, PostgreSQL Experts, commandprompt, Glue Finance, ActiveRecord]
type: post
---

[PGX] had [a client] come to us recently with a rather nasty deadlock issue. It
took far longer than we would have liked to figure out the issue, and once we
did, they were able to clear it up by dropping an unnecessary index. Still, it
shouldn’t have been happening to begin with. Joel Jacobson admirably [explained
the issue] on pgsql-hackers (and don’t miss [the screencast]).

Some might consider it a bug in PostgreSQL, but the truth is that PostgreSQL can
obtain stronger than necessary locks. Such locks cause some operations to block
unnecessarily and some other operations to deadlock, especially when foreign
keys are used in a busy database. And really, who doesn’t use FKs in their busy
database?

Fortunately, Simon Riggs [proposed a solution]. And it’s a good one. So good
that [PGX] is partnering with [Glue Finance][a client] and [Command Prompt] as
founding sponsors on a new [FOSSExperts project] to actually get it done.
[Álvaro Herrera] is doing the actual hacking on the project, and has already
blogged about it [here] and [here][1].

If you use foreign key constraints (and you should!) and you have a high
transaction load on your database (or expect to soon!), this matters to you. In
fact, if you use ActiveRecord with Rails, there might even be a special place in
your heart for this issue, [says Mina Naguib]. We’d *really* like to get this
done in time for the PostgreSQL 9.1 release. But it will only happen if the
project can be funded.

Yes, that’s right, as with [PGXN], this is community project for which we’re
raising funds from the community to get it done. I think that more and more work
could be done this way, as various interested parties contribute small amounts
to collectively fund improvements to the benefit of us all. So can you help out?
Hit the [FOSSExperts project page][FOSSExperts project] for all the project
details, and to [make your contribution].

Help us help the community to make PostgreSQL better than ever!

  [PGX]: http://pgexperts.com/
  [a client]: http://gluefinance.com/
  [explained the issue]: http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg157869.html
  [the screencast]: http://www.screencast.com/users/joeljacobson/folders/Jing/media/42c31028-80fa-45fe-b21f-9039110c3555
  [proposed a solution]: http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg158205.html
  [Command Prompt]: http://www.commandprompt.com/
  [FOSSExperts project]: https://www.fossexperts.com/content/foreign-key-locks
  [Álvaro Herrera]: http://www.commandprompt.com/blogs/alvaro_herrera/
  [here]: http://www.commandprompt.com/blogs/alvaro_herrera/2010/11/fixing_foreign_key_deadlocks/
  [1]: http://www.commandprompt.com/blogs/alvaro_herrera/2010/11/fixing_foreign_key_deadlocks_part_2/
  [says Mina Naguib]: http://mina.naguib.ca/blog/2010/11/22/postgresql-foreign-key-deadlocks.html
  [PGXN]: http://pgxn.org/
  [make your contribution]: https://www.fossexperts.com/content/foreign-key-locks-0
