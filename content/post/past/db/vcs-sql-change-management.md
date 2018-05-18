--- 
date: 2012-01-27T07:32:13Z
description: Some thoughts on how to use VCS history to determine what changes need to be deployed or reverted without relying on a configuration file.
slug: vcs-sql-change-management
title: VCS-Enabled SQL Change Management
aliases: [/computers/databases/vcs-sql-change-management.html]
tags: [databases, SQL, database, change management, version control, Git]
type: post
---

<p>In my <a href="/computers/databases/simple-sql-change-management.html">previous post</a>,
I outlined the basics of a configuration-file and dependency-tracking SQL
deployment architecture, but left a couple of additional challenges
unresolved. They were:</p>

<ol>
<li><p>I would rather not have to hand-edit a configuration file, as it it’s
finicky and error-prone.</p></li>
<li><p>There is still more duplication of code than I would like, in that a
procedure defined in one change script would have to be copied whole
to a new script for any changes, even single-line simple changes.</p></li>
</ol>


<p>I believe I can solve both of these issues by simple use of a VCS. Since all
of my current projects currently use Git, I will use it for the examples here.</p>

<h3>Git it On</h3>

<p>First, recall the structure of the configuration file, which was something
like this:</p>

<pre><code>[alpha]
users_table

[beta]
add_widget
widgets_table

[gamma]
add_user

[delta]
widgets_created_at
add_widget_v2
</code></pre>

<p>Basically, we have bracketed tags identifying changes that should be deployed.
Now have a look at this:</p>

<pre><code>&gt; git log -p --format='[%H]' --name-only --reverse sql/deploy
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
</code></pre>

<p>Look familiar? Let’s use a bit of <code>awk</code> magic to neaten things a bit (Thanks
<a href="http://technosorcery.net/">helwig</a>!):</p>

<pre><code>&gt; git log -p --format='[%H]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>Ah, that’s better. We have commit SHA1s for tags, followed by the appropriate
lists of deployment scripts. But wait, we can decorate it, too:</p>

<pre><code>&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
| awk '/^\[/ {print ""} /./'

[8920aaf7947a56f6777e69a21b70fd877c8fd6dc (alpha)]
sql/deploy/users_table.sql

[f7da5fd4b7391747f75d85db6fa82de47b9e4c00 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[ea10b9e566934ef256debe8752504189436e162a (gamma)]
sql/deploy/add_user.sql
[89e85f98d891a2984ad4e3c42d8ca8cf31f3b2b4 (HEAD, delta, master)]
</code></pre>

<p>Look at that! Actual VCS tags built right in to the output. So, assuming our
deployment app can parse this output, we can deploy or revert to any commit or
tag. Better yet, we don’t have to maintain a configuration file, because the
VCS is already tracking all that stuff for us! Our change management app can
automatically detect if we’re in a Git repository (or Mercurial or CVS or
Subversion or whatever) and fetch the necessary information for us. It’s all
there in the history. We can name revision identifiers (SHA1s here) to deploy
or revert to, or use tags (alpha, beta, gamma, delta, HEAD, or master in this
example).</p>

<p>And with careful repository maintenance, this approach will work for branches,
as well. For example, say you have developers working in two branches,
<code>feature_foo</code> and <code>feature_bar</code>. In <code>feature_foo</code>, a <code>foo_table</code> change script
gets added in one commit, and an <code>add_foo</code> script in a second commit. Merge it
into master and the history now looks like this:</p>

<pre><code>&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>So far so good.</p>

<p>Meanwhile, development in the <code>feature_bar</code> branch has added a <code>bar_table</code>
change script in one commit and <code>add_bar</code> in another. Because development in
this branch was going on concurrently with the <code>feature_foo</code> branch, if we
just merged it into master, we might get a history like this:</p>

<pre><code>&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>Note that <code>bar_table</code> comes before <code>add_foo</code>. In other words, the
<code>feature_foo</code> and <code>feature_bar</code> commits are interleaved. If we were to deploy
to <code>HEAD</code>, and then need to revert <code>feature_bar</code>, <code>bar_table</code> would not be
reverted. This is, shall we say, less than desirable.</p>

<p>There are at least two ways to avoid this issue. One is to squash the merge
into a single commit using <code>git merge --squash feature_bar</code>. This would be
similar to accepting a single patch and applying it. The resulting history
would look like this:</p>

<pre><code>&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>Now both of the <code>feature_bar</code> change scripts come after the <code>feature_foo</code>
changes. But it might be nice to keep the history. So a better solution (and
the best practice, I believe), is to rebase the <code>feature_bar</code> branch before
merging it into master, like so:</p>

<pre><code>&gt; git rebase master
First, rewinding head to replay your work on top of it...
Applying: Add bar.
Applying: Add add_bar().
&gt; git checkout master
Switched to branch 'master'
&gt; git merge feature_bar
Updating 7f89e23..0fab7a0
Fast-forward
 0 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 sql/deploy/add_bar.sql
 create mode 100644 sql/deploy/bar_table.sql
 create mode 100644 sql/revert/add_bar.sql
 create mode 100644 sql/revert/bar_table.sql
</code></pre>

<p>And now we should have:</p>

<pre><code>&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>Awesome, now everything is in the correct order. We did lose the <code>feature_foo</code>
“tag,” though. That’s because it wasn’t a tag, and neither is <code>feature_bar</code>
here. They are, rather, branch names, which we becomes obvious when using
“full” decoration:</p>

<pre><code>git log --format='%d' --decorate=full HEAD^..      
 (HEAD, refs/heads/master, refs/heads/feature_foo)
</code></pre>

<p>After the next commit, it will disappear from the history. So let’s just tag the
relevant commits ourselves:</p>

<pre><code>&gt; git tag feature_foo 7f89e23c9f1e7fc298c69400f6869d701f76759e
&gt; git tag feature_bar
&gt; git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
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
</code></pre>

<p>Ah, there we go! After the next commit, one of those <code>feature_bar</code>s will
disappear, since the branch will have been left behind. But we’ll still have
the tag.</p>

<h3>Not Dead Yet</h3>

<p>Clearly we can intelligently use Git to manage SQL change management. (Kind of
stands to reason, doesn’t it?) Nevertheless, I believe that a configuration
file still might have its uses. Not only because not every project is in a VCS
(it ought to be!), but because oftentimes a project is not deployed to
production as a git clone. It might be distributed as a source tarball or an
RPM. In such a case, including a configuration file in the distribution would
be very useful. But there is still no need to manage it by hand; our
deployment app can generate it from the VCS history before packaging for
release.</p>

<h3>More to Come</h3>

<p>I’d planned to cover the elimination of duplication, but I think this is
enough for one post. Watch for that idea in my next post.</p>
