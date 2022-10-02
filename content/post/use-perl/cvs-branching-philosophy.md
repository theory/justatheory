---
date: 2002-01-24T02:08:00Z
description: Is there no right way?
lastMod: 2022-10-02T22:39:29Z
slug: cvs-branching-philosophy
tags:
  - use Perl
  - Perl
  - CVS
title: CVS Branching Philosophy
---

"This will go down in [my] permanent record," eh? I guess I'd better make it
good.

There's been quite the [debate] going on over on the Bricolage developers list.
For those who don't know about Bricolage, its a full-featured, open-source, 100%
Perl content management system that I maintain on SourceForge. You can learn
more about it [here].

Anyway, the debate is over the art and science of CVS management. We've been
adding features to both minor and major releases up to now, but there has been
substantial argument that the minor releases should be bug-fix only. The
advantage of this approach is that new code won't threaten stable releases. The
disadvantage is that it could slow development. Quick and easy new features will
have to wait for more involved features to be complete before they can see the
light of day of a release.

There are some strong opinions, but I'm currently sitting on the fence. More
opinions are welcome!

*Originally published [on use Perl;]*

  [debate]: http://www.geocrawler.com/mail/thread.php3?subject=%5BBricolage-Devel%5D+More+on+Releases&list=15308
  [here]: http://bricolage.thepirtgroup.com/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/2363/
    "use.perl.org journal of Theory: “CVS Branching Philosophy”"
