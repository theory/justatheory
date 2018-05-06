--- 
date: 2009-04-24T17:24:40Z
slug: bricolage-to-git
title: Migrating Bricolage CVS and SVN to Git
aliases: [/computers/vcs/git/bricolage-to-git.html]
tags: [Bricolage, Git, Subversion, CVS, SCM, GitHub, migrations, VCS]
---

<p>Now that I've successfully
<a href="/computers/vcs/git/bricolage-cvs-to-git.html" title="Migrating Bricolage CVS to Git">migrated the old Bricolage SourceForge
CVS</a> repository to Git, and
also <a href="/computers/vcs/git/bricolage-svn-to-git.html" title="Migrating Bricolage Subversion to Git">migrated Subversion</a> to Git,
it's time to stitch the two repositories together into one with all history
intact. I'm glad to say that figuring out how to do so took substantially less
time than the first two steps, thanks in large part to the great help from
“doener,” “Ilari,” and “Fissure” on the Freenode #git channel.</p>

<p>Actually, they helped me with a bit more tweaking of my CVS and Subversion
conversions. One thing I realized after writing
<a href="/computers/vcs/git/bricolage-svn-to-git.html" title="Migrating Bricolage Subversion to Git">yesterday's post</a> was that, after running <code>git
filter-branch</code>, I had twice as many commits as I should have had. It
turns out that <code>git filter-branch</code> rewrites all commits, but keeps
the old ones around in case you mess something up. doener also pointed out
that I wasn't having all grafts properly applied, because <code>git
filter-branch</code> only applies to the currently checked-out branch. To get
all of the branches, he suggested that I read the
<a href="http://www.kernel.org/pub/software/scm/git/docs/git-filter-branch.html" title="git-filter-branch(1) Manual Page">git-filter-branch documentation</a>,
where I'll find that <code>git filter-branch &#x002d;&#x002d;tag-name-filter cat &#x002d;&#x002d;
&#x002d;&#x002d;all</code> would hit all branches. Actually, such was not clear to me from
the documentation, but I took his word for it. Once I did that, to get rid
of the dupes, all I had to do was <code>git clone</code> the repository
to a new repository. And that was that.</p>

<p>This worked great for my CVS migration, but I realized that I also wanted
to clean out metadata from the Subversion migration. Of course,
<code>git clone</code> throws out most of the metadata, but <code>git
svn</code> also stores some metadata at the end of every commit log message,
like this:</p>

<pre>
git-svn-id: file:///Users/david/svn/bricolage/trunk@8581 e630fb3e-2914-11de-beb6-f300316f8eb1
</pre>

<p>This had been very handy as I looked through commits in GitX to find
parents to set up for grafts, but with that done and everything grafted, I no
longer needed it. Ilari helped me to figure out how to properly use 
<code>git filter-branch</code> to get rid of those. To do it, all I had to do
was add a filter for commit messages, like so:</p>

<pre>
git filter-branch &#x002d;&#x002d;msg-filter \
&#x0027;perl -0777 -pe &quot;s/\r?\ngit-svn-id:.+\n//ms&quot;&#x0027; \
&#x002d;&#x002d;tag-name-filter cat &#x002d;&#x002d; &#x002d;&#x002d;all
</pre>

<p>This properly strips out that ugly bit of metadata and finalizes the grafts
all at the same time. Very nice.</p>

<p><em>Now</em> it was time to combine these two repositories for a single
unified history. I wasn't able to find a good tutorial for this on the web,
other
than <a href="http://www.ouaza.com/wp/2007/07/24/assembling-bits-of-history-with-git/" title="Buxy rêve tout haut: “Assembling bits of history with git”">one</a>
that used a third-party Debian utility and only hooked up the master branch,
using a bogus intermediary commit to do it. On the other hand, simply copying
the pack files, as mentioned in the
<a href="http://git.or.cz/gitwiki/GraftPoint" title="GitWiki: “GraftPoint”">Git Wiki</a>--and demonstrated by the scripts linked from there--also appeared to
be suboptimal: The new commits were not showing up in GitX! And besides, Ilari
said, “just copying packs might not suffice. There can also be loose objects.”
Well, we can't have that, can we?</p>

<p>Ilari suggested <code>git-fetch</code>, the
<a href="http://www.kernel.org/pub/software/scm/git/docs/git-fetch.html" title="git-fetch(1) Manual Page">documentation</a> for which says that it will
“download objects and refs from another repository.” Perfect! I wanted to copy
the objects from my CVS migration to the Subversion migration.</p>

<p>My first attempt failed: some commits showed up, but not others. Ilari
pointed out that it wouldn't copy remote branches unless you asked it to do
so, via “refspecs.” Since I'd cloned the repositories to get rid of the
duplicate commits created by <code>git filter-branch</code>, all of my
lovingly recreated local branches were now remote branches. Actually, this is
what I want for the final repository, so I just had to figure out how to copy
them. What I came up with was this:</p>

<pre>
chdir $cvs;
my @branches = map { s/^\s+//; s/\s+$//; $_ } `git branch -r`;

chdir $svn;
system qw(git fetch &#x002d;&#x002d;tags), $cvs;

for my $branch (@branches) {
    next if $branch eq &#x0027;origin/HEAD&#x0027;;
    my $target = $branch =~ m{/master|rev_1_[68]$} ? &quot;$branch-cvs&quot; : $branch;
    system qw(git fetch &#x002d;&#x002d;tags), $cvs,
        &quot;refs/remotes/$branch:refs/remotes/$target&quot;;
}
</pre>

<p>It took me a while to figure out the proper incantation for referencing and
creating remote branches. Once I got the <code>refs/remotes</code> part
figured out, I found that the master, rev_1_6, and rev_1_8 branches from CVS
were overwriting the Subversion branches with the same names. What I really
needed was to have the CVS branches grafted as parents to the Subversion
branches. The #git channel again came to my rescue, where Fissure suggested
that I rename those branches when importing them, do the grafts, and then drop
the renamed branches. Hence the line above that adds “-cvs” to the names of
those branches.</p>

<p>Once the branches were imported, I simply looked for the earliest commits
to those branches in Subversion and mapped it to the latest commits to the
same branches in CVS, then wrote their SHA1 IDs to
<code>.git/info/grafts</code>, like so:</p>

<pre>
open my $fh, &#x0027;>&#x0027;, &quot;.git/info/grafts&quot; or die &quot;Cannot open grafts: $!\n&quot;;
print $fh &#x0027;77a35487f18d68b96d294facc1f1a41745ad914c &#x0027;
       => &quot;835ff47ee1e3d1bf228b8d0976fbebe3c7f02ae6\n&quot;, # rev_1_6
          &#x0027;97ef646f5c2a7c6f47c2046c8d289c1dfc30a73d &#x0027;
       => &quot;2b9f3c5979d062614ef54afd0a01631f746fa3cb\n&quot;, # rev_1_8
          &#x0027;b3b2e7f53d789bea962fe8047e119148e28865c0 &#x0027;
       => &quot;8414b64a6a434b2117294c0568c1012a17bc863b\n&quot;, # master
    ;
close $fh;
</pre>

<p>With the branches all imported and the grafts created, I simply had to
run <code>git filter-branch</code> to make them permanent and drop the
temporary CVS branches:</p>

<pre>
system qw(git filter-branch &#x002d;&#x002d;tag-name-filter cat &#x002d;&#x002d; &#x002d;&#x002d;all);
unlink &#x0027;.git/info/grafts&#x0027;;
system qw(git branch -r -D), &quot;origin/$_-cvs&quot; for qw(rev_1_6 rev_1_8 master);
</pre>

<p>Now I had a complete repository, but with duplicate commits left over
by <code>git-filter-branch</code>. To get rid of those, I need to clone the
repository. But before I clone, I need the remote branches to be local
branches, so that the clone will see them as remotes. For this, I wrote 
the following function:</p>

<pre>
sub fix_branches {
    for my $remote (map { s/^\s+//; s/\s+$//; $_ } `git branch -r`) {
        (my $local = $remote) =~ s{origin/}{};
        next if $local eq &#x0027;master&#x0027;;
        next if $local eq &#x0027;HEAD&#x0027;;
        system qw(git checkout), $remote;
        system qw(git checkout -b), $local;
    }
    system qw(git checkout master);
}
</pre>

<p>It's important to skip the master and HEAD branches, as they'll
automatically be created by <code>git clone</code>. So then I call the
function and and run <code>git gc</code> to take out trash, and then
clone:</p>

<pre>
fix_branches();

run qw(git gc);
chdir &#x0027;..&#x0027;;
run qw(git clone), &quot;file://$svn&quot;, &#x0027;git_final&#x0027;;
</pre>

<p>It's important to use the <code>file:///</code> URL to clone so as to get a
real clone; just pointing to the directory instead makes hard links.</p>

<p>Now I that I had the final repository with all history intact, I was ready
to push it to GitHub! Well, almost ready. First I needed to make the branches
local again, and then see if I could get the repository size down a bit:</p>

<pre>
chdir &#x0027;git_final&#x0027;;
fix_branches();
system qw(git remote rm origin);
system qw(git remote add origin git@github.com:bricoleurs/bricolage.git);
system qw(git gc);
system qw(git repack -a -d -f &#x002d;&#x002d;depth 50 &#x002d;&#x002d;window 50);
</pre>

<p>And that's it! My new Bricolage Git repository is complete, and I've now
pushed it up to its <a href="http://github.com/bricoleurs/bricolage/" title="The Bricolage Git Tree on GitHub">new home on GitHub</a>. I pushed it
like this:</p>

<pre>
git push origin &#x002d;&#x002d;all
git push origin &#x002d;&#x002d;tags
</pre>

<p>Damn I'm glad that's done! I'll be getting the Subversion repository set to
read-only next, and then writing some documentation for my fellow Bricoleurs
on how to work with Git. For those of you who already
know, <a href="http://github.com/bricoleurs/bricolage/fork" title="Fork Bricolage Now!">fork</a> and enjoy!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/vcs/git/bricolage-to-git.html">old layout</a>.</small></p>


