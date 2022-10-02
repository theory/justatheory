---
date: 2002-02-22T02:14:38Z
description: Bricolage is moving fast!
lastMod: 2022-10-02T22:39:29Z
slug: release-release-release
tags:
  - use Perl
  - Perl
  - Bricolage
title: 'Release, Release, Release!'
---

Well, I got Bricolage 1.3.0 out yesterday. It's a development release for the
upcoming 1.4.0 release. There are two major new features in 1.3.0. The big one
is a SOAP server. [Sam Tregar] has been hard at work on this puppy. It promises
to simplify the process of autopublishing stories, and to make importing and
exporting assets and elements a no-brainer. I say kudos to Sam for his hard
work.

The second major new feature is a real live configure process. Mark Jaroski of
the World Health Organization developed this for us using Autoconf.
Unfortunately, it wasn't ready in time for the 1.3.0 release, but it's already
looking better and should be in 1.3.1 in a couple of days. Meanwhile, I need to
get 1.2.1 out. This is mostly a bug-fix release of Bricolage, although there is
one new feature. A new module greatly simplifies the process of Apache
configuration, making it easy to, among other things, run Bricolage on a virtual
host. The one drawback to this feature is that it relies heavily on mod_perl
`<Perl>` sections, and these are somewhat [broken], although there is a [patch].
Other than that, there are loads of bug fixes in 1.2.1, so look for it soon!

*Originally published [on use Perl;]*

  [Sam Tregar]: http://use.perl.org/user/samtregar/
  [broken]: http://use.perl.org/user/Theory/journal/2879
  [patch]: http://mathforum.org/epigone/modperl/rorphaltwin/1013661847.9431.102.camel@monica
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/3024/
    "use.perl.org journal of Theory: “Release, Release, Release!”"
