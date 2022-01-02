--- 
date: 2012-09-25T22:59:59Z
lastMod: 2022-01-02T17:43:28Z
slug: sqitch-symbolism
title: Sqitch Symbolism
aliases: [/computers/databases/sqitch-symbolism.html]
tags: [Sqitch, SQL, Change Management, Localization, Internationalization]
type: post
---

It has been a while since I [last blogged about Sqitch]. The silence is in part
due to the fact that I’ve moved from full-time Sqitch development to actually
putting it to use building databases at work. This is exciting, because it needs
the real-world experience to grow up.

That’s not to say that nothing has happened with Sqitch. I’ve just released
[v0.931] which includes a bunch of improvement since I wrote about v0.90. First
a couple of the minor things:

-   Sqitch now checks dependencies before reverting, and dies if they would be
    broken by the revert. This change, introduced in v0.91, required that the
    dependencies be moved to their own table, so if you’ve been messing with an
    earlier version of Sqitch, you’ll have to rebuild the database. Sorry about
    that.
-   I fixed a bunch of Windows-related issues, including finding the current
    user’s full name, correctly setting the locale for displaying dates and
    times, executing shell commands, and passing tests. The awesome [ActiveState
    PPM Index] has been invaluable in tracking these issues down.
-   Added the [`bundle` command]. All it does is copy your project configuration
    file, plan, and deploy, revert, and test scripts to a directory you
    identify. The purpose is to be able to export the project into a directory
    structure suitable for distribution in a tarball, RPM, or whatever. That my
    not sound incredibly useful, since copying files is no big deal. However,
    the long-term plan is to add VCS support to Sqitch, which would entail
    fetching scripts from various places in VCS history. At that point, it will
    be essential to use `bundle` to do the export, so that scripts are properly
    exported from the VCS history. That said, I’m actually using it already to
    build RPMs. Useful already!

### Symbolic References

And now the more immediately useful changes. First, I added new symbolic tags,
`@FIRST` and `@LAST`. These represent the first and last changes currently
deployed to a database, respectively. These complement the existing `@ROOT` and
`@HEAD` symbolic tags, which represent the first and last changes listed in the
*plan.* The distinction is important: The change plan vs actual deployments to a
database.

The addition of `@FIRST` and `@LAST` may not sounds like much, but there’s more.

I also added forward and reverse change reference modifiers `^` and `~`. The
basic idea was stolen from [Git Revisions], though the semantics vary. For
[Sqitch changes], `^` appended to a name or tag means “the change before this
change,” while `~` means “the change after this change”. I find `^` most useful
when doing development, where I’m constantly deploying and reverting a change as
I work. Here’s how I do that revert:

    sqitch revert --to @LAST^

That means “revert to the change before the last change”, or simply “revert the
last change”. If I want to revert two changes, I use two `^`s:

    sqitch revert --to @LAST^^

To go back any further, I need to use an integer with the `^`. Here’s how to
revert the last four changes deployed to the database:

    sqitch revert --to @LAST^4

The cool thing about this is that I don’t have to remember the name of the
change to revert, as was previously required. And of course, if I just wanted to
deploy two changes since the last deployment, I would use `~~`:

    sqitch deploy --to @LAST~~

Nice, right? One thing to bear in mind, as I was reminded while giving a [Sqitch
presentation][slides] to [PDXPUG][]: Changes are deployed in a sequence. You can
think of them as a linked list. So this command:

    sqitch revert @LAST^^

Does *not* mean to revert the second-to-last change, leaving the two after it.
It will revert the last change *and* the penultimate change. This is why I
actually encourage the use of the `--to` option, to emphasize that you’re
deploying or reverting all changes *to* the named point, rather than deploying
or reverting the named point in isolation. Sqitch simply doesn’t do that.

### Internationalize Me

One more change. With today’s release of v0.931, there is now proper
internationalization support in Sqitch. The code has been localized for a long
time, but there was no infrastructure for internationalizing. Now there is, and
I’ve stubbed out files for translating Sqitch messages into [French] and
[German]. Adding others is easy.

If you’re interested in translating Sqitch’s messages (only 163 of them, should
be quick!), just [fork Sqitch], juice up your favorite [gettext editor], and
start editing. Let me know if you need a language file generated; I’ve built the
tools to do it easily with [dzil], but haven’t released them yet. Look for a
post about that later in the week.

### Presentation

Oh, and that [PDXPUG presentation][PDXPUG]? Here are the slides (also for
[download] and on [Slideshare]). Enjoy!

<iframe src="{{% link "sqitch-pdxpug-2012.pdf" %}}" class="slides"></iframe>

  [last blogged about Sqitch]: {{% ref "/post/past/sqitch/sqitch-depend-on-it" %}}
  [v0.931]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.931/
  [ActiveState PPM Index]: https://code.activestate.com/ppm/App-Sqitch/
  [`bundle` command]: https://metacpan.org/module/sqitch-bundle
  [Git Revisions]: https://git-scm.com/docs/gitrevisions
  [Sqitch changes]: https://metacpan.org/module/sqitchchanges
  [PDXPUG]: http://pdxpug.wordpress.com/2012/09/07/pdxpug-september-meeting-coming-up/
  [French]: https://github.com/sqitchers/sqitch/blob/develop/po/fr_FR.po
  [German]: https://github.com/sqitchers/sqitch/blob/develop/po/de_DE.po
  [fork Sqitch]: https://github.com/theory/sqitch/
  [gettext editor]: http://www.google.com/search?q=gettext+editor
  [dzil]: https://dzil.org
  [download]: {{% link "sqitch-pdxpug-2012.pdf" %}}
    "Download “Sane SQL Change Management with Sqitch”"
  [Slideshare]: https://www.slideshare.net/justatheory/sane-sql-change-management-with-sqitch
    "Slideshare: “Sane SQL Change Management with Sqitch”"