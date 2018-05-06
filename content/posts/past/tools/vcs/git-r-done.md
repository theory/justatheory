--- 
date: 2009-04-29T03:18:25Z
slug: git-r-done
title: Git-R-Done
aliases: [/computers/vcs/git/git-r-done.html]
tags: [Git, Subversion, Bricolage, VCS, SCM, migrations, wikis, GitHub]
---

<p>Just a quick followup on the completion of
the <a href="/computers/vcs/git/bricolage-to-git.html" title="Migrating Bricolage CVS and SVN to Git">Bricolage Git migration</a> last week, today I
completed writing up a set
of <a href="http://wiki.github.com/bricoleurs/bricolage/development" title="Bricolage Wiki: Development">GitHub wiki documents</a> explaining to my
fellow Bricoleurs how to start hacking. The most important bits are:</p>

<ul>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/working-with-git">Working with Git</a>, explaining how to get set up with a forked Bricolage repository</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/contributing-a-bug-fix">Contributing a Bug Fix</a>, an intro to the Git way of doing things (as far as I understand it)</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/working-with-branches">Working with Branches</a>, describing how to track a maintenance branch in your fork</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/merging-with-git">Merging with Git</a>, to cover the frequent merging from Bricolage maintenance branches into master, and how to get said merges pushed upstream</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/starting-a-project-branch">Starting a Project Branch</a>, which you'd need to read if you were taking on a major development task, such as a Summer of Code project</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/contributing-via-email">Contributing via Email</a>, for those who don't want a GitHub account (needs fleshing out)</li>
  <li><a href="http://wiki.github.com/bricoleurs/bricolage/creating-a-release">Creating a Release</a>, in which the fine art of branching, tagging, and releasing is covered</li>
</ul>

<p>If you're familiar with the “Git way,” I would greatly appreciate your feedback on these documents. Corrections and comments would be greatly appreciated.</p>

<p>I also just wanted to say that the process of reconstructing the merge
history from CVS and Subversion was quite an eye-opener for me. Not because it
was difficult (it was) and required a number of hacks (it did), but because it
highlighted just how much better a fit Git is for the way in which we do Open
Source software development. Hell, probably closed-source, too, for that
matter. I no longer will have to think about what revisions to include in a
merge, or create a branch just to “tag” a merge. Hell, I'll probably be doing
merges a hell of a lot more often, just because it's so easy, the history
remains intact, and everything just stays more up-to-date and closely
integrated.</p>

<p>But I also really appreciate the project-based emphasis of Git. A
Subversion repository, I now realize, is really very much like a versioned
file system. That means where things go is completely ad-hoc, or
convention-driven at best. And god forbid if you decide to change the
convention and move stuff around! It's just <em>so</em> much more sane to get
a project repository, with all of the history, branches, tags, merges, and
everything else, all in one package. It's more portable, it's a hell of a lot
faster (ever tried to check out a Subversion repository with 80 tags?), and
just <em>tighter</em>. it encourages modularization, which can only be good.
I'll tell you, I expect to have some frustrations and challenges as I learn
more about using Git, but I'm already very much happier with the overall
philosophy.</p>

<p>Enough evangelizing. As a last statement on this, I've uploaded the Perl
scripts I wrote to do this migration, just in case someone else finds them
useful:</p>

<ul>
  <li><a href="/computers/vcs/git/bricolage-migration/bric_cvs_to_git">bric_cvs_to_git</a> migrated a CVS backup to Git.</li>
  <li><a href="/computers/vcs/git/bricolage-migration/bric_to_git">bric_to_git</a> migrated Subversion from r5517 to Git.</li>
  <li><a href="/computers/vcs/git/bricolage-migration/stitch">stitch</a> stitched the CVS-migrated Git repository into the Subversion-migrated Git repository for a final product.</li>
</ul>

<p>It turned out that there were a
few <a href="http://github.com/bricoleurs/bricolage/commit/95c2335634a64fc68745629d5242cad5b1c69d48">files lost</a> in the conversion, which I didn't notice until after all was said and
done, but overall I'm very happy. My thanks again
to <a href="http://www.askask.com/">Ask</a> and the denizens of #git for all
the help.</p>


<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/vcs/git/git-r-done.html">old layout</a>.</small></p>


