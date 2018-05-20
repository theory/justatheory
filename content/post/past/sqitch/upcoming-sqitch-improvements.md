--- 
date: 2013-07-04T13:12:34Z
slug: upcoming-sqitch-improvements
title: Notes on Upcoming Sqitch Improvements
aliases: [/computers/databases/upcoming-sqitch-improvements.html]
tags: [Sqitch, database, change management, MySQL, Cubrid, SQLite]
type: post
---

I was traveling last week, and knowing I would be offline a fair bit, not to
mention seriously jet-lagged, I put my hacking efforts into getting MySQL
support into [Sqitch]. I merged it in yesterday; check out [the tutorial] if
you’re interested in it. I expect to release v0.980 with the MySQL support in a
couple of weeks; testing and feedback would most appreciated.

There is a caveat, though: it requires MySQL v5.6.4. So if you’re stuck with an
older MySQL, it won’t work. There are two reasons to require v5.6.4:

-   The microsecond precision support in `DATETIME` values, added in v5.6.4.
    This makes it much easier to keep things in the proper order (deployments
    usually take less than a second).
-   The `SIGNAL` functionality, introduced in v5.5. This allows the schema to
    [mock a check constraint] in the Sqitch database, as well as make it much
    easier to write verify tests (as described in the tutorial and figured out
    [on StackOverflow]).

But if you can afford to take advantage of a relatively modern MySQL, give it a
shot!

The next release also makes a backwards-incompatible change to the SQLite
engine: the default Sqitch database is no longer
`$db_dir/$db_name-sqitch.$suffix`, but `$db_dir/sqitch.$suffix`. In other words,
if you were deploying to a db named `/var/db/myapp.db`, Sqitch previously kept
its metadata in `/var/db/myapp-sqitch.db`, but now will keep it in
`/var/db/sqitch.db`. This is to make it more like the other engines (MySQL
defaults to a database named “sqitch”, and Postgres and Oracle default to a
schema named “sqitch”).

It’s also useful if you use the SQLite [`ATTACHDATABASE`] command to manage
multiple database files in a single project. In that case, you will want to use
the same metadata file for all the databases. Keep them all in the same
directory with the same suffix and you get just that with the default sqitch
database.

If you’d like it to have a different name, use
`sqitch config core.sqlite.sqitch_db $name` to configure it. This will be useful
if you don’t want to use the same Sqitch database to manage multiple databases,
or if you do, but they live in different directories.

I haven’t released this change yet, and I am not a big-time SQLite user. So if
this makes no sense, please [comment on this issue]. It’ll be a couple of weeks
before I release v0.980, so there is time to reverse if if there’s consensus
that it’s a bad idea.

But given another idea I’ve had, I suspect it will be okay. The idea is to
expand on the concept of a Sqitch “target” by giving it [its own command] and
configuration settings. Basically, it would be sort of like Git remotes: use
URIs to specify database connection and parameter info (such as the sqitch
database name for SQLite). These can be passed to database-touching commands,
such as `deploy`, `revert`, `log`, and the like. They can also be given names
and stored in the configuration file. The upshot is that it would enable
invocations such as

    sqitch deploy production
    sqitch log qa
    sqitch status pg://localhost/flipr?sqitch_schema=meta

See [the GitHub issue][its own command] for a fuller description of this
feature. I’m certain that this would be useful [at work], as we have a limited
number of databases that we deploy each Sqitch project to, and it’s more of a
PITA for my co-workers to remember to use different values for the `--db-host`,
`--db-user`, `--db-name` and friends options. The project itself would just
store the named list of relevant deployment targets.

And it alleviates the issue of specifying a different Sqitch database on SQLite
or MySQL, as one can just create a named target that specifies it in the URI.

Not sure when I will get to this feature, though. I think it would be great to
have, and maybe iovation would want me to spend some time on it in the next
couple of months. But it might also be a great place for someone else to get
started adding functionality to Sqitch.

Oh, and before I forget: it looks like Sqitch might soon get [CUBRID support],
too, thanks to [Ștefan Suciu]. Stay tuned!

  [Sqitch]: http://sqitch.org/
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial-mysql.pod
  [mock a check constraint]: https://github.com/theory/sqitch/blob/master/lib/App/Sqitch/Engine/mysql.sql#L132
  [on StackOverflow]: http://stackoverflow.com/q/17406675/79202
  [`ATTACHDATABASE`]: http://www.sqlite.org/lang_attach.html
  [comment on this issue]: https://github.com/theory/sqitch/issues/98
  [its own command]: https://github.com/theory/sqitch/issues/100
  [at work]: http://iovation.com/
  [CUBRID support]: https://github.com/theory/sqitch/issues/93
  [Ștefan Suciu]: https://github.com/stefansbv
