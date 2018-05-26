--- 
date: 2014-01-09T15:27:00Z
title: Sqitch on Target
aliases: [/sqitch/2014/01/09/sqitch-on-target/]
tags: [Sqitch]
type: post
---

At the end of the day last week, I released [Sqitch] v0.990. This was a
pretty big release, with lots of changes. The most awesome addition, in my
opinion, is *Named Deployment targets.*

In previous versions of Sqitch, one
could set default values for the database to deploy to, but needed to use the
`--db-*` options to deploy to another database. This was fine for
development: just set the default on `localhost` and go. But when it came
time to deploy to other servers for testing, QA, or production, it was a bit
of a PITA. At [work], I ended up writing deployment docs that defined a slew
of environment variables, and our operations team needed to adjust those
variables to deploy to various servers. It was ugly, and frankly a bit of a
pain in the ass.

I thought it'd be better to have named deployment targets, so instead of
changing a bunch of environment variables in order to set a bunch of options,
we could just name a target and go. I borrowed the idea from [Git remotes],
and started a [database URI spec] (mentioned [previously]) to simplify things
a bit. Here's how it works. Say you have a PostgreSQL Sqitch project called
"Flipr". While doing development, you'll want to have a local database to
deploy to. There is also a QA database and a production database. Use the
[`target`] command to set them up:

``` sh
sqitch target add dev db:pg:flipr
sqitch target add qa db:pg://sqitch@qa.example.com/flipr
sqitch target add prod db:pg://sqitch@db.example.com/flipr
```

Like [Git remotes], we just have names and URIs. To [`deploy`] to a database,
just name it:

``` sh
sqitch deploy dev
```

Want to deploy to QA? Name it:

``` sh
sqitch deploy qa
```

This works with any of the commands that connect to a database, including
[`revert`] and [`status`]:

``` sh
sqitch revert --to @HEAD^^ dev
sqitch status prod
```
The great thing about this feature is that the configuration is all stored
in the project Sqitch configuration file. That means you can commit all the
connection URIs for all likely targets in directly to the project repository.
If they change, just change them in the config, commit, and push.

Targets don't always have to be configured in advance, of course. The names
essentially stand in for the URIs, so you can connect to an unnamed target
just by using a URI:

``` sh
sqitch log db:postgres://db1.example.net/flipr_export
```

Of course there are still defaults specific to each engine. I generally like
to set the "dev" target as the default deploy target, like so:

``` sh
sqitch config core.pg.target dev
```

This sets the "dev" target as the default for the PostgreSQL engine. So now I
can do stuff with the "dev" target without mentioning it at all:

``` sh
sqitch rebase --onto HEAD^4
```

Named targets may also have a couple other attributes associated with them:

* `client`: The command-line client to use for a target.
* `registry`: The name of the Sqitch registry schema or database, which defaults
  to, simply, `sqitch`.

Now that I've started using it, I can think of other things I'd like to add to
targets in the future, including:

* [Setting other attributes], such as the deployment mode, whether to verify
  changes, and variables.
* [Allowing multiple URIs], for concurrent database deployments!

Pretty cool stuff ahead, IMO. I'm grateful to [work] for letting me hack on
Sqitch.

  [Sqitch]: https://sqitch.org/
  [Git remotes]: http://git-scm.com/docs/git-remote
  [work]: http://www.iovation.com/
  [database URI spec]: https://github.com/theory/uri-db
  [previously]: /rfc/2013/11/26/toward-a-database-uri-standard/
  [`target`]: https://metacpan.org/pod/sqitch-target
  [`deploy`]: https://metacpan.org/pod/sqitch-deploy
  [`revert`]: https://metacpan.org/pod/sqitch-revert
  [`status`]: https://metacpan.org/pod/sqitch-status
  [Setting other attributes]: https://github.com/theory/sqitch/issues/143
  [Allowing multiple URIs]: https://github.com/theory/sqitch/issues/135
