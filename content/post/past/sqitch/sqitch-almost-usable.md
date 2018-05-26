--- 
date: 2012-07-05T11:29:19Z
slug: sqitch-almost-usable
title: "Sqitch Update: Almost Usable"
aliases: [/computers/databases/sqitch-almost-usable.html]
tags: [Sqitch, SQL, Change Management, Databases, Migrations]
type: post
---

This week, I released v0.50 of [Sqitch], the database change management app I’ve
been working on for the last couple of months. Those interested in how it works
should read [the tutorial]. A lot has changed since v0.30; here are some
highlights:

-   The plan file is now required. This can make merges more annoying, but
    thanks to a comment [from Jakub Narębski], I discovered that Git can be
    configured to use a “union merge driver”, which seems to simplify things a
    great deal. See [the tutorial][1] for a detailed example.
-   The plan now consists solely of a list of changes, roughly analogous to Git
    commits. Tags are simply pointers to specific changes.
-   Dependencies are now specified in the plan file, rather than in the
    deployment scripts. Once the plan file became required, this seemed like the
    [much more obvious] place for them.
-   The plan file now goes into the top-level directory of a project (which
    defaults to the current directory, assumed to be the top level directory of
    a VCS project), while the configuration file goes into the current
    directory. This allows one to have multiple top-level directories for
    different database engines, each with its own plan, and a single
    configuration file for them all.

Seems like a short list, but in reality, this release is the first I would call
almost usable. Most of the core functionality and infrastructure is in place,
and the architectural designs have been finalized. There should be much less
flux in how things work from here on in, though this is still very much a
developer release. Things *might* still change, so I’m being conservative and
not doing a “stable” release just yet.

### What works

So what commands actually work at this point? All of the most important
functional ones:

-   [`sqitch init`] – Initialize a Sqitch project. Creates the project
    configuration file, a plan file, and directories for deploy, revert, and
    test scripts
-   [`sqitch config`] – Configure Sqitch. Uses the same configuration format as
    Git, including cascading local, user, and system-wide configuration files
-   [`sqitch help`] – Get documentation for specific commands
-   [`sqitch add`] – Add a new change to the plan. Generates deploy, revert, and
    test scripts based on user-modifiable templates
-   [`sqitch tag`] – Tag the latest change in the plan, or show a list of
    existing tags
-   [`sqitch deploy`] – Deploy changes to a database. Includes a `--mode` option
    to control how to revert changes in the event of a deploy failure (not at
    all, to last tag, or to starting point)
-   [`sqitch revert`] – Revert changes from a database
-   [`sqitch rework`] – Copy and modify a previous change

Currently, only PostgreSQL is supported by `deploy` and `revert`; I will at
least add SQLite support soon.

The `rework` command is my solution to the problem of code duplication. It does
not (yet) rely on VCS history, so it still duplicates code. However, it does so
in such a way that it is still easier to see what has changed, because the new
files are actually used by the *previous* instance of the command, while the new
one uses the existing files. So a `diff` command, while showing the new files in
toto, actually shows what changed in the existing scripts, making it easier to
follow. I think this is a decent compromise, to allow Sqitch to be used with or
without a VCS, and without disabling the advantages of VCS integration in the
future.

The only requirement for reworking a change is that there must be a tag on that
change or a change following it. Sqitch uses that tag in the name of the files
for the previous instance of the change, as well as in internal IDs, so it’s
required to disambiguate the scripts and deployment records of the two
instances. The assumption here is that tags are generally used when a project is
released, as otherwise, if you were doing development, you would just go back
and modify the change’s scripts directly, and revert and re-deploy to get the
changes in your dev database. But once you tag, this is a sort of promise that
nothing will be changed prior to the tag.

I modify change scripts a *lot* in my own database development projects.
Naturally, I think it is important to be free to change deployment scripts
however one likes while doing development, and also important to promise not to
change them once they have been released. As long as tags are generally thought
of as marking releases or other significant milestones, it seems a reasonable
promise not to change anything that appears before a tag.

See [the tutorial][2] for a detailed example. In a future release, VCS
integration will be added, and the duplicated files will be unnecessary, too.
But the current approach has the advantage that it will work anywhere, VCS or
no. The VCS support will be backward-compatible with this design (indeed, it
depends on it).

### Still To Do

I think I might hold off a bit on the VCS integration, since the `rework`
command no longer requires it. There also needs to be support for database
engines other than PostgreSQL. But otherwise, mostly what needs to be done is
the informational commands, packaging, and testing:

-   [`sqitch status`] – Show the current deployment status of a database
-   [`sqitch log`] – Show the deploy and revert history of a database
-   [`sqitch bundle`] – Bundle up the configuration, plan, and scripts for
    distribution packaging
-   [`sqitch test`] – Test changes. Mostly hand-wavy; see below
-   [`sqitch check`] – Validate a database deployment history against the plan

I will likely be working on the `status` and `log` commands next, as well as an
SQLite engine, to make sure I have the engine encapsulation right.

### Outstanding Questions

I’m still pondering some design decisions. Your thoughts and comments greatly
appreciated.

-   Sqitch now requires a URI, which is set in the local configuration file by
    the `init` command. If you don’t specify one, it just creates a UUID-based
    URI. The URI is required to make sure that changes have unique IDs across
    projects (a change may have the same name as in another project). But maybe
    this should be more flexible? Maybe, like Git, Sqitch should require a user
    name and email address, instead? They would have to be added to the change
    lines of the plan, which is what has given me pause up to now. It would be
    annoying to parse.

-   How should testing work? When I do PostgreSQL stuff, I am of course rather
    keen on [pgTAP]. But I don’t think it makes sense to require a particular
    format of output or anything of that sort. It just wouldn’t be
    engine-neutral enough. So maybe test scripts should just run and considered
    passing if the engine client exits successfully, and failing if it exited
    unsuccessfully? That would allow one to use whatever testing was supported
    by the engine, although I would have to find some way to get pgTAP to make
    `psql` exit non-zero on failure.

    Another possibility is to require expected output files, and to diff them.
    I’m not too keen on this approach, as it makes it much more difficult to
    write tests to run on multiple engine versions and platforms, since the
    output might vary. It’s also more of a PITA to maintain separate test and
    expect files and keep them in sync. Still, it’s a tried-and-true approach.

### Help Wanted

Contributions would be warmly welcomed. See [the to-do list] for what needs
doing. Some highlights and additional items:

-   [Convert to Dist::Zilla]
-   Implement the [Locale::TextDomain]-based localization build. Should be done
    at distribution build time, not install time. Ideally, there would be a
    Dist::Zilla plugin to do it, based pattern implemented in [this example
    `Makefile`] (see also [this README]).
-   [The web site][Sqitch] could use some updating, though I realize it will
    regularly need changing until most of the core development has completed and
    more documentation has been written.
-   Handy with graphics? The project [could use a logo]. Possible themes: SQL,
    databases, change management, baby Sasquatch.
-   Packaging. It would greatly help developers and system administrators who
    don’t do CPAN if they could just use their familiar OS installers to get
    Sqitch. So [RPM], [Debian package], [Homebrew], [BSD Ports], and Windows
    distribution support would be hugely appreciated.

### Take it for a Spin!

Please do install the v0.51 developer release from the CPAN (run
`cpan D/DW/DWHEELER/App-Sqitch-0.51-TRIAL.tar.gz`) and kick the tires a bit.
Follow along [the tutorial] to get a feel for it, or even just review the
tutorial example’s [Git history] to get a feel for it. And if there is something
you want out of Sqitch that you don’t see, please feel free to [file an issue]
with your suggestion.

  [Sqitch]: https://sqitch.org/
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
  [from Jakub Narębski]: /computers/databases/sqitch-dependencies.html#comment-538970287
  [1]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod#emergency
  [much more obvious]: /computers/databases/sqitch-dependencies.html
  [`sqitch init`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-init.pod
  [`sqitch config`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-config.pod
  [`sqitch help`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-help.pod
  [`sqitch add`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-add.pod
  [`sqitch tag`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-tag.pod
  [`sqitch deploy`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-deploy.pod
  [`sqitch revert`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-revert.pod
  [`sqitch rework`]: https://github.com/theory/sqitch/blob/master/lib/sqitch-rework.pod
  [2]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod#in-place-changes
  [`sqitch status`]: https://github.com/theory/sqitch/issues/11
  [`sqitch log`]: https://github.com/theory/sqitch/issues/12
  [`sqitch bundle`]: https://github.com/theory/sqitch/issues/14
  [`sqitch test`]: https://github.com/theory/sqitch/issues/15
  [`sqitch check`]: https://github.com/theory/sqitch/issues/13
  [pgTAP]: https://pgtap.org/
  [the to-do list]: https://github.com/theory/sqitch/issues?labels=todo&page=1&state=open
  [Convert to Dist::Zilla]: https://github.com/theory/sqitch/issues/17
  [Locale::TextDomain]: http://metacpan.org/module/Locale::TextDomain
  [this example `Makefile`]: https://metacpan.org/source/GUIDO/libintl-perl-1.20/sample/simplecal/po/Makefile
  [this README]: https://metacpan.org/source/GUIDO/libintl-perl-1.20/sample/README
  [could use a logo]: https://twitter.com/theory/statuses/197383050680745984
  [RPM]: https://en.wikipedia.org/wiki/RPM_Package_Manager
  [Debian package]: http://www.debian.org/doc/manuals/debian-reference/ch02
  [Homebrew]: http://mxcl.github.com/homebrew/
  [BSD Ports]: https://en.wikipedia.org/wiki/FreeBSD_Ports
  [Git history]: https://github.com/theory/sqitch-intro/commits/master
  [file an issue]: https://github.com/theory/sqitch/issues
