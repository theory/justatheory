--- 
date: 2012-05-15T17:41:03Z
slug: dbi-in-sqitch
title: Use of DBI in Sqitch
aliases: [/computers/databases/dbi-in-sqitch.html]
tags: [Sqitch, Perl, DBI, IPC]
type: post
---

<p><a href="http://sqitch.org/">Sqitch</a> uses the native database client applications (<a href="http://www.postgresql.org/docs/current/static/app-psql.html"><code>psql</code></a>, <a href="http://man.he.net/man1/sqlite3"><code>sqlite3</code></a>, <a href="http://dev.mysql.com/doc/refman/5.5/en/mysql.html"><code>mysql</code></a>, etc.). So for tracking metadata about the state of deployments, I have been trying to stick to using them. I’m first targeting PostgreSQL, and as a result need to open a connection to <code>psql</code>, start a transaction, and be able to read and write stuff to it as migrations go along. <a href="http://stackoverflow.com/questions/10569805/what-is-the-preferred-cross-platform-ipc-perl-module">The IPC</a> is a <a href="http://www.perlmonks.org/?node_id=970244">huge PITA</a>. Furthermore, getting things properly quoted is also pretty annoying — and it will be worse for SQLite and MySQL, I expect (<code>psql</code>’s <code>--set</code> support is pretty slick).</p>

<p>If, on the other hand, I used the <a href="https://metacpan.org/module/DBI">DBI</a>, on the other hand, all this would be very easy. There is no IPC, just a direct connection to the database. It would save me a ton of time doing development, and be robust and safer to use (e.g., exception handling rather than platform-dependent signal handling (or not, in the case of Windows)). I am quite tempted to just so that.</p>

<p>However, I have been trying to be sensitive to dependencies. I had planned to make Sqitch simple to install on any system, and if you had the command-line client for your preferred database, it would just work. If I used the DBI instead, then Sqitch would not work at all unless you installed the appropriate DBI driver for your database of choice. This is no big deal for Perl people, of course, but I don’t want this to be a Perl people tool. I want it to be dead simple for anyone to use for any database. Ideally, there will be RPMs and Ubuntu packages, so one can just install it and go, and not have to worry about figuring out what additional Perl DBD to install for your database of choice. It should be transparent.</p>

<p>That is still my goal, but at this point the IPC requirements for controlling the clients is driving me a little crazy. Should I just give up and use the DBI (at least for now)? Or persevere with the IPC stuff and get it to work? Opinions wanted!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/dbi-in-sqitch.html">old layout</a>.</small></p>


