--- 
date: 2013-02-22T07:09:46Z
lastMod: 2022-01-02T17:21:14Z
slug: sqitch-homebrew-tap
title: Sqitch Homebrew Tap
aliases: [/computers/databases/sqitch-homebrew-tap.html]
tags: [Sqitch, SQL, Change Management, Development, Homebrew, Test Anything Protocol, macOS]
type: post
---

If [Sqitch] is to succeed, it needs to get into the hands of as many people as
possible. That means making it easy to install for people who are not Perl
hackers and don’t want to deal with CPAN. The [Sqitch Homebrew Tap] is my first
public stab at that. It provides a series of “Formulas” for [Homebrew] users to
easily download, build, and install Sqitch and all of its dependencies.

If you are one of these lucky people, here’s how to configure the Sqitch tap:

    brew tap theory/sqitch

Now you can install the core Sqitch application:

    brew install sqitch

That’s it. Make sure it works:

    > sqitch --version
    sqitch (App::Sqitch) 0.953

It won’t do you much good without support for your database, though. Currently,
there is a build for PostgreSQL. Note that this requires the Homebrew core
PostgreSQL server:

    brew install sqitch_pg

Sqitch hasn’t been ported to other database engines yet, but once it is, expect
other formulas to follow. But if you use PostgreSQL (or just want to experiment
with it), you’re ready to rock! I suggest following along [the tutorial],
[downloading], or [taking in] the latest iteration of the introductory
presentation (video of an older version [on Vimeo]).

My thanks to IRC user “mistym” for the help and suggestions in getting this
going. My Ruby is pretty much rusted through, soI could not have done it without
the incredibly responsive help!

  [Sqitch]: https://sqitch.org/ "Sqitch: Sane database schema change management"
  [Sqitch Homebrew Tap]: https://github.com/sqitchers/homebrew-sqitch
  [Homebrew]: https://brew.sh/
  [the tutorial]: https://github.com/sqitchers/sqitch/blob/develop/lib/sqitchtutorial.pod
  [taking in]: https://speakerdeck.com/theory/sane-database-change-management-with-sqitch
    "Speaker Deck: “Sane Database Change Management with Sqitch”"
  [downloading]: {{% link "sqitch-pdxpm-2013.pdf" %}}
    "Download “Sane Database Change Management with Sqitch”"
  [on Vimeo]: https://vimeo.com/50104469
