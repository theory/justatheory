--- 
date: 2010-11-24T22:30:53Z
slug: fk-locks-project
title: Fixing Foreign Key Deadlocks in PostgreSQL
aliases: [/computers/databases/postgresql/fk-locks-project.html]
tags: [Postgres, SQL, Deadlocks, fossexperts, PostgreSQL Experts, commandprompt, Glue Finance, ActiveRecord]
---

<p><a href="http://pgexperts.com/">PGX</a> had <a href="http://gluefinance.com/">a client</a> come to us recently with a rather nasty deadlock issue. It took far longer than we would have liked to figure out the issue, and once we did, they were able to clear it up by dropping an unnecessary index. Still, it shouldn’t have been happening to begin with. Joel Jacobson admirably <a href="http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg157869.html">explained the issue</a> on pgsql-hackers (and don’t miss <a href="http://www.screencast.com/users/joeljacobson/folders/Jing/media/42c31028-80fa-45fe-b21f-9039110c3555">the screencast</a>).</p>

<p>Some might consider it a bug in PostgreSQL, but the truth is that PostgreSQL can obtain stronger than necessary locks. Such locks cause some operations to block unnecessarily and some other operations to deadlock, especially when foreign keys are used in a busy database. And really, who doesn’t use FKs in their busy database?</p>

<p>Fortunately, Simon Riggs <a href="http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg158205.html">proposed a solution</a>. And it’s a good one. So good that <a href="http://pgexperts.com/">PGX</a> is partnering with <a href="http://gluefinance.com/">Glue Finance</a> and <a href="http://www.commandprompt.com/">Command Prompt</a> as founding sponsors on a new <a href="https://www.fossexperts.com/content/foreign-key-locks">FOSSExperts project</a> to actually get it done. <a href="http://www.commandprompt.com/blogs/alvaro_herrera/">Álvaro Herrera</a> is doing the actual hacking on the project, and has already blogged about it <a href="http://www.commandprompt.com/blogs/alvaro_herrera/2010/11/fixing_foreign_key_deadlocks/">here</a> and <a href="http://www.commandprompt.com/blogs/alvaro_herrera/2010/11/fixing_foreign_key_deadlocks_part_2/">here</a>.</p>

<p>If you use foreign key constraints (and you should!) and you have a high transaction load on your database (or expect to soon!), this matters to you. In fact, if you use ActiveRecord with Rails, there might even be a special place in your heart for this issue, <a href="http://mina.naguib.ca/blog/2010/11/22/postgresql-foreign-key-deadlocks.html">says Mina Naguib</a>. We’d <em>really</em> like to get this done in time for the PostgreSQL 9.1 release. But it will only happen if the project can be funded.</p>

<p>Yes, that’s right, as with <a href="http://pgxn.org/">PGXN</a>, this is community project for which we’re raising funds from the community to get it done. I think that more and more work could be done this way, as various interested parties contribute small amounts to collectively fund improvements to the benefit of us all. So can you help out? Hit the <a href="https://www.fossexperts.com/content/foreign-key-locks">FOSSExperts project page</a> for all the project details, and to <a href="https://www.fossexperts.com/content/foreign-key-locks-0">make your contribution</a>.</p>

<p>Help us help the community to make PostgreSQL better than ever!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/postgresql/fk-locks-project.html">old layout</a>.</small></p>


