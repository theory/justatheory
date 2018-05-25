--- 
date: 2013-02-22T07:09:46Z
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
with it), you’re ready to rock! I suggest following along [the tutorial] or
taking in [the latest iteration of the introductory presentation] (video of an
older version [here]).

My thanks to IRC user “mistym” for the help and suggestions in getting this
going. My Ruby is pretty much rusted through, soI could not have done it without
the incredibly responsive help!

  [Sqitch]: http://sqitch.org/ "Sqitch: Sane database schema change management"
  [Sqitch Homebrew Tap]: https://github.com/theory/homebrew-sqitch
  [Homebrew]: http://mxcl.github.com/homebrew/
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
  [the latest iteration of the introductory presentation]: https://speakerdeck.com/theory/sane-database-change-management-with-sqitch
  [here]: https://vimeo.com/50104469
