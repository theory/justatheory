---
date: 2002-02-15T00:46:29Z
description: And it appears to be worse than I thought!
lastMod: 2022-10-02T22:39:29Z
slug: mod-perl-bug-confirmed
tags:
  - use Perl
  - Perl
title: mod_perl Bug Confirmed!
---

The mod_perl bug that I [reported] finding last week has been confirmed and a
patch supplied by Salvador Ortiz Garcia. Read all about it [here]).

It turns out to be uglier than I thought, because what Location and Directory
locations that mod_perl decides to "upgrade" to their Match versions is random.
Actually, we've found it to be consistent in [Bricolage] (the relevant source
code is [here]). That is, although we can't predict which directives mod_perl
will "upgrade", it does tend to "upgrade" the same ones every time. This allows
me to check the mod_perl version and try to do the right thing regardless. Maybe
we'll require mod_perl 1.27 when it finally comes out.

But at any rate, I'm glad to have the thing addressed and understood. It's not
common that I notice a bug in Perl or mod_perl, and it's rewarding to see
someone pick it up and address it quickly. Thanks Salvador!

*Originally published [on use Perl;]*

  [reported]: http://use.perl.org/user/Theory/journal/2658
  [here]: http://mathforum.org/epigone/modperl/rorphaltwin
  [Bricolage]: http://bricolage.thepirtgroup.com
  [here]: http://cvs.sourceforge.net/cgi-bin/viewcvs.cgi/bricolage/bricolage/lib/Bric/App/ApacheConfig.pm
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/2879/
    "use.perl.org journal of Theory: “mod_perl Bug Confirmed!”"
