--- 
date: 2012-05-15T17:41:03Z
slug: dbi-in-sqitch
title: Use of DBI in Sqitch
aliases: [/computers/databases/dbi-in-sqitch.html]
tags: [Sqitch, Perl, DBI, IPC]
type: post
---

[Sqitch] uses the native database client applications ([`psql`], [`sqlite3`],
[`mysql`], etc.). So for tracking metadata about the state of deployments, I
have been trying to stick to using them. I’m first targeting PostgreSQL, and as
a result need to open a connection to `psql`, start a transaction, and be able
to read and write stuff to it as migrations go along. [The IPC] is a [huge
PITA]. Furthermore, getting things properly quoted is also pretty annoying — and
it will be worse for SQLite and MySQL, I expect (`psql`’s `--set` support is
pretty slick).

If, on the other hand, I used the [DBI], on the other hand, all this would be
very easy. There is no IPC, just a direct connection to the database. It would
save me a ton of time doing development, and be robust and safer to use (e.g.,
exception handling rather than platform-dependent signal handling (or not, in
the case of Windows)). I am quite tempted to just so that.

However, I have been trying to be sensitive to dependencies. I had planned to
make Sqitch simple to install on any system, and if you had the command-line
client for your preferred database, it would just work. If I used the DBI
instead, then Sqitch would not work at all unless you installed the appropriate
DBI driver for your database of choice. This is no big deal for Perl people, of
course, but I don’t want this to be a Perl people tool. I want it to be dead
simple for anyone to use for any database. Ideally, there will be RPMs and
Ubuntu packages, so one can just install it and go, and not have to worry about
figuring out what additional Perl DBD to install for your database of choice. It
should be transparent.

That is still my goal, but at this point the IPC requirements for controlling
the clients is driving me a little crazy. Should I just give up and use the DBI
(at least for now)? Or persevere with the IPC stuff and get it to work? Opinions
wanted!

  [Sqitch]: https://sqitch.org/
  [`psql`]: http://www.postgresql.org/docs/current/static/app-psql.html
  [`sqlite3`]: http://man.he.net/man1/sqlite3
  [`mysql`]: http://dev.mysql.com/doc/refman/5.5/en/mysql.html
  [The IPC]: http://stackoverflow.com/questions/10569805/what-is-the-preferred-cross-platform-ipc-perl-module
  [huge PITA]: http://www.perlmonks.org/?node_id=970244
  [DBI]: https://metacpan.org/module/DBI
