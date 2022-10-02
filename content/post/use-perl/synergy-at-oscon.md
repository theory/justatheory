---
date: 2003-07-13T04:49:50Z
description: Bringing Perlers and PostgreSQLers together.
lastMod: 2022-10-02T22:39:29Z
slug: synergy-at-oscon
tags:
  - use Perl
  - Perl
  - OSCON
title: Synergy at OSCON
---

Well, I thoroughly enjoyed OSCON this year. I knew a lot more people than last
year, and thus was able to socialize more, and talk to more people about more
stuff. Really a great time, with lots of cross-pollination of ideas.

My favorite moment came on Thursday. The PostgreSQL BOF was on Wednesday night,
where Bruce Momjian was discussing some of the problems they've been having with
the Win32 port, specifically with fork and exec. Now, I know nothing about C,
but James Briggs suggested that the PostgreSQL guys talk to Gurusamy Sarathy
about it, since he did the work on fork and exec for Perl and thus might be able
to provide some advice for the PostgreSQL folks.

No one reacted much to this, but I thought it was a good enough idea that during
the morning break on Thursday, I introduced my self to Sarathy and asked if he'd
be willing to discuss it with the PostgreSQL developers. He said he'd be happy
to. So during the afternoon break, I brought Bruce down to the ActiveState booth
and introduced him to Sarathy.

Well, that seemed to go very, very well. Sarathy seemed willing not only to help
them with some questions they might have, but perhaps even to contribute some
work to the effort. It turns out that he views PostgreSQL as an important
open-source asset, and is willing to put his code where his opinion is. He asked
about subscribing to the PostgreSQL hackers mail list! He and Bruce talked for a
while about the issues at hand, and there seemed to be a great deal of
understanding and mutual respect. This could be a major benefit for the
PostgreSQL community, and will in turn give Perlers another great OSS RDBMS that
runs just about anywhere. Yay!

A similar thing happened on Thursday night. Andy Wardley of Template Toolkit
fame has promised to create a TT burner for Bricolage. This will bring the total
number of Bricolage templating systems to three (Mason, HTML::Template, and TT).
After the action, I accompanied Dave Rolsky, one of the lead Mason hackers, into
the bar where we ran into Andy. Andy started telling us that looking at adding
TT to Bricolage had led him to hatch a plan to come up with a unified,
foundational templating API that many or all of the Perl templating systems
might one day be able to use, so that they might start to share a common feature
set. And then, when one of them wanted to add a feature similar to a feature in
another templating architecture, it might be able to just exploit the common
API.

This seemed like a very cool idea to me, and Dave said that he would definitely
be interested in participating in such an effort. I think that, if he can find
the tuits, Andy may well start a project in this vein, inviting the Mason,
Embperl, Apache::ASP, and other Perl templating hackers to collaborate. This
could really be to the benefit of them all.

What a great conference. I can't wait till next year when I can see some of the
fruits of these meetings, the spoils of inter-community synergy, and where it
will happen all over again.

My apologies for those friends I didn't get a chance to spend much time with at
the conference. All of a sudden I know so many people! See you next year.

*Originally published [on use Perl;]*

  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/13415/
    "use.perl.org journal of Theory: “Synergy at OSCON”"
