--- 
date: 2012-01-30T16:00:00Z
description: Here’s how I propose to eliminate the duplication of code between deploy and revert SQL change management scripts.
slug: sql-change-management-sans-redundancy
title: SQL Change Management Sans Duplication
aliases: [/computers/databases/sql-change-management-sans-redundancy.html]
tags: [databases, SQL, database, change management, version control, Git]
---

<p>In the <a href="/computers/databases/vcs-sql-change-management.html">previous episode</a>
in this series, I had one more issue with regard to SQL change management that
I wanted to resolve:</p>

<ol>
<li>There is still more duplication of code than I would like, in that a
procedure defined in one change script would have to be copied whole
to a new script for any changes, even simple single-line changes.</li>
</ol>


<p>So let’s see what we can do about that. Loading it into Git, our
<a href="/computers/databases/simple-sql-change-management.html">first example</a> looks
like this:</p>

<pre><code>&gt; alias sqlhist="git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
| awk '/^\[/ {print \"\"} /./'"
&gt; sqlhist

[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (HEAD, gamma, master)]
sql/deploy/add_user.sql
</code></pre>

<p>(Aside: I’ve created an alias, <code>sqlhist</code>, on the first line, so that all the Git
and Awk magic doesn’t clutter the remaining examples.)</p>

<p>So, we’ve got the creation of the <code>users</code> table under the <code>alpha</code> tag, the
addition of the <code>widgets</code> table and an accompanying <code>add_widget()</code> function
under the <code>beta</code> tag, and the creation of the <code>add_user()</code> function under the
<code>gamma</code> tag. So far so good. Now, let’s say that <code>gamma</code> has been deployed to
production, and now we’re ready to add a feature for the next release.</p>

<h3>Modify This</h3>

<p>It turns out that our users really want a timestamp for the time a widget was
created. So let’s add a new change script that adds a <code>created_at</code> column to
the <code>widgets</code> table. First we add <code>sql/deploy/widgets_created_at.sql</code> with:</p>

<pre><code>-- requires: widgets_table
ALTER TABLE widgets ADD created_at TIMESTAMPTZ;
</code></pre>

<p>And then the accompanying revert script, <code>sql/revert/widgets_created_at.sql</code>:</p>

<pre><code>ALTER TABLE widgets DROP COLUMN IF EXISTS created_at;
</code></pre>

<p>Commit them and now our deployment configuration looks like this:</p>

<pre><code>&gt; sqlhist

[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
sql/deploy/add_user.sql

[44ba615b7813531f0acb6810cbf679791fe57bf2 (HEAD, master)]
sql/deploy/widgets_created_at.sql
</code></pre>

<p>So far so good. We have a simple delta script that modifies the existing
table, and there is no code duplication. Time to modify the <code>add_widget()</code>
function to insert the timestamp. Recall that, in the
<a href="/computers/databases/simple-sql-change-management.html">first article</a> in
this series, I created a separate <code>sql/deploy/add_widgets_v2.sql</code> file, copied
the existing function in its entirety into the new file, and modified it
there. If we were to do that here, the resulting deployment configuration
would look something like this:</p>

<pre><code>&gt; sqlhist

[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
sql/deploy/add_user.sql

[44ba615b7813531f0acb6810cbf679791fe57bf2]
sql/deploy/widgets_created_at.sql

[dfba488cfd9145928a25d8d48de3231da84s4bd2 (HEAD, master)]
sql/deploy/add_widget_v2.sql
</code></pre>

<p>Which would be fine, except that if someone else wanted to see what had
changed, here’s what <code>git diff</code> would output:</p>

<pre><code>&gt; git diff HEAD^ sql/deploy 
diff --git a/sql/deploy/add_widget_v2.sql b/sql/deploy/add_widget_v2.sql
new file mode 100644
index 0000000..9132195
--- /dev/null
+++ b/sql/deploy/add_widget_v2.sql
@@ -0,0 +1,8 @@
+-- requires widgets_created_at
+CREATE OR REPLACE FUNCTION add_widget(
+    username   TEXT,
+    widgetname TEXT
+) RETURNS VOID LANGUAGE SQL AS $$
+    INSERT INTO widgets (created_by, name, created_at)
+    VALUES ($1, $2, NOW());
+$$;
</code></pre>

<p>So, what changed in the <code>add_widget()</code> function between <code>gamma</code> and now? One
cannot tell from this diff: it looks like a brand new function. And no
web-based VCS interface will show you, either; it’s just not inherent in the
commit. We have to actually <em>know</em> that it was just an update to an existing
function, and what files to manually diff, like so:</p>

<pre><code> &gt; diff -u sql/deploy/add_widget.sql sql/deploy/add_widget_v2.sql 
--- sql/deploy/add_widget.sql   2012-01-28 13:06:24.000000000 -0800
+++ sql/deploy/add_widget_v2.sql    2012-01-28 13:26:59.000000000 -0800
@@ -1,8 +1,8 @@
--- requires: widgets_table
-
+-- requires: widgets_created_at
 CREATE OR REPLACE FUNCTION add_widget(
     username   TEXT,
     widgetname TEXT
 ) RETURNS VOID LANGUAGE SQL AS $$
-    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
+    INSERT INTO widgets (created_by, name, created_at)
+    VALUES ($1, $2, NOW());
 $$;
</code></pre>

<p>Much better, but how annoying is that? It doesn’t allow us to really take
advantage of the VCS, all because we need SQL changes to run in a very
specific order.</p>

<p>But let’s ignore that for the moment. Let’s just throw out the commit with
<code>add_widgets_v2.sql</code> and go ahead and change the <code>add_widget</code> change script
directly. So the history now looks like this:</p>

<pre><code>&gt; sqlhist

[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
sql/deploy/add_user.sql

[44ba615b7813531f0acb6810cbf679791fe57bf2]
sql/deploy/widgets_created_at.sql

[e4b970aa36f27451fe377791eab040a73c6eb47a (HEAD, epsilon, master)]
sql/deploy/add_widget.sql
</code></pre>

<p>Naturally, the <code>add_widget</code> script appears twice now, once under the <code>beta</code>
tag and once under <code>epsilon</code> (which I’ve just tagged). What are the
consequences for our migration? Well, if we were to build a new database from
the beginning, running these migrations as listed here, we would get an error
while applying the <code>beta</code> changes:</p>

<pre><code>ERROR:  column "created_at" of relation "widgets" does not exist
LINE 5:     INSERT INTO widgets (created_by, name, created_at)
</code></pre>

<p>This is because the <code>created_at</code> column won’t exist until the
<code>widgets_created_at</code> change is applied. That won’t do, will it? Fortunately,
Git knows exactly what the <code>add_widget</code> deploy script looked like under the
<code>beta</code> tag, and we can ask it:</p>

<pre><code>&gt; git show beta:sql/deploy/add_widget.sql
-- requires: widgets_table

CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
$$;
</code></pre>

<p>Boom, there it is, with no reference to <code>created_at</code>. Using this technique,
our SQL deployment app can successfully apply all of our database changes by
iterating over the list of changes and applying the contents of each script
<em>at the time of the appropriate commit or tag.</em> In other words, it could apply
the output from each of these commands:</p>

<pre><code>git show alpha:sql/deploy/users_table.sql
git show beta:sql/deploy/widgets_table.sql
git show beta:sql/deploy/add_widget.sql
git show gamma:sql/deploy/add_user.sql
git show 44ba615b7813531f0acb6810cbf679791fe57bf2:sql/deploy/widget_created_at.sql
git show epsilon:sql/deploy/add_widget.sql
</code></pre>

<p>And everything will work exactly as it should: the original version of the
<code>add_widget</code> change script will be for the <code>beta</code> tag, and the next version
will be applied for the <code>epsilon</code> tag. Not bad, right? We get a nice, clean
Git history <em>and</em> can exploit it to manage the changes.</p>

<h3>Reversion to the Mean</h3>

<p>But what about reversion? What if the deploy to <code>epsilon</code> failed, and we need
to revert back to <code>gamma</code>? Recall that in the
<a href="/computers/databases/simple-sql-change-management.html">first article</a>, I
eliminated duplication by having the <code>add_widget_v2</code> revert script simply
call the <code>add_widget</code> deploy script. But such is not possible now that we’ve
changed <code>add_widget</code> in place. What to do?</p>

<p>The key is for the change management script to know the difference between a
new change script and a modified one. Fortunately, Git knows that, too, and we
can get it to cough up that information with a simple change to the <code>sqlhist</code>
alias: instead of passing <code>--name-only</code>, pass <code>--name-status</code>:</p>

<pre><code>% alias sqlhist="git log -p --format='[%H%d]' --name-status --reverse sql/deploy \
| awk '/^\[/ {print \"\"} /./'"
</code></pre>

<p>Using this new alias, our history looks like:</p>

<pre><code>&gt; sqlhist

[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
A   sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
A   sql/deploy/add_widget.sql
A   sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
A   sql/deploy/add_user.sql

[44ba615b7813531f0acb6810cbf679791fe57bf2]
A   sql/deploy/widgets_created_at.sql

[e4b970aa36f27451fe377791eab040a73c6eb47a (HEAD, epsilon, master)]
M   sql/deploy/add_widget.sql
</code></pre>

<p>Now we have a letter defining the status of each file. An “A” means the file
was added in that commit; an “M” means it was modified. But the upshot is
that, to revert to <code>gamma</code>, our change management can see that <code>add_widget</code>
was modified in <code>epsilon</code>, and, rather than apply a revert change script, it
can just apply the version of the script as it existed under <code>gamma</code>:</p>

<pre><code>&gt; git show gamma:sql/deploy/add_widget.sql
-- requires: widgets_table

CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
$$;
</code></pre>

<p>And there we are, right back to where we should be. Of course, the remaining
<code>epsilon</code> deploy script, <code>widget_created_at</code>, was added in its commit, so we
just apply the revert script and we’re set, back to <code>gamma</code>.</p>

<h3>Still Configurable</h3>

<p>To get back to the original idea of a migration configuration file, I still
think it’s entirely do-able. All we need to is to have the change management
app generate it, just <a href="/databases/vcs-sql-change-management.html">as before</a>.
When it comes to modified — rather than added — deploy scripts, it can
automatically insert new scripts with the full copies of previous versions,
much as before. The resulting configuration would look something like this:</p>

<pre><code>[3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
sql/deploy/users_table.sql

[32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
sql/deploy/add_widget.sql
sql/deploy/widgets_table.sql

[b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
sql/deploy/add_user.sql

[44ba615b7813531f0acb6810cbf679791fe57bf2]
sql/deploy/widgets_created_at.sql

[e4b970aa36f27451fe377791eab040a73c6eb47a (HEAD, epsilon, master)]
sql/deploy/add_widget_v2.sql
</code></pre>

<p>Note that last line, where we now have <code>add_widget_v2</code>. The change management
script would simply generate this file, and create an additional revert script
with the same name that just contains the contents of the deploy script as it
was under the <code>gamma</code> tag.</p>

<h3>Too Baroque?</h3>

<p>Having written down these ideas that have plagued by brain for the last week,
along with some examples using Git to confirm them, I’m convinced more than
ever that this is entirely workable. But it also leads me to wonder if it’s
too baroque. I intend these posts as a rough spec for how this thing should
work, and I plan to implement it in the coming weeks. But I’m wondering how
difficult it will be to explain it all to people?</p>

<p>So let me see if I can break it down to a few simple rules.</p>

<ul>
<li>In general, you should create independent deploy and revert scripts for your
SQL. Put a <code>CREATE TABLE</code> statement into its own script. If it requires some
some other table, require declare the dependency. If you need to change it
later, create a new script that uses <code>ALTER TABLE</code>.</li>
<li>In special cases where a simple change cannot be made without copying
something wholesale, and where the deploy script is idempotent, you may
simply modify the deploy script in-place.</li>
</ul>


<p>That’s about it. The <a href="https://en.wikipedia.org/wiki/Idempotence">idempotence</a>
of the deploy script is important for ensuring consistency, and applies very
well to features such as
<a href="http://www.postgresql.org/docs/current/static/xfunc.html">user-defined functions</a>.
For other objects, there are generally <code>ALTER</code> statements that allow changes
to be made without wholesale copying of existing code.</p>

<p>So what am I missing? What have I overlooked? What mistakes in my logic have I
made? Do you think this will be too tricky to implement, or to use? Is it hard
to understand? Your comments would be greatly appreciated, because I <em>am</em>
going to write an app to do this stuff, and want to get it <em>right</em>.</p>

<p>Thanks for sticking with me through all the thought experiments. For my next
post on this topic, I expect to have an interface spec for the new app.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sql-change-management-sans-redundancy.html">old layout</a>.</small></p>


