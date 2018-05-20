--- 
date: 2009-04-17T05:59:20Z
slug: bricolage-cvs-to-git
title: Migrating Bricolage CVS to Git
aliases: [/computers/vcs/git/bricolage-cvs-to-git.html]
tags: [Bricolage, Git, Subversion, CVS, SCM]
type: post
---

Following a [discussion] on the Bricolage developers mail list, I started down
the path last week of migrating the Bricolage Subversion repository to Git. This
turned out to be much more work than I expected, but to the benefit of the
project, I think. Since I had a lot of questions about how to do certain things
and how Git thinks about certain things, I wanted to record what I worked out
here over the course of a few entries. Maybe it will help you manage your
migration to Git.

The first thing I tried to do was use `git-svn` to migrate Bricolage to Git. I
pointed it to the [root directory] and let it rip. I immediately saw that it
noticed that the root was originally at the root of the repository, rather than
the “bricolage” subdirectory, and so followed that path and started pulling
stuff down. In a separate terminal window, I was watching the branches build up,
and there were a *lot* of them, many named like:

    David
    David@5248
    David@584
    tags/Release_1_2_1
    tags/Release_1_2_1@5249
    tags/Release_1_2_1@577

Although many of those branches and tags hadn't been used since the beginning of
time, and certainly not since Bricolage was moved to Subversion from its
[original home] in SourceForge CVS, because Subversion has no real concept of
branches or tags, `git-svn` was duly copying them *all*, including the separate
histories for each. Yow.

I could have dealt with that, renaming things, deleting others, and grafting
where appropriate (more on grafting in a minute), but then I got this error from
`git-svn`:

    bricolage/branches/rev_1_8/lib/Bric/App/ApacheConfig.pm was not
    found in commit e5145931069a511e98a087d4cb1a8bb75f43f899 (r5256)

This was annoying, especially since the file clearly *does* exist in that
commit:

    svn list -r5256 http://svn.bricolage.cc/bricolage/branches/rev_1_8/lib/Bric/App/ApacheConfig.pm
    ApacheConfig.pm

I [posted] to the Git mail list about this issue, but unfortunately got no
reply. Given that it was taking around 30 hours(!) to get to that point (and
about 18 hours once I started using a local copy of the Subversion repository,
thank to a suggestion from [Ask Bjørn Hansen]), I started thinking about how to
simplify things a bit.

Since most of the moving stuff around happened immediately after the move to
Subversion, and before we started committing working code to the repository, it
occurred to me that I could probably go back to the original [Bricolage CVS
Repository][original home] on SourceForge, migrate *that* to Git, and then just
migrate from Subversion starting from the first real commit there. Then I could
just [stitch the two repositories together].

### From CVS to Git

Thanks to advice from IRC, I used [`cvs2git`] to build a repository from a dump
from CVS. Apparently, `git cvsimport` makes a lot of mistakes, while `cvs2git`
does a decent job keeping branches and tags where they should be. It's also
pretty fast; once I set up its configuration and ran it, it took only around 5
minutes for it to build import files for `git fast-import`. It also has some
nice features to rename symbols (tags), ignore tags, assign authors, etc. I'm
aware of not tool to migrate Subversion to Git that does the same thing.

Once I had my dump, I started writing a script to import it into Git. The basic
import looks like this:

    GITREPO=/Users/david/Desktop/git_from_cvs
    rm -rf $GITREPO
    mkdir $GITREPO
    chdir $GITREPO
    git init
    cat ../cvs2svn-tmp/git-blob.dat ../cvs2svn-tmp/git-dump.dat | git fast-import
    svn2git --no-clone
    git gc
    git reset --hard

I used [svn2git] to convert remote branches to local tags and branches The
`--no-clone` option is what keeps it from doing the Subversion stuff; everything
else is the same for a new conversion from CVS. I also had to run
`git reset --hard` to throw out uncommitted local changes. What changes? I'm not
sure where they came from, but after the last commit is imported from CVS, all
of the local files in the master branch are deleted, but that change is not
committed. Strange, but by doing a hard reset, I reverted that change with no
harm done.

Next, I started looking at the repository in [GitX], which provides a decent
graphical interface for browsing around a Git repository on Mac OS X. There I
discovered that a major benefit to importing from CVS rather than Subversion is
that, because CVS has real tags, those tags are properly migrated to Git. What
this means is that, because the Bricolage project (nearly) always tagged merges
between branches and included the name of the appropriate tag name in a merge
commit message, I was able to reconstruct the merge history in Git.

For example, there were a lot of tags named like so:

    % git tag
    rev_1_8_merge-2004-05-04
    rev_1_6_merge-2004-05-02
    rev_1_6_merge-2004-04-10
    rev_1_6_merge-2004-04-09
    rev_1_6_merge-2004-03-16

So if I wanted to find the merge commit that corresponded to that first tag, all
I had to do was sort the commits in GitX by date and look near 2004-05-04 for a
commit message that said something like:

    Merge from rev_1_8. Will tag that branch "rev_1_8_merge-2004-05-04".

That commit's SHA key is “b786ad1c0eeb9df827d658a81dc2d32ec6108e92”. Its
parent's SHA key is “11dbbd49644aaa607bd83f8d542d37fcfbd5e63b”. So then all I
had to do was to tell git that there is a second parent for that commit. Looking
in GitX for the commit tagged “rev\_1\_8\_merge-2004-05-04”, I found that its
SHA key is “4fadb117a71a49add69950eccc14b77a04c8ec68”. So to assign that as a
second parent, I write a line to the file `.git/info/grafts` that describes its
parentage:

    b786ad1c0eeb9df827d658a81dc2d32ec6108e92 11dbbd49644aaa607bd83f8d542d37fcfbd5e63b 4fadb117a71a49add69950eccc14b77a04c8ec68

Once I had all the grafts written, I just ran `git filter-branch` and they were
permanently rewritten to the new hierarchy.

And that's it! The parentage is now correct. It was a lot of busy work to create
the mapping between tags and merges, but it's nice to have it all done and
properly mapped out historically in Git. I even found a bunch merges with no
corresponding tags and figured out the proper commit to link them up to (though
I stopped when I got back to 2002 and things get really confusing). And now,
because the merge relationships are now properly recorded in Git, I can drop
those old merge tags: as workarounds for a lack of merge tracking in CVS, they
are no longer necessary in Git.

Next up, how I completed the merge from Subversion. I'll write that once I've
finally got it nailed down. Unfortunately, it takes an hour or two to export
from Subversion to Git, and I'm having to do it over and over again as I figure
stuff out. But it will be done, and you'll hear more about it here.

  [discussion]: http://marc.info/?t=123886317200001
    "Bricolage Developer List Archive: “GitHub?”"
  [root directory]: http://svn.bricolage.cc/bricolage/
  [original home]: http://bricolage.cvs.sourceforge.net/viewvc/bricolage/bricolage/
    "Bricolage SourceForge CVS Browser"
  [posted]: http://marc.info/?l=git&m=123964663024277
    "Git Mail List: “Again with git-svn: File was not found in commit”"
  [Ask Bjørn Hansen]: http://www.askask.com/
  [stitch the two repositories together]: http://www.ouaza.com/wp/2007/07/24/assembling-bits-of-history-with-git/
    "Buxy rêve tout haut: “Assembling bits of history with git”"
  [`cvs2git`]: http://cvs2svn.tigris.org/cvs2git.html
  [svn2git]: http://github.com/schwern/svn2git/tree/ "svn2git on GitHub"
  [GitX]: http://gitx.frim.nl/
