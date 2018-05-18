--- 
date: 2009-04-17T05:59:20Z
slug: bricolage-cvs-to-git
title: Migrating Bricolage CVS to Git
aliases: [/computers/vcs/git/bricolage-cvs-to-git.html]
tags: [Bricolage, Git, Subversion, CVS, SCM]
type: post
---

<p>Following a <a href="http://marc.info/?t=123886317200001" title="Bricolage Developer List Archive: “GitHub?”">discussion</a> on the Bricolage developers
mail list, I started down the path last week of migrating the Bricolage
Subversion repository to Git. This turned out to be much more work than I
expected, but to the benefit of the project, I think. Since I had a lot of
questions about how to do certain things and how Git thinks about certain
things, I wanted to record what I worked out here over the course of a few
entries. Maybe it will help you manage your migration to Git.</p>

<p>The first thing I tried to do was use <code>git-svn</code> to migrate
Bricolage to Git. I pointed it to the
<a href="http://svn.bricolage.cc/bricolage/">root directory</a> and let it
rip. I immediately saw that it noticed that the root was originally at the
root of the repository, rather than the “bricolage” subdirectory, and so
followed that path and started pulling stuff down. In a separate terminal
window, I was watching the branches build up, and there were a <em>lot</em> of
them, many named like:</p>

<pre>
David
David@5248
David@584
tags/Release_1_2_1
tags/Release_1_2_1@5249
tags/Release_1_2_1@577
</pre>

<p>Although many of those branches and tags hadn't been used since the
beginning of time, and certainly not since Bricolage was moved to Subversion
from its
<a href="http://bricolage.cvs.sourceforge.net/viewvc/bricolage/bricolage/" title="Bricolage SourceForge CVS Browser">original home</a> in SourceForge
CVS, because Subversion has no real concept of branches or
tags, <code>git-svn</code> was duly copying them <em>all</em>, including the
separate histories for each. Yow.</p>

<p>I could have dealt with that, renaming things, deleting others, and
grafting where appropriate (more on grafting in a minute), but then I got this
error from <code>git-svn</code>:</p>

<pre>
bricolage/branches/rev_1_8/lib/Bric/App/ApacheConfig.pm was not
found in commit e5145931069a511e98a087d4cb1a8bb75f43f899 (r5256)
</pre>

<p>This was annoying, especially since the file clearly <em>does</em> exist in
that commit:</p>

<pre>
svn list -r5256 http://svn.bricolage.cc/bricolage/branches/rev_1_8/lib/Bric/App/ApacheConfig.pm
ApacheConfig.pm
</pre>

<p>I <a href="http://marc.info/?l=git&amp;m=123964663024277" title="Git Mail List: “Again with git-svn: File was not found in commit”">posted</a>
to the Git mail list about this issue, but unfortunately got no reply. Given
that it was taking around 30 hours(!) to get to that point (and about 18 hours
once I started using a local copy of the Subversion repository, thank to a
suggestion from <a href="http://www.askask.com/">Ask Bjørn Hansen</a>), I
started thinking about how to simplify things a bit.</p>

<p>Since most of the moving stuff around happened immediately after the move
to Subversion, and before we started committing working code to the
repository, it occurred to me that I could probably go back to the original
<a href="http://bricolage.cvs.sourceforge.net/viewvc/bricolage/bricolage/" title="Bricolage SourceForge CVS Browser">Bricolage CVS Repository</a> on
SourceForge, migrate <em>that</em> to Git, and then just migrate from
Subversion starting from the first real commit there. Then I could just
<a href="http://www.ouaza.com/wp/2007/07/24/assembling-bits-of-history-with-git/" title="Buxy rêve tout haut: “Assembling bits of history with git”">stitch the
two repositories together</a>.</p>

<h3>From CVS to Git</h3>

<p>Thanks to advice from IRC, I used
<a href="http://cvs2svn.tigris.org/cvs2git.html"><code>cvs2git</code></a> to
build a repository from a dump from CVS. Apparently, <code>git
cvsimport</code> makes a lot of mistakes, while <code>cvs2git</code> does a
decent job keeping branches and tags where they should be. It's also pretty
fast; once I set up its configuration and ran it, it took only around 5
minutes for it to build import files for <code>git fast-import</code>. It also
has some nice features to rename symbols (tags), ignore tags, assign authors,
etc. I'm aware of not tool to migrate Subversion to Git that does the same
thing.</p>

<p>Once I had my dump, I started writing a script to import it into Git. The
basic import looks like this:</p>

<pre>
GITREPO=/Users/david/Desktop/git_from_cvs
rm -rf $GITREPO
mkdir $GITREPO
chdir $GITREPO
git init
cat ../cvs2svn-tmp/git-blob.dat ../cvs2svn-tmp/git-dump.dat | git fast-import
svn2git &#x002d;&#x002d;no-clone
git gc
git reset &#x002d;&#x002d;hard
</pre>

<p>I used <a href="http://github.com/schwern/svn2git/tree/" title="svn2git on GitHub">svn2git</a> to convert remote branches to local
tags and branches The <code>&#x002d;&#x002d;no-clone</code> option is what keeps it from
doing the Subversion stuff; everything else is the same for a new conversion
from CVS. I also had to run <code>git reset &#x002d;&#x002d;hard</code> to throw out
uncommitted local changes. What changes? I'm not sure where they came from,
but after the last commit is imported from CVS, all of the local files in the
master branch are deleted, but that change is not committed. Strange, but by
doing a hard reset, I reverted that change with no harm done.</p>

<p>Next, I started looking at the repository in
<a href="http://gitx.frim.nl/">GitX</a>, which provides a decent graphical
interface for browsing around a Git repository on Mac OS X. There I discovered
that a major benefit to importing from CVS rather than Subversion is that,
because CVS has real tags, those tags are properly migrated to Git. What this
means is that, because the Bricolage project (nearly) always tagged merges
between branches and included the name of the appropriate tag name in a merge
commit message, I was able to reconstruct the merge history in Git.</p>

<p>For example, there were a lot of tags named like so:</p>

<pre>
% git tag
rev_1_8_merge-2004-05-04
rev_1_6_merge-2004-05-02
rev_1_6_merge-2004-04-10
rev_1_6_merge-2004-04-09
rev_1_6_merge-2004-03-16
</pre>

<p>So if I wanted to find the merge commit that corresponded to that first
tag, all I had to do was sort the commits in GitX by date and look near
2004-05-04 for a commit message that said something like:</p>

<pre>
Merge from rev_1_8. Will tag that branch &quot;rev_1_8_merge-2004-05-04&quot;.
</pre>

<p>That commit's SHA key is “b786ad1c0eeb9df827d658a81dc2d32ec6108e92”. Its
parent's SHA key is “11dbbd49644aaa607bd83f8d542d37fcfbd5e63b”. So then all I
had to do was to tell git that there is a second parent for that commit.
Looking in GitX for the commit tagged “rev_1_8_merge-2004-05-04”, I found that
its SHA key is “4fadb117a71a49add69950eccc14b77a04c8ec68”. So to assign that
as a second parent, I write a line to the file <code>.git/info/grafts</code>
that describes its parentage:</p>

<pre>
b786ad1c0eeb9df827d658a81dc2d32ec6108e92 11dbbd49644aaa607bd83f8d542d37fcfbd5e63b 4fadb117a71a49add69950eccc14b77a04c8ec68
</pre>

<p>Once I had all the grafts written, I just ran <code>git
filter-branch</code> and they were permanently rewritten to the new
hierarchy.</p>

<p>And that's it! The parentage is now correct. It was a lot of busy work to
create the mapping between tags and merges, but it's nice to have it all done
and properly mapped out historically in Git. I even found a bunch merges with
no corresponding tags and figured out the proper commit to link them up to
(though I stopped when I got back to 2002 and things get really confusing).
And now, because the merge relationships are now properly recorded in Git, I
can drop those old merge tags: as workarounds for a lack of merge tracking in
CVS, they are no longer necessary in Git.</p>

<p>Next up, how I completed the merge from Subversion. I'll write that once
I've finally got it nailed down. Unfortunately, it takes an hour or two to
export from Subversion to Git, and I'm having to do it over and over again as
I figure stuff out. But it will be done, and you'll hear more about it
here.</p>
