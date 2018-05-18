--- 
date: 2009-04-23T18:15:06Z
slug: bricolage-svn-to-git
title: Migrating Bricolage Subversion to Git
aliases: [/computers/vcs/git/bricolage-svn-to-git.html]
tags: [Bricolage, Git, Subversion, CVS, SCM]
type: post
---

<p>Following up on last
week's <a href="/computers/vcs/git/bricolage-cvs-to-git.html" title="Migrating Bricolage CVS to Git">post</a> on migrating the old Bricolage SourceForge CVS
repository to Git, here are my notes on migrating the
current <a href="http://svn.bricolage.cc/">Bricolage Subversion repository</a> to Git.</p>

<p>It turns out that migrating from Subversion is much more of a pain than
migrating from CVS. Why? Because CVS has real tags, while Subversion does not.
So while <code>git-svn</code> tries to identify all of your tags and branches,
it's really relying on your Subversion repository using standard directories
for all of your branches and tags. And while we've used a standard
for <a href="http://svn.bricolage.cc/bricolage/branches/">branches directory</a>,
our <a href="http://svn.bricolage.cc/bricolage/tags/">tags setup</a> is a
<em>bit</em> more complicated.</p>

<p>The problem was that we used tags every time we merged between branches.
This meant that we ended up with a lot of tags with names like
“merge_rev_1_10_5665” to indicate a merge from the “rev_1_10” branch into
trunk at r5665. Plus we had tags for releases.
So <a href="http://www.exclupen.com/" title="Marshall Roch">Marshall</a> took
it upon himself to reorganize the tags in the Subversion tree so that all
release tags went into the “releases” subdirectory, and merges went into
subdirectories named for the branch from which the merge derived. Those
subdirectories went into the “merges” subdirectory. We ended up with a
directory structure organized like this:</p>

<pre>
/tags/
  /releases/
    /1.10.1/
    /1.10.2/
    /1.10.3/
  /merges/
    /dev_ajax/
      /trunk-7890
    /rev_1_10/
      /trunk-7043/
      /trunk-7194/
      /trunk-7300/
</pre>

<p>This was useful for keeping things organized in Subversion, so that we
could easily find a tag for a previous merge in order to determine the
revisions to specify for a new merge. But because older tags were moved from
previous locations, and because newer tags were in subdirectories of the
“tags” directory, <code>git-svn</code> did not identify them as tags. Well,
that's not really fair. It <em>did</em> identify earlier tags, before they
were moved, but all the other tags were not found. Instead I ended up with
tags in Git named <code>tags/releases</code> and <code>tags/merges</code>,
which was useless. But even if all of our tags had been identified as tags,
none had parent commit IDs, so there was no place to see where they actually
came from.</p>

<p>So to rebuild the commit, release, and merge history from Subversion, I
first created a local copy of the subversion repository
using <code>svnsync</code>. Then I cloned it to Git like so:</p>

<pre>
SVNREPO=file:///Users/david/svn_bricolage_cc
git svn init $SVNREPO &#x002d;&#x002d;stdlayout
git config svn.authorsfile /Users/david/bric_authors.txt
git svn fetch &#x002d;&#x002d;no-follow-parent &#x002d;&#x002d;revision 5517:HEAD
</pre>

<p>By starting with r5517, which was the first real commit to Subversion, I
avoided the <code>git-svn</code> error
I <a href="http://marc.info/?t=123964664700006" title="Git Mail List: “Again with git-svn: File was not found in commit”">reported last week</a>. In truth, though, I ended up running this clone many, <em>many</em>
times. The first few times, I ran it with <code>&#x002d;&#x002d;no-metadata</code>,
as <a href="http://www.simplisticcomplexity.com/2008/03/05/cleanly-migrate-your-subversion-repository-to-a-git-repository/" title="Simplistic Complexity: “Cleanly Migrate Your Subversion Repository To a GIT Repository”">recommended</a>
in various HOWTOs. But then I kept getting errors such as:</p>

<pre>
git svn log
fatal: bad default revision &#x0027;refs/remotes/git-svn&#x0027;
&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;&#x002d;
</pre>

<p>This was more than a little annoying, and it took me a day or so to realize
that this was because I had been using <code>&#x002d;&#x002d;no-metadata</code>. Once I
killed off that option, things worked much better</p>

<p>Furthermore, by starting at r5517 and passing the
<code>&#x002d;&#x002d;no-follow-parent</code> option, <code>git-svn</code> ran much more
quickly. Rather than taking 30 hours to get all revisions including stuff that
had been moved around (and then failing), it now took around 90 minutes to do
the export. Much more manageable, although I also started making backup copies
and restoring from them as I experimented with fixing branches and tags.
Ultimately, I ended up also passing the <code>&#x002d;&#x002d;ignore-paths</code> option, to
exclude various branches that were never really used or that I had already
fetched in their entirety from CVS:</p>

<pre>
git svn fetch &#x002d;&#x002d;no-follow-parent &#x002d;&#x002d;revision 5517:HEAD \
&#x002d;&#x002d;ignore-paths &#x0027;(David|Kineticode|Release_|dev_(callback|(media_)?templates)|rev_1_([024]|[68]_temp)|tags/(Dev-|Release_|Start|help|mark|rel_1_([24567]|8_0)|rev_1_([26]|8_merge-2004-05-04)))|tmp&#x0027;
svn2git &#x002d;&#x002d;no-clone
</pre>

<p>The call to <a href="http://github.com/schwern/svn2git/tree/" title="svn2git on GitHub">svn2git</a> converts remote branches to local tags
and branches. Now I had a reasonably clean copy of the repository (aside from
the 120 or so commits from when Marshall did the tags reorganization) for me
to work with. I opened it up with <a href="http://gitx.frim.nl/">GitX</a> and
started scripting out merges.</p>

<p>To assist in this, I took a hint from <a href="http://www.askask.com/">Ask Bjørn Hansen</a>, sent in email in response to a Tweet, and tagged every
single commit with its corresponding Subversion revision number, like so (in
Perl):</p>

<pre>
for my $c (`git rev-list &#x002d;&#x002d;all &#x002d;&#x002d;date-order &#x002d;&#x002d;timestamp | sort -n | awk &#x0027;{print \$2}&#x0027;`) {
    chomp $c;
    my ($svnid) = `git show -s $c | tail -1` =~ /[@](\d+)\s+/;
    system qw(git tag -f), $svnid, $c;
}
</pre>

<p>The nice thing about this is that it made it easy for me to scan through
the commits in GitX and see where things were. It also meant that I could
reference these tags when I wrote the code to manage the merges. So what I did
was sort the commits in reverse chronological order, and then search for those
with the word “merge” in their subjects. When one was clearly for a merge (as
opposed to simply using the word “merge”), I would disable the search, scroll
through the commits until I found the selected commit, and then look for
a likely prior commit that it merged from.</p>

<p>This was a bit of pain in the ass, because, unfortunately, GitX doesn't
keep the selected commit record in the middle of the screen when you cancel
the search. Mail.app does this right: If I do a search, select a message, then
cancel the search, the selected message is still in the middle of the screen.
But with GitX, as I said, I have to scroll to find it. This wasn't going to
scale very well. So what I did instead was search for “merge”, then I took a
screen shot of the results and cancelled the merge. Then I just opened the
screenshot in Preview, looked at the records there, then found them in GitX.
This made things go quite a bit faster.</p>

<figure><img src="/2009/04/bricolage-svn-to-git/merges.gif" alt="Commits that mention merging in GitX" /></figure>

<p>As a result, I added a migration function to properly tag merges. It looked
like this:</p>

<pre>
sub graft_merges {
    print &quot;Grafting merges\n&quot;;
    # Handle the merges.
    for my $graft (
        [qw( trunk@5524   rev_1_8@5523 )],
        [qw( trunk@5614   rev_1_8@5613 )],
        [qw( rev_1_8@5591 trunk@5590   )],
    ) {
        my ($commit, $parent) = map { s/.+[@]//; $_ } @$graft;
        my $cmd = &quot;\$(git rev-parse $commit) &quot;
                . &quot;\$(git rev-parse $commit^) &quot;
                . &quot;\$(git rev-parse $parent)&quot;;
        `echo &quot;$cmd&quot; >> .git/info/grafts`;
    }
}
</pre>

<p>By referencing revision tags explicitly, I was able to just use <code>git rev-parse</code>
to look up SHA1 hash IDs to put into
<code>.git/info/grafts</code>. This saved me the headache of dealing with very
long IDs, but also allowed me to easily keep track of revision numbers and
branches (the branch information is actually superfluous here, but I kept it
for my sanity). So, basically, for <code>[qw( trunk@5524 rev_1_8@5523
)]</code>, it ends up writing the SHA1 hashes for r5524, the existing parent
commit for r5524 (that's the <code>$commit^</code> bit), and for the new
parent, r5523. I ended up with 73 merges that needed to be properly
recorded.</p>

<p>With the merges done, I next dove into branches. For some
reason, <code>git-svn</code> failed to identify a parent commit
for <em>any</em> branch. Maybe because I started with r5517? I have no idea.
So I had to search through the commits to see when branches were started. I
mainly did this by looking at the branches
in <a href="http://viewsvn.bricolage.cc/bricolage/branches/" title="Bricolage Branches in ViewVC">ViewVC</a>. By clicking each one, I was able to see the
earliest commit, which usually had a name like “Created a branch for my SoC
project.” I would then look up that commit in ViewVC, such
as <a href="http://viewsvn.bricolage.cc/?view=revision&amp;revision=7423">r7423</a>,
which started the “dev_ajax” branch, just to make sure that it was copied from
trunk. Then I simply went into GitX, found r7423, then looked back to the last
commit to trunk before r7423. That was the parent of the branch. With such
data, I was able to write a function like this:</p>

<pre>
sub graft_branches {
    print &quot;Grafting branches\n&quot;;
    for my $graft (
        [qw( dev_ajax@7423            trunk@7301 )],
        [qw( dev_mysql@7424           trunk@7301 )],
        [qw( dev_elem_occurrence@7427 trunk@7301 )],
    ) {
        my ($commit, $parent) = map { s/.+[@]//; $_ } @$graft;
        my $cmd = &quot;\$(git rev-parse $commit) &quot;
                . &quot;\$(git rev-parse $parent)&quot;;
        `echo &quot;$cmd&quot; >> .git/info/grafts`;
    }
}
</pre>

<p>Here I only needed to look up the revision and its parent and write it
to <code>.git/info/grafts</code>. Then all of my branches had parents. Or
nearly all of them; those that were also in the old CVS repository will have
to wait until the two are stitched together to find their parents.</p>

<p>Next I needed to get releases properly tagged. This was not unlike the
merge tag work: I just had to find the proper revision and tag it. This time,
I looked through the commits in GitX for those with “tag for” in their
subjects because, conveniently, I nearly always used this phrase in a release
tag, as in “Tag for the 1.8.11 release of Bricolage.” Then I just looked back
from the tag commit to find the commit copied to the tag, and <em>that</em>
commit would be tagged with the release tag. The function to create the tags
looked like this:</p>

<pre>
sub tag_releases {
    print &quot;Tagging releases\n&quot;;
    for my $spec (
        [ &#x0027;rev_1_8@5726&#x0027; => &#x0027;v1.8.1&#x0027;  ],
        [ &#x0027;rev_1_8@5922&#x0027; => &#x0027;v1.8.2&#x0027;  ],
        [ &#x0027;rev_1_8@6073&#x0027; => &#x0027;v1.8.3&#x0027;  ],
    ) {
        my ($where, $tag) = @{$spec};
        my ($branch, $rev) = split /[@]/, $where;
        my $tag_date = `git show &#x002d;&#x002d;pretty=format:%cd -s $rev`;
        chomp $tag_date;
        local $ENV{GIT_COMMITTER_DATE} = $tag_date;
        system qw(git tag -fa), $tag, &#x0027;-m&#x0027;, &quot;Tag for $tag release of Bricolage.&quot;, $rev;
    }
}
</pre>

<p>I am again indebted to <a href="http://www.askask.com/">Ask</a> for the
code here, especially to set the date for the tag.</p>

<p>Since I had created new release tags and recreated the merge history in
Git, I no longer needed the old tags from Subversion, so next I rewrote
the <code>&#x002d;&#x002d;ignore-paths</code> option to exclude all of the tags directories,
as well as some branches that were never used:</p>

<pre>
SVNREPO=file:///Users/david/svn_bricolage_cc
git svn init $SVNREPO &#x002d;&#x002d;stdlayout
git config svn.authorsfile /Users/david/bric_authors.txt
git svn fetch &#x002d;&#x002d;no-follow-parent &#x002d;&#x002d;revision 5517:HEAD
git svn fetch &#x002d;&#x002d;no-follow-parent &#x002d;&#x002d;revision 5517:HEAD \
&#x002d;&#x002d;ignore-paths &#x0027;(David|Kineticode|Release_|dev_(callback|(media_)?templates)|rev_1_([024]|[68]_temp)|tags/)|tmp&#x0027;;
</pre>

<p>With this in hand, I killed off the call to <code>svn2git</code>, opting to
convert trunk and the remote branches myself (easily done by
copying-and-pasting the relevant Perl code). Then all I needed to do was clean
up the extant tags and run <code>git-filter-branch</code> to make the grafts
permanent:</p>

<pre>
sub finish {
    print &quot;Deleting old tags\n&quot;;
    my @tags = grep m{^tags/}, map { s/^\s+//; s/\s+$//; $_ } `git branch -a`;
    system qw(git branch -r -D), $_ for @tags;

    print &quot;Deleting revision tags\n&quot;;
    @tags_to_delete = grep { /^\d+$/ } map { s/^\s+//; s/\s+$//; $_ } `git tag`;
    system qw(git tag -d), $_ for @tags_to_delete;

    print &quot;Grafting...\n&quot;;
    system qw(git filter-branch);
    system qw(git gc);
}
</pre>

<p>And now I have a nicely organized Git repository based on the Bricolage
Subversion repository, with all (or most) merges in their proper places,
release tags, and branch tracking. Now all I have to do is stitch it together
with the repository <a href="/computers/vcs/git/bricolage-cvs-to-git.html" title="Migrating Bricolage CVS to Git">based on CVS</a> and I'll be ready
to put this sucker on GitHub! More on that in my next post.</p>
