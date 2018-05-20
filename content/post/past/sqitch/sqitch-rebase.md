--- 
date: 2012-12-04T07:27:27Z
slug: sqitch-rebase
title: "Sqitch Update: All Your Rebase Are…Never Mind"
aliases: [/computers/databases/sqitch-rebase.html]
tags: [Sqitch, SQL, change management, database]
type: post
---

I’m pleased to announce the release of [Sqitch v0.940]. The focus of this
release? *Sanity*.

I’ve been doing a lot of Sqitch-based database development at [work]. Overall it
has worked quite well. Except for one thing: often the order in which changes
would be arranged would change from one run to the next. Oy.

### Out of Order

The reason? The plan parser would perform a [topological sort] of all the
changes between tags based on their dependencies. I’ve been careful, for the
most part, to keep my changes in the proper order in our plan files, but the
topological sort would often pick a different order. Still valid in terms of
dependency ordering, but different from the plan file.

Given the same inputs, the sort always produced the same order. However,
whenever I added a new changes (and I do that all the time while developing),
there would then be a new input, which could result in a completely different
order. The downside is that I would add a change, run `sqitch deploy`, and it
would die because it thought something needed to be deployed that had already
been deployed, simply because it sorted it to come after an undeployed change.
*So annoying.*. It also caused problems in for production deployments, because
different machines with different Perls would sort the plans in different ways.

So I re-wrote the sorting part of the the plan parser so that it no longer
sorts. The list of changes is now always identical to the order in the plan
file. It still checks dependencies, of course, only now it throws an exception
if it finds an ordering problem, rather than re-ordering for you. I’ve made an
effort to tell the user how to move things around in the plan file to fix
ordering issues, so hopefully everything will be less mysterious.

Of course, many will never use dependencies, in which case this change has
effect. But it was important to me, as I like to specify dependencies as much as
I can, for my own sanity.

See? There’s that theme!

### Everyone has a Mom

Speaking of ordering, as we have been starting to do production deployments, I
realized that my previous notion to allow developers to reorder changes in the
plan file without rebuilding databases was a mistake. It was too easy for
someone to deploy to an existing database and miss changes because there was
nothing to notice that changes had not been deployed. This was especially a
problem before I addressed the ordering issue.

Even with ordering fixed, I thought about how `git push` works, and [realized]
that it was much more important to make sure things really were consistent than
it was to make things slightly more convenient for developers.

So I changed the way change IDs are generated. The text hashed for IDs now
includes the ID of the parent change (if there is one), the change dependencies,
and the change note. If any of these things change, the ID of the change will
change. So they might change a lot during development, while one moves things
around, changes dependencies, and tweaks the description. But the advantage is
for production, where things have to be deployed exactly right, with no
modifications, or else the deploy will fail. This is sort of like requiring all
Git merges to be fast-forwarded, and philosophically in line with the Git
practice of never changing commits after they’re pushed to a remote repository
accessible to others.

Curious what text is hashed for the IDs? Check out the new [`show` command]!

### Rebase

As a database hacker, I still need things to be relatively convenient for
iterative development. So I’ve also added the [`rebase` command]. It’s simple,
really: It just does a `revert` and a `deploy` a single command. I’m doing this
all day long, so I’m happy to save myself a few steps. It’s also nice that I can
do `sqitch rebase @HEAD^` to revert and re-apply the latest change over and over
again without fear that it will fail because of an ordering problem. But I
already mentioned that, didn’t I?

### Order Up

Well, mostly. Another ordering issue I addressed was for the `revert --to`
option. It used to be that it would find the change to revert to in the *plan*,
and revert based on the plan order. (And did I mention that said order might
have *changed since the last deploy?*) v0.940 now searches the *database* for
the revert target. Not only that, the full list of changes to deploy to revert
to the target is *also* returned from the database. In fact, the `revert` no
longer consults the plan file at all. This is great if you’ve re-ordered things,
because the revert will *always* be the reverse order of the *previous* deploy.
Even if IDs have changed, `revert` will find the changes to revert by name. It
will only fail if you’ve removed the revert script for a change.

So simple, conceptually: `revert` reverts in the proper order based on what was
deployed before. `deploy` deploys based on the order in the plan.

### Not `@FIRST`, Not `@LAST`

As a result of the improved intelligence of `revert`, I have also deprecated the
`@FIRST` and `@LAST` symbolic tags. These tags forced a search of the database,
but were mainly used for `revert`. Now that `revert` always searches the
database, there’s nothing to force. They’re still around for backward
compatibility, but no longer documented. Use `@ROOT` and `@HEAD`, instead.

### Not Over

So lots of big changes, including some compatibility changes. But I’ve tried
hard to make them as transparent as possible (old IDs will automatically be
updated by `deploy`). So take it for a spin!

Meanwhile, I still have quite a few other improvements I need to make. On my
short list are:

-   [Checking all dependencies] before deploying or reverting *any* changes.
-   [Adding the `verify` command] to run acceptance tests.
-   [Adding a `--no-run` option to `deploy`] so that existing databases can be
    upgraded to Sqitch.
-   [Adding a `check` command] to sanity-check a plan, scripts, and a database.

  [Sqitch v0.940]: https://metacpan.org/release/App-Sqitch/
  [work]: http://iovation.com/
  [topological sort]: https://en.wikipedia.org/wiki/Topological_sorting
    "Wikipedia: âTopological sortingâ"
  [realized]: /computers/databases/changing-sqitch_ids.html
  [`show` command]: (https://metacpan.org/module/sqitch-show
  [`rebase` command]: https://github.com/theory/sqitch/blob/master/lib/sqitch-rebase.pod
  [Checking all dependencies]: https://github.com/theory/sqitch/issues/39
  [Adding the `verify` command]: https://github.com/theory/sqitch/issues/15
  [Adding a `--no-run` option to `deploy`]: https://github.com/theory/sqitch/issues/54
  [Adding a `check` command]: https://github.com/theory/sqitch/issues/13
