--- 
date: 2012-04-28T04:32:52Z
slug: sqitch-update
title: Sqitch Update
aliases: [/computers/databases/sqitch-update.html]
tags: [Sqitch, SQL, Change Management]
type: post
---

A quick update on [Sqitch]. I started implementation about a couple of weeks
ago. It’s coming a long a bit more slowly than I'd like, given that I need to
give [a presentation] on it soon. But I did things a little differently than I
usually do with project like this: I wrote documentation first. In addition to
the basic docs I [posted] a couple weeks back, I’ve written [a tutorial]. I put
quite a lot of time into it, studying the [Git] interface as I did so, to try to
develop useful workflows. The nice thing about this it that it will not only
serve as the foundation for my presentation (*PHEW!* Half the work done
already!), but it also serves as a design specification.

So I've been diligently plugging away on it, and have uploaded a couple of trial
releases [to CPAN]. So far, we have decent support for:

-   `sqitch help` and `sqitch help command`. The latter only works for the
    implemented commands, of course.
-   `sqitch config`, which is a near perfect duplication of [`git-config`],
    thanks to the very useful [Config::GitLike]. It supports a local,
    project-specific config file, a user config file, and a system config file.
-   `sqitch init`, which creates a new project by creating directories for the
    deploy, revert, and test scripts, and writes a project-specific config file.
    This file has options you specify in the call to `sqitch` (such as the
    database engine you plan to use), and all unmodified settings or settings
    set in user or system configuration are written out as comments.

So yeah, not a ton so far, but the foundations for how it all goes together are
there, so it should take less time to develop other commands, all things being
equal.

Next up:

-   `sqitch add-step`, which will create deploy and revert scripts for a new
    step, based on simple templates.
-   `sqitch deploy`, which is the big one. Initial support will be there for
    PostgreSQL and SQLite (and perhaps MySQL).

Interested in helping out?

-   I'm going to need a parser for [the plan file] pretty soon. The interface
    will need an iterator to move back and forth in the file, as well as a way
    to write to the file, add steps to it, etc. The [grammar] is pretty simple,
    so anyone familiar with parsers and iterators could probably knock something
    out pretty quickly.

-   The interface for testing needs some thinking through. I had been thinking
    that it could be something as simple as just diffing the output of a script
    file against an expected output file, at least to start. One could even use
    [pgTAP] or [MyTAP] in such scripts, although it might be a pain to get the
    output exactly right for varying environments. But maybe that doesn't matter
    for deployment, so much? Because it tends to be to a more controlled
    environment than your typical open-source library test suite, I mean.

Got something to add? [Fork it!]

  [Sqitch]: https://github.com/theory/sqitch/
  [a presentation]: https://www.pgcon.org/2012/schedule/events/479.en.html
  [posted]: /computers/databases/sqitch-draft.html
  [a tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
  [Git]: http://git-scm.com/
  [to CPAN]: http://search.cpan.org/dist/App-Sqitch/
  [`git-config`]: https://git-scm.com/docs/git-config
  [Config::GitLike]: https://metacpan.org/module/Config::GitLike/
  [the plan file]: https://github.com/theory/sqitch/blob/master/lib/sqitch.pod#plan-file
  [grammar]: https://github.com/theory/sqitch/blob/master/lib/sqitch.pod#grammar
  [pgTAP]: https://pgtap.org/
  [MyTAP]: http://hepabolu.github.com/mytap/
  [Fork it!]: https://github.com/theory/sqitch
