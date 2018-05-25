--- 
date: 2009-04-24T17:24:40Z
slug: bricolage-to-git
title: Migrating Bricolage CVS and SVN to Git
aliases: [/computers/vcs/git/bricolage-to-git.html]
tags: [Bricolage, Git, Subversion, CVS, SCM, GitHub, Migrations, VCS]
type: post
---

Now that I've successfully [migrated the old Bricolage SourceForge CVS]
repository to Git, and also [migrated Subversion] to Git, it's time to stitch
the two repositories together into one with all history intact. I'm glad to say
that figuring out how to do so took substantially less time than the first two
steps, thanks in large part to the great help from “doener,” “Ilari,” and
“Fissure” on the Freenode \#git channel.

Actually, they helped me with a bit more tweaking of my CVS and Subversion
conversions. One thing I realized after writing [yesterday's post][migrated
Subversion] was that, after running `git filter-branch`, I had twice as many
commits as I should have had. It turns out that `git filter-branch` rewrites all
commits, but keeps the old ones around in case you mess something up. doener
also pointed out that I wasn't having all grafts properly applied, because
`git filter-branch` only applies to the currently checked-out branch. To get all
of the branches, he suggested that I read the [git-filter-branch documentation],
where I'll find that `git filter-branch --tag-name-filter cat -- --all` would
hit all branches. Actually, such was not clear to me from the documentation, but
I took his word for it. Once I did that, to get rid of the dupes, all I had to
do was `git clone` the repository to a new repository. And that was that.

This worked great for my CVS migration, but I realized that I also wanted to
clean out metadata from the Subversion migration. Of course, `git clone` throws
out most of the metadata, but `git svn` also stores some metadata at the end of
every commit log message, like this:

    git-svn-id: file:///Users/david/svn/bricolage/trunk@8581 e630fb3e-2914-11de-beb6-f300316f8eb1

This had been very handy as I looked through commits in GitX to find parents to
set up for grafts, but with that done and everything grafted, I no longer needed
it. Ilari helped me to figure out how to properly use `git filter-branch` to get
rid of those. To do it, all I had to do was add a filter for commit messages,
like so:

    git filter-branch --msg-filter \
    'perl -0777 -pe "s/\r?\ngit-svn-id:.+\n//ms"' \
    --tag-name-filter cat -- --all

This properly strips out that ugly bit of metadata and finalizes the grafts all
at the same time. Very nice.

*Now* it was time to combine these two repositories for a single unified
history. I wasn't able to find a good tutorial for this on the web, other than
[one] that used a third-party Debian utility and only hooked up the master
branch, using a bogus intermediary commit to do it. On the other hand, simply
copying the pack files, as mentioned in the [Git Wiki]--and demonstrated by the
scripts linked from there--also appeared to be suboptimal: The new commits were
not showing up in GitX! And besides, Ilari said, “just copying packs might not
suffice. There can also be loose objects.” Well, we can't have that, can we?

Ilari suggested `git-fetch`, the [documentation] for which says that it will
“download objects and refs from another repository.” Perfect! I wanted to copy
the objects from my CVS migration to the Subversion migration.

My first attempt failed: some commits showed up, but not others. Ilari pointed
out that it wouldn't copy remote branches unless you asked it to do so, via
“refspecs.” Since I'd cloned the repositories to get rid of the duplicate
commits created by `git filter-branch`, all of my lovingly recreated local
branches were now remote branches. Actually, this is what I want for the final
repository, so I just had to figure out how to copy them. What I came up with
was this:

```perl
chdir $cvs;
my @branches = map { s/^\s+//; s/\s+$//; $_ } `git branch -r`;

chdir $svn;
system qw(git fetch --tags), $cvs;

for my $branch (@branches) {
    next if $branch eq 'origin/HEAD';
    my $target = $branch =~ m{/master|rev_1_[68]$} ? "$branch-cvs" : $branch;
    system qw(git fetch --tags), $cvs,
        "refs/remotes/$branch:refs/remotes/$target";
}
```

It took me a while to figure out the proper incantation for referencing and
creating remote branches. Once I got the `refs/remotes` part figured out, I
found that the master, rev\_1\_6, and rev\_1\_8 branches from CVS were
overwriting the Subversion branches with the same names. What I really needed
was to have the CVS branches grafted as parents to the Subversion branches. The
\#git channel again came to my rescue, where Fissure suggested that I rename
those branches when importing them, do the grafts, and then drop the renamed
branches. Hence the line above that adds “-cvs” to the names of those branches.

Once the branches were imported, I simply looked for the earliest commits to
those branches in Subversion and mapped it to the latest commits to the same
branches in CVS, then wrote their SHA1 IDs to `.git/info/grafts`, like so:

```perl
open my $fh, '>', ".git/info/grafts" or die "Cannot open grafts: $!\n";
print $fh '77a35487f18d68b96d294facc1f1a41745ad914c '
        => "835ff47ee1e3d1bf228b8d0976fbebe3c7f02ae6\n", # rev_1_6
            '97ef646f5c2a7c6f47c2046c8d289c1dfc30a73d '
        => "2b9f3c5979d062614ef54afd0a01631f746fa3cb\n", # rev_1_8
            'b3b2e7f53d789bea962fe8047e119148e28865c0 '
        => "8414b64a6a434b2117294c0568c1012a17bc863b\n", # master
    ;
close $fh;
```

With the branches all imported and the grafts created, I simply had to run
`git filter-branch` to make them permanent and drop the temporary CVS branches:

```perl
system qw(git filter-branch --tag-name-filter cat -- --all);
unlink '.git/info/grafts';
system qw(git branch -r -D), "origin/$_-cvs" for qw(rev_1_6 rev_1_8 master);
```

Now I had a complete repository, but with duplicate commits left over by
`git-filter-branch`. To get rid of those, I need to clone the repository. But
before I clone, I need the remote branches to be local branches, so that the
clone will see them as remotes. For this, I wrote the following function:

```perl
sub fix_branches {
    for my $remote (map { s/^\s+//; s/\s+$//; $_ } `git branch -r`) {
        (my $local = $remote) =~ s{origin/}{};
        next if $local eq 'master';
        next if $local eq 'HEAD';
        system qw(git checkout), $remote;
        system qw(git checkout -b), $local;
    }
    system qw(git checkout master);
}
```

It's important to skip the master and HEAD branches, as they'll automatically be
created by `git clone`. So then I call the function and and run `git gc` to take
out trash, and then clone:

```perl
fix_branches();

run qw(git gc);
chdir '..';
run qw(git clone), "file://$svn", 'git_final';
```

It's important to use the `file:///` URL to clone so as to get a real clone;
just pointing to the directory instead makes hard links.

Now I that I had the final repository with all history intact, I was ready to
push it to GitHub! Well, almost ready. First I needed to make the branches local
again, and then see if I could get the repository size down a bit:

```bash
chdir 'git_final';
fix_branches();
system qw(git remote rm origin);
system qw(git remote add origin git@github.com:bricoleurs/bricolage.git);
system qw(git gc);
system qw(git repack -a -d -f --depth 50 --window 50);
```

And that's it! My new Bricolage Git repository is complete, and I've now pushed
it up to its [new home on GitHub]. I pushed it like this:

    git push origin --all
    git push origin --tags

Damn I'm glad that's done! I'll be getting the Subversion repository set to
read-only next, and then writing some documentation for my fellow Bricoleurs on
how to work with Git. For those of you who already know, [fork] and enjoy!

  [migrated the old Bricolage SourceForge CVS]: /computers/vcs/git/bricolage-cvs-to-git.html
    "Migrating Bricolage CVS to Git"
  [migrated Subversion]: /computers/vcs/git/bricolage-svn-to-git.html
    "Migrating Bricolage Subversion to Git"
  [git-filter-branch documentation]: http://www.kernel.org/pub/software/scm/git/docs/git-filter-branch.html
    "git-filter-branch(1) Manual Page"
  [one]: http://www.ouaza.com/wp/2007/07/24/assembling-bits-of-history-with-git/
    "Buxy rêve tout haut: “Assembling bits of history with git”"
  [Git Wiki]: http://git.or.cz/gitwiki/GraftPoint "GitWiki: “GraftPoint”"
  [documentation]: http://www.kernel.org/pub/software/scm/git/docs/git-fetch.html
    "git-fetch(1) Manual Page"
  [new home on GitHub]: http://github.com/bricoleurs/bricolage/
    "The Bricolage Git Tree on GitHub"
  [fork]: http://github.com/bricoleurs/bricolage/fork "Fork Bricolage Now!"
