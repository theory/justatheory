--- 
date: 2009-04-29T03:18:25Z
slug: git-r-done
title: Git-R-Done
aliases: [/computers/vcs/git/git-r-done.html]
tags: [Git, Subversion, Bricolage, VCS, SCM, Migrations, Wikis, GitHub]
type: post
---

Just a quick followup on the completion of the [Bricolage Git migration] last
week, today I completed writing up a set of [GitHub wiki documents] explaining
to my fellow Bricoleurs how to start hacking. The most important bits are:

-   [Working with Git], explaining how to get set up with a forked Bricolage
    repository
-   [Contributing a Bug Fix], an intro to the Git way of doing things (as far as
    I understand it)
-   [Working with Branches], describing how to track a maintenance branch in
    your fork
-   [Merging with Git], to cover the frequent merging from Bricolage maintenance
    branches into master, and how to get said merges pushed upstream
-   [Starting a Project Branch], which you'd need to read if you were taking on
    a major development task, such as a Summer of Code project
-   [Contributing via Email], for those who don't want a GitHub account (needs
    fleshing out)
-   [Creating a Release], in which the fine art of branching, tagging, and
    releasing is covered

If you're familiar with the “Git way,” I would greatly appreciate your feedback
on these documents. Corrections and comments would be greatly appreciated.

I also just wanted to say that the process of reconstructing the merge history
from CVS and Subversion was quite an eye-opener for me. Not because it was
difficult (it was) and required a number of hacks (it did), but because it
highlighted just how much better a fit Git is for the way in which we do Open
Source software development. Hell, probably closed-source, too, for that matter.
I no longer will have to think about what revisions to include in a merge, or
create a branch just to “tag” a merge. Hell, I'll probably be doing merges a
hell of a lot more often, just because it's so easy, the history remains intact,
and everything just stays more up-to-date and closely integrated.

But I also really appreciate the project-based emphasis of Git. A Subversion
repository, I now realize, is really very much like a versioned file system.
That means where things go is completely ad-hoc, or convention-driven at best.
And god forbid if you decide to change the convention and move stuff around!
It's just *so* much more sane to get a project repository, with all of the
history, branches, tags, merges, and everything else, all in one package. It's
more portable, it's a hell of a lot faster (ever tried to check out a Subversion
repository with 80 tags?), and just *tighter*. it encourages modularization,
which can only be good. I'll tell you, I expect to have some frustrations and
challenges as I learn more about using Git, but I'm already very much happier
with the overall philosophy.

Enough evangelizing. As a last statement on this, I've uploaded the Perl scripts
I wrote to do this migration, just in case someone else finds them useful:

-   [bric\_cvs\_to\_git] migrated a CVS backup to Git.
-   [bric\_to\_git] migrated Subversion from r5517 to Git.
-   [stitch] stitched the CVS-migrated Git repository into the
    Subversion-migrated Git repository for a final product.

It turned out that there were a few [files lost] in the conversion, which I
didn't notice until after all was said and done, but overall I'm very happy. My
thanks again to [Ask] and the denizens of \#git for all the help.

  [Bricolage Git migration]: /computers/vcs/git/bricolage-to-git.html
    "Migrating Bricolage CVS and SVN to Git"
  [GitHub wiki documents]: http://wiki.github.com/bricoleurs/bricolage/development
    "Bricolage Wiki: Development"
  [Working with Git]: http://wiki.github.com/bricoleurs/bricolage/working-with-git
  [Contributing a Bug Fix]: http://wiki.github.com/bricoleurs/bricolage/contributing-a-bug-fix
  [Working with Branches]: http://wiki.github.com/bricoleurs/bricolage/working-with-branches
  [Merging with Git]: http://wiki.github.com/bricoleurs/bricolage/merging-with-git
  [Starting a Project Branch]: http://wiki.github.com/bricoleurs/bricolage/starting-a-project-branch
  [Contributing via Email]: http://wiki.github.com/bricoleurs/bricolage/contributing-via-email
  [Creating a Release]: http://wiki.github.com/bricoleurs/bricolage/creating-a-release
  [bric\_cvs\_to\_git]: /computers/vcs/git/bricolage-migration/bric_cvs_to_git
  [bric\_to\_git]: /computers/vcs/git/bricolage-migration/bric_to_git
  [stitch]: /computers/vcs/git/bricolage-migration/stitch
  [files lost]: http://github.com/bricoleurs/bricolage/commit/95c2335634a64fc68745629d5242cad5b1c69d48
  [Ask]: http://www.askask.com/
