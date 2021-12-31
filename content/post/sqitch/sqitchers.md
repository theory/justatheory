---
title: "Sqitchers"
date: 2018-05-30T14:43:39Z
lastMod: 2018-05-30T14:43:39Z
description: The time has come for Sqitch to leave the nest and go out on its own.
tags: [Sqitch, Community, Dave Rolsky, Shawn Sorichetti, Curtis Poe, Ștefan Suciu]
type: post
---

In the last few years, I’ve not had a lot of time to hack on my open-source
projects, including [Sqitch]. Last week's call to [adopt my modules] garnered an
unexpected quantity of interest in helping to maintain Sqitch specifically. It’s
little different from my other [Perl modules], being designed as a standalone
app rather than a software development library. It deserves care and feeding
from more than a single maintainer.

So I’m very pleased to announce two changes to the Sqitch ecosystem:

1.  I’ve moved all my Sqitch-related code, including Sqitch itself, from my
    personal GitHub account to the new [“Sqitchers” GitHub organization]. In
    addition to myself, the organization has four other owners: [Dave Rolsky],
    [Shawn Sorichetti], [Curtis Poe], and [Ștefan Suciu]. However, I’d really
    like to balance all this great Perl talent with a few database folks. Even
    better to get some non-white-dudes involved. If that’s you, and you’d like
    to help Sqitch continue to improve, drop me a line.

2.  I’ve created a new mail list, [sqitch-hackers], for folks who want to hack
    on Sqitch itself. This is an open list, like the existing [sqitch-users]
    list: anyone can subscribe and participate in the discussion of how to
    improve Sqitch, get hints for hacking on it, talk about approaches to
    implementing features, etc.

I’ll likely make a brain dump of stuff I’d like to see happen with the project
and the community. Do [join][sqitch-hackers] and send us your ideas, too!

Sqitch has become a pretty important tool for a lot of people, far and way my
most-starred project on GitHub. It deserves a broader coalition of people to
care for it going forward. I hope these changes help to galvanize the community
to take it on collectively.

  [Sqitch]: https://sqitch.org/
  [adopt my modules]: {{% ref "/post/perl/adopt-my-modules" %}} "Adopt My Modules"
  [Perl modules]: https://metacpan.org/author/DWHEELER
    "CPAN distributions released by David E. Wheeler"
  [“Sqitchers” GitHub organization]: https://github.com/sqitchers
  [Dave Rolsky]: https://blog.urth.org "House Absolute(ly) Pointless"
  [Shawn Sorichetti]: https://ssoriche.com
  [Curtis Poe]: https://allaroundtheworld.fr "All Around the World"
  [Ștefan Suciu]: http://stefansuciu.ro
  [sqitch-hackers]: https://groups.google.com/forum/#!forum/sqitch-hackers
  [sqitch-users]: https://groups.google.com/forum/#!forum/sqitch-users
