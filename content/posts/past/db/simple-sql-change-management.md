--- 
date: 2012-01-26T05:00:00Z
description: I've been thinking a lot about SQL change management. I think I may finally have cracked this thing wide open.
slug: simple-sql-change-management
title: Simple SQL Change Management
aliases: [/computers/databases/simple-sql-change-management.html]
tags: [databases, SQL, database, change management, versioning]
---

<p>I’ve been thinking a lot about SQL change management. I know I have
<a href="/computers/databases/change-management.html">written about this before</a>. But
I was never satisfied with that idea, mostly because it required managing
database changes in two separate but interdependent ways. Blargh. So for my
Perl projects the last couple of years, I have stuck to the very simple but
ugly Rails-style migration model, as implemented in
<a href="https://metacpan.org/module/Module::Build::DB">Module::Build::DB</a>.</p>

<p>But it has been on my brain more lately because I’m writing more and more
database applications <a href="http://iovation.com/">at work</a>, and managing changes
over time is becoming increasingly annoying. I’ve been using a variation on
<a href="http://www.depesz.com/index.php/2010/08/22/versioning/">Depesz’s Versioning</a>
package, mainly because its idea of specifying dependencies instead of ordered
deployment scripts is so useful. However, its implementation in pure SQL, with
accompanying shell and Perl scripts, is not entirely satisfying. Worse, one
cannot easily include the contents of an earlier deployment script in a
reversion script, because the dependency registration function embedded in a
script will throw an error if it has been run before. The upshot is that if
you make a one-line change to a database function, you still have to paste the
entire thing into a new file and commit it to your source code repository.
This makes tracking diffs annoying.</p>

<p>Oh, and did I mention that there is no simple built-in way to revert changes,
and even if there were, because there are no named releases, it can be
difficult to decide what to revert <em>to</em>? I don’t often need that capability,
but when I need it, I <strong>need it.</strong></p>

<p>Then, this week, Robert Haas
<a href="http://archives.postgresql.org/pgsql-hackers/2012-01/msg01138.php">described a deployment implementation</a>
he implemented. It was simple:</p>

<blockquote><p>My last implementation worked by keeping a schema_versions table on the
server with one column, a UUID. The deployment tarball contained a file with
a list of UUIDs in it, each one associated to an SQL script. At install
time, the install script ran through that file in order and ran any scripts
whose UUID didn’t yet appear in the table, and then added the UUIDs of the
run scripts to the table.</p></blockquote>

<p>I like this simplicity, but there are some more things I think could be done,
including dependency resolution and reversion. And it seems silly to have a
UUID stand for a script name; why not just list script names? Better yet, tag
groups of changes for easy reference.</p>

<h3>Yet Another SQL Deployment Strategy</h3>

<p>So here’s my proposal. Following Robert, we create a configuration file, but
instead of just listing changes, we fill it with tags and the names of the
changes are associated with each. An example:</p>

<pre><code>[alpha]
users_table

[beta]
add_widget
widgets_table

[gamma]
add_user
</code></pre>

<p>Our change management app will parse this file, finding the tag for each stage
of the migration in brackets, and apply the associated changes, simply finding
each of them in <code>sql/deploy/$change.sql</code>. If it’s reverting changes, it finds
the reversion scripts named <code>sql/revert/$change.sql</code>. The tags can be anything
you want; release tags might be useful. Easy so far, right?</p>

<p>Except notice that I have a minor ordering problem here. The <code>add_widget</code>
change, which adds a function to insert a record into the <code>widgets</code> table,
comes <em>before</em> the <code>widgets_table</code> script. If we run the <code>add_widget</code> change
first, it will fail, because the <code>widgets</code> table does not yet exist.</p>

<p>Of course we can re-order the lines in the configuration file. But given that
one might have many changes for a particular tag, with many cross-referencing
dependencies, I think it’s better to overcome this problem in the scripts
themselves. So I suggest that the <code>sql/deploy/add_widget.sql</code> file look
something like this:</p>

<pre><code>-- requires: widgets_table

CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
$$;
</code></pre>

<p>Here I’m stealing Depesz’s dependency tracking idea. With a simple comment at
the top of the script, we specify that this change requires that the
<code>widgets_table</code> change be run first. So let’s look at
<code>sql/deploy/widgets_table.sql</code>:</p>

<pre><code>-- requires: users_table

CREATE TABLE widgets (
    created_by TEXT NOT NULL REFERENCES users(name),
    name       TEXT NOT NULL
);
</code></pre>

<p>Ah, now here we also require that the <code>users_table</code> change be deployed first.
Of course, it likely would be, given that it appears under a tag earlier in
the file, but it’s best to be safe and explicitly spell out dependencies.
Someone might merge the two tags at some point before release, right?</p>

<p>The <code>users_table</code> change has no dependencies, but the later <code>add_user</code> change
of course does; our <code>sql/deploy/add_user.sql</code>:</p>

<pre><code>-- requires: users_table

CREATE OR REPLACE FUNCTION add_user(
    name TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO users (name) VALUES ($1);
$$;
</code></pre>

<p>Our deployment app can properly resolve these dependencies. Of course, we also
need reversion scripts in the <code>sql/revert</code> directory. They might look
something like:</p>

<pre><code>-- sql/revert/users_table.sql
DROP TABLE IF EXISTS users;

-- sql/revert/add_widget.sql
DROP FUNCTION IF EXISTS add_widget(text, text);

-- sql/revert/widgets_table.sql
DROP TABLE IF EXISTS widgets;

-- sql/revert/add_user.sql
DROP FUNCTION IF EXISTS add_user(text);
</code></pre>

<p>So far so good, right? Our app can resolve dependencies in both directions, so
that if we tell it to revert to <code>beta</code>, it can do so in the proper order.</p>

<p>Now, as the deployment app runs the scripts, deploying or reverting changes,
it tracks them and their dependencies in its own metadata table in the
database, not unlike
<a href="http://www.depesz.com/index.php/2010/08/22/versioning/">Depesz’s Versioning</a>
package. But because dependencies are parsed from comments in the scripts, we
are free to <em>include</em> the contents of one script in another. For example, say
that we later need to revise the <code>add_widget()</code> function to log the time a
widget is created. First we add a new script to add the necessary column:</p>

<pre><code>-- requires: widgets_table
ALTER TABLE widgets ADD created_at TIMESTAMPTZ;
</code></pre>

<p>Call that script <code>sql/deploy/widgets_created_at.sql</code>. Next we add a script
that changes <code>add_widgets()</code>:</p>

<pre><code>-- requires widgets_created_at
CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name, created_at)
    VALUES ($1, $2, NOW());
$$;
</code></pre>

<p>Call it <code>sql/deploy/add_widget_v2.sql</code>. Then update the deployment
configuration file with a new tag and the associated changes:</p>

<pre><code>[delta]
widgets_created_at
add_widget_v2
</code></pre>

<p>With me so far? Now, what about reversion? <code>sql/revert/widgets_created_at.sql</code>
is simple, of course:</p>

<pre><code>ALTER TABLE widgets DROP COLUMN IF EXISTS created_at;
</code></pre>

<p>But what should <code>sql/revert/add_widget_v2.sql</code> look like? Why, to go back to
the first version of <code>add_widget()</code>, it would be identical to
<code>sql/deploy/add_widget.sql</code>. But it would be silly to copy the whole file,
wouldn’t it? Why duplicate when we can just include?</p>

<pre><code>\i sql/deploy/add_widget.sql
</code></pre>

<p><em>Boom,</em> we get the reversion script for free. No unnecessary duplication
between deployment and reversion scripts, and all dependencies are nicely
resolved. Plus, the tags in the configuration file make it easy to deploy and
revert change sets as necessary, with dependencies properly followed.</p>

<h3>There’s More!</h3>

<p>To recap, I had two primary challenges with Depesz’s Versioning package to
overcome: inability to easily revert to an earlier implementation; and the
inability to easily include one script in another. Both of course are do-able
with workarounds, but I think that the addition of a deployment configuration
file with tagged sets of changes and the elimination of SQL-embedded
dependency specification overcome these issues much more effectively and
intuitively.</p>

<p>Still, there are two more challenges I would like to overcome:</p>

<ol>
<li><p>It would be nice not to need the configuration file at all. Maintaining
such a thing can be finicky and error-prone.</p></li>
<li><p>I still had to duplicate the entire <code>add_widget()</code> function in the
<code>add_widget_v2</code> script for a very simple change. This means no easy way to
simply see the diff for this change in my VCS. It would be nice not to have
to copy the entire function.</p></li>
</ol>


<p>I think I have solutions for these issues, as well. More in my next post.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/simple-sql-change-management.html">old layout</a>.</small></p>


