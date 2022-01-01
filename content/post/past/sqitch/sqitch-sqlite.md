--- 
date: 2013-04-10T00:27:57Z
slug: sqitch-sqlite
title: "Sqitch: Now with SQLite Support"
aliases: [/computers/databases/sqitch-sqlite.html]
tags: [Sqitch, Git, SQLite, Databases]
type: post
---

This week I released [Sqitch v0.961]. There are a number of great new features
v0.95x, including the beginning of two features I’ve had in mind since the
beginning: VCS integration and support for multiple databases.

First the VCS integration. This comes in the form of the new [`checkout`
command], which automatically makes database changes for you when you change VCS
branches. Say you have two branches, “widgets” and “big-fix”, and that their
Sqitch plans diverge. If you’re in the “widgets” branch and want to switch to
“big-fix”, just run

    sqitch checkout big-fix

Sqitch will look at the “big-fix” plan, figure out the last change in common
with “widgets”, and revert to it. Then it checks out “big-fix” and deploys.
That’s it. Yes, you could do this yourself, but do you really remember the last
common change between the two branches? Do you want to take the time to look for
it, then revert, check out the new branch, and deploy? This is exactly the sort
of common developer task that Sqitch aims to take the pain out of, and I’m
thrilled to provide it.

You know what’s awesome, though? *This feature never occurred to me.* I didn’t
come up with it, and didn’t implement it. No, it was dreamt up and submitted in
a pull request by [Ronan Dunklau]. I have wanted VCS integration since the
beginning, but had yet to get ‘round to it. Now Ronan has jumpstarted it. A
million thanks!

One downside: it’s currently Git-only. I plan to add infrastructure for
[supporting multiple VCSes], probably with Git and Subversion support to begin
with. Watch for that in v0.970 in the next couple months.

The other big change is the addition of [SQLite] support alongside the existing
[PostgreSQL] support. Fortunately, I was able to re-use nearly all the code, so
the SQLite adapter is just [a couple hundred lines long]. For the most part,
Sqitch on SQLite works just like on PostgreSQL. The main difference is that
Sqitch stores its metadata in a separate SQLite database file. This allows one
to use a single metadata file to maintain multiple databases, which can be
important if you use multiple databases as schemas pulled into a single
connection via [`ATTACH DATABASE`].

Curious to try it out? Install Sqitch [from CPAN] or [via the Homebrew Tap] and
then follow the new [Sqitch SQLite tutorial].

Of the multitude of other [Changes], one other bears mentioning: the new [`plan`
command]. This command is just like [`log`], except that it shows what is in the
plan file, rather than what changes have been made to the database. This can be
useful for quickly listing what’s in a plan, for example when you need to
remember the names of changes required by a change you’re about to [`add`]. The
`--oneline` option is especially useful for this functionality. An example from
[the tutorial]’s plan:

    > sqitch plan --oneline
    In sqitch.plan
    6238d8 deploy change_pass
    d82139 deploy insert_user
    7e6e8b deploy pgcrypto
    87952d deploy delete_flip @v1.0.0-dev2
    b0a951 deploy insert_flip
    834e6a deploy flips
    d0acfa deploy delete_list
    77fd99 deploy insert_list
    1a4b9a deploy lists
    0acf77 deploy change_pass @v1.0.0-dev1
    ec2dca deploy insert_user
    bbb98e deploy users
    ae1263 deploy appschema

I personally will be using this a lot, Yep, scratching my own itch here. What
itch do you have to scratch with Sqitch?

In related news, I’ll be giving a tutorial at [PGCon] next month, entitled
“[Agile Database Development]”. We’ll be developing a database for a web
application using [Git] for source code management, [Sqitch] for database change
management, and [pgTAP] for unit testing. This is the stuff I do all day long at
work, so you can also think of it as “Theory’s Pragmatic approach to Database
Development.” See you there?

  [Sqitch v0.961]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.961/
  [`checkout` command]: https://metacpan.org/module/sqitch-checkout
  [Ronan Dunklau]: https://github.com/rdunklau/
  [supporting multiple VCSes]: https://github.com/theory/sqitch/issues/25
  [SQLite]: https://sqlite.org/
  [PostgreSQL]: https://postgresql.org/
  [a couple hundred lines long]: https://github.com/theory/sqitch/blob/master/lib/App/Sqitch/Engine/sqlite.pm
  [`ATTACH DATABASE`]: https://www.sqlite.org/lang_attach.html
  [from CPAN]: https://metacpan.org/release/App-Sqitch
  [via the Homebrew Tap]: https://github.com/theory/homebrew-sqitch
  [Sqitch SQLite tutorial]: https://metacpan.org/module/sqitchtutorial-sqlite
  [Changes]: https://metacpan.org/source/DWHEELER/App-Sqitch-0.961/Changes
  [`plan` command]: https://metacpan.org/module/sqitch-plan
  [`log`]: https://metacpan.org/module/sqitch-log
  [`add`]: https://metacpan.org/module/sqitch-add
  [the tutorial]: https://metacpan.org/module/sqitchtutorial
  [PGCon]: http://pgcon.org/2013/
  [Agile Database Development]: https://www.pgcon.org/2013/schedule/events/615.en.html
  [Git]: http://git-scm.com/
  [Sqitch]: https://sqitch.org/
  [pgTAP]: https://pgtap.org/
