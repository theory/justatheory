--- 
date: 2012-01-27T07:32:13Z
description: Some thoughts on how to use VCS history to determine what changes need to be deployed or reverted without relying on a configuration file.
slug: vcs-sql-change-management
title: VCS-Enabled SQL Change Management
aliases: [/computers/databases/vcs-sql-change-management.html]
tags: [Databases, SQL, Databases, Change Management, Version Control, Git]
type: post
---

In my [previous post], I outlined the basics of a configuration-file and
dependency-tracking SQL deployment architecture, but left a couple of additional
challenges unresolved. They were:

1.  I would rather not have to hand-edit a configuration file, as it it’s
    finicky and error-prone.

2.  There is still more duplication of code than I would like, in that a
    procedure defined in one change script would have to be copied whole to a
    new script for any changes, even single-line simple changes.

I believe I can solve both of these issues by simple use of a VCS. Since all of
my current projects currently use Git, I will use it for the examples here.

### Git it On

First, recall the structure of the configuration file, which was something like
this:

    [alpha]
    users_table

    [beta]
    add_widget
    widgets_table

    [gamma]
    add_user

    [delta]
    widgets_created_at
    add_widget_v2

Basically, we have bracketed tags identifying changes that should be deployed.
Now have a look at this:

    > git log -p --format='[%H]' --name-only --reverse sql/deploy
    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc]

    sql/deploy/users_table.sql
    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00]

    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql
    [ea10b9e566934ef256debe8752504189436e162a]

    sql/deploy/add_user.sql
    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4]

    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

Look familiar? Let’s use a bit of `awk` magic to neaten things a bit (Thanks
[helwig]!):

    > git log -p --format='[%H]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

Ah, that’s better. We have commit SHA1s for tags, followed by the appropriate
lists of deployment scripts. But wait, we can decorate it, too:

    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql
    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (HEAD, delta, master)]

Look at that! Actual VCS tags built right in to the output. So, assuming our
deployment app can parse this output, we can deploy or revert to any commit or
tag. Better yet, we don’t have to maintain a configuration file, because the VCS
is already tracking all that stuff for us! Our change management app can
automatically detect if we’re in a Git repository (or Mercurial or CVS or
Subversion or whatever) and fetch the necessary information for us. It’s all
there in the history. We can name revision identifiers (SHA1s here) to deploy or
revert to, or use tags (alpha, beta, gamma, delta, HEAD, or master in this
example).

And with careful repository maintenance, this approach will work for branches,
as well. For example, say you have developers working in two branches,
`feature_foo` and `feature_bar`. In `feature_foo`, a `foo_table` change script
gets added in one commit, and an `add_foo` script in a second commit. Merge it
into master and the history now looks like this:

    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (delta)]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

    [cbb48144065dd345c5248e5f1e42c1c7391a88ed]
    sql/deploy/foo_table.sql

    [7f89e23c9f1e7fc298c69400f6869d701f76759e (HEAD, master, feature_foo)]
    sql/deploy/add_foo.sql

So far so good.

Meanwhile, development in the `feature_bar` branch has added a `bar_table`
change script in one commit and `add_bar` in another. Because development in
this branch was going on concurrently with the `feature_foo` branch, if we just
merged it into master, we might get a history like this:

    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'
    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (delta)]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

    [cbb48144065dd345c5248e5f1e42c1c7391a88ed]
    sql/deploy/foo_table.sql

    [d1882d7b4cfcf5c57030bd5a15f8571bfd7e48e2]
    sql/deploy/bar_table.sql

    [7f89e23c9f1e7fc298c69400f6869d701f76759e]
    sql/deploy/add_foo.sql

    [2330da1caae9a46ea84502bd028ead399ca3ca02 (feature_bar)]
    sql/deploy/add_bar.sql

    [73979ede2c8589cfe24c9213a9538f305e6f508f (HEAD, master, feature_foo)]

Note that `bar_table` comes before `add_foo`. In other words, the `feature_foo`
and `feature_bar` commits are interleaved. If we were to deploy to `HEAD`, and
then need to revert `feature_bar`, `bar_table` would not be reverted. This is,
shall we say, less than desirable.

There are at least two ways to avoid this issue. One is to squash the merge into
a single commit using `git merge --squash feature_bar`. This would be similar to
accepting a single patch and applying it. The resulting history would look like
this:

    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (delta)]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

    [cbb48144065dd345c5248e5f1e42c1c7391a88ed]
    sql/deploy/foo_table.sql

    [7f89e23c9f1e7fc298c69400f6869d701f76759e]
    sql/deploy/add_foo.sql

    [91a048c05e0444682e2e4763e8a7999a869b4a77 (HEAD, master)]
    sql/deploy/add_bar.sql
    sql/deploy/bar_table.sql

Now both of the `feature_bar` change scripts come after the `feature_foo`
changes. But it might be nice to keep the history. So a better solution (and the
best practice, I believe), is to rebase the `feature_bar` branch before merging
it into master, like so:

    > git rebase master
    First, rewinding head to replay your work on top of it...
    Applying: Add bar.
    Applying: Add add_bar().
    > git checkout master
    Switched to branch 'master'
    > git merge feature_bar
    Updating 7f89e23..0fab7a0
    Fast-forward
     0 files changed, 0 insertions(+), 0 deletions(-)
     create mode 100644 sql/deploy/add_bar.sql
     create mode 100644 sql/deploy/bar_table.sql
     create mode 100644 sql/revert/add_bar.sql
     create mode 100644 sql/revert/bar_table.sql

And now we should have:

    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (delta)]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

    [cbb48144065dd345c5248e5f1e42c1c7391a88ed]
    sql/deploy/foo_table.sql

    [7f89e23c9f1e7fc298c69400f6869d701f76759e]
    sql/deploy/add_foo.sql

    [0e53c29eb47c618d0a8818cc17bd5a0aab0acd6d]
    sql/deploy/bar_table.sql

    [0fab7a0ba928b34a46a9495d4efc1c73d9133d37 (HEAD, master, feature_bar)]
    sql/deploy/add_bar.sql

Awesome, now everything is in the correct order. We did lose the `feature_foo`
“tag,” though. That’s because it wasn’t a tag, and neither is `feature_bar`
here. They are, rather, branch names, which we becomes obvious when using “full”
decoration:

    git log --format='%d' --decorate=full HEAD^..      
     (HEAD, refs/heads/master, refs/heads/feature_foo)

After the next commit, it will disappear from the history. So let’s just tag the
relevant commits ourselves:

    > git tag feature_foo 7f89e23c9f1e7fc298c69400f6869d701f76759e
    > git tag feature_bar
    > git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print ""} /./'

    [8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
    sql/deploy/users_table.sql

    [f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [ea10b9e566934ef256debe8752504189436e162a (gamma)]
    sql/deploy/add_user.sql

    [89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (delta)]
    sql/deploy/add_widget_v2.sql
    sql/deploy/widgets_created_at.sql

    [cbb48144065dd345c5248e5f1e42c1c7391a88ed]
    sql/deploy/foo_table.sql

    [7f89e23c9f1e7fc298c69400f6869d701f76759e (feature_foo)]
    sql/deploy/add_foo.sql

    [0e53c29eb47c618d0a8818cc17bd5a0aab0acd6d]
    sql/deploy/bar_table.sql

    [0fab7a0ba928b34a46a9495d4efc1c73d9133d37 (HEAD, feature_bar, master, feature_bar)]
    sql/deploy/add_bar.sql

Ah, there we go! After the next commit, one of those `feature_bar`s will
disappear, since the branch will have been left behind. But we’ll still have the
tag.

### Not Dead Yet

Clearly we can intelligently use Git to manage SQL change management. (Kind of
stands to reason, doesn’t it?) Nevertheless, I believe that a configuration file
still might have its uses. Not only because not every project is in a VCS (it
ought to be!), but because oftentimes a project is not deployed to production as
a git clone. It might be distributed as a source tarball or an RPM. In such a
case, including a configuration file in the distribution would be very useful.
But there is still no need to manage it by hand; our deployment app can generate
it from the VCS history before packaging for release.

### More to Come

I’d planned to cover the elimination of duplication, but I think this is enough
for one post. Watch for that idea in my next post.

  [previous post]: {{% ref "/post/past/db/simple-sql-change-management" %}}
  [helwig]: https://technosorcery.net/
