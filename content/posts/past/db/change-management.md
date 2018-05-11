--- 
date: 2009-04-29T18:02:57Z
description: Database migration frameworks and ad-hoc solutions leave things…wanting. Herein lie some preliminary thoughts on how to solve this problem.
slug: change-management
title: Some Thoughts on Database Change Management
aliases: [/computers/databases/change-management.html]
tags: [databases, database, change management]
---

<p>I've had reason to think about database change management lately. While I
was working on Rails apps, I of course made use
of <a href="http://guides.rubyonrails.org/migrations.html" title="RailsGuides: Migrations">migrations</a>. These were an improvement over what I'd been doing
with <a href="http://github.com/bricoleurs/bricolage/tree/master/inst/upgrade" title="Bricolage Upgrade Scripts">Bricolage upgrade scripts</a>, in the sense
that the system kept track of what version you were on (where “version” means
“numeric sequence of migration scripts”) and applied whatever had a higher
number than was last applied. But Rails migrations leave a number of things to
be desired, not least of which that they support a very small subset of SQL
and require that you write the migrations in Ruby (sure I could embed SQL, and
I did, but it was still Ruby and thus not able to integrate with,
say, <a href="http://www.slony.info/">Slony-I</a>).</p>

<p>Inspired by Rails migrations, last summer I wrote some code for a customer
that did essentially the same thing, except that the migration scripts were
pure SQL scripts rather than Ruby (or Perl or whatever). I did this by
subclassing <a href="http://search.cpan.org/dist/Module-Build/" title="Module::Build on CPAN">Module::Build</a> to add a “db” action. So for a
deployment, you could do this:</p>

<pre>
perl Build.PL
./Build
./Build db
sudo ./Build install
</pre>

<p>And it would do the right thing, tracking which migration scripts had been
run by their numeric prefixes and updating a metadata record for each one. And
that worked great…except when it came to maintaining database functions and
procedures.</p>

<p>The problem in a nut-shell is this: Database functions are
<a href="/computers/databases/postgresql/recurring_events.html" title="Just a Theory: “How to Generate Recurring Events in the Database”">amazingly useful</a>; they greatly
<a href="http://www.onlamp.com/pub/a/onlamp/2006/06/29/many-to-many-with-plpgsql.html" title="O’Reilly ONLamp: “Managing Many-to-Many Relationships with PL/pgSQL”">simplify client interfaces</a> and
<a href="http://www.oreillynet.com/pub/a/databases/2006/09/07/plpgsql-batch-updates.html" title="O’Reilly Databases: “Batch Updates with PL/pgSQL”">improve performance</a>. But managing them in migration scripts is a recipe for
a <em>ton</em> of code duplication. Why? Because--unlike your Perl or Ruby
code or whatever, which you just modify in a library file and commit to your
version control system--every time you have to modify a function, you have to
paste the entire fucking thing in a new migration script and make your changes
there.</p>

<p>Try to imagine, for a moment, what that means for a function such as the
<code>recurring_events_for()</code> function in my piece
on <a href="/computers/databases/postgresql/recurring_events.html" title="Just a Theory: “How to Generate Recurring Events in the Database”">generating recurring events in the database</a>. Say there was a bug in the function,
where it was failing to return some instances of events that fall between the
recurrence dates. A simple patch might look something like this:</p>

<pre>
@@ -22,7 +22,10 @@
                   recurrence &lt;&gt; &#x0027;none&#x0027;
               OR  (
                      recurrence = &#x0027;none&#x0027;
-                 AND starts_at BETWEEN range_start AND range_end
+                 AND (
+                         starts_at BETWEEN range_start AND range_end
+                      OR ends_at   BETWEEN range_start AND range_end
+                 )
               )
           )
     LOOP
</pre>

<p>Pretty straight-forward, right? But <em>not for migration scripts!</em>. To
make this three-line change with migrations, I'd actually have to paste the
entire 58-line function into a new migration script, make the changes and then
commit. There are at least two problems with this approach: 1) A huge amount
of code duplication for no good reason; and 2) No real change management!
Someone looking at
<a href="http://search.cpan.org/dist/SVN-Notify/" title="SVN::Notify on CPAN">SVN::Notify</a> notifications would not easily be
able to see what changed, because the diff does not show what lines changed in
the function, only that a whole new file with a whole new function was added.
Yikes!</p>

<p>And it can get worse than this. For a client I'm currently working with,
the state of the production database is tracked in Subversion by running a
nightly <code>cron</code> job that dumps the database schema to a file and
checks it into subversion. Migration scripts are written in pure SQL and
named with bug numbers, but once they are pushed to production,
<em>the bloody migration scripts are deleted because the nightly schema dump
reflects the changes!</em>. So, for function updates, the are committed to
Subversion en masse <em>twice!</em></p>

<p>So I'd like to propose a different approach to database change management.
Or, rather, a more diversified approach.</p>

<p>First, you can have numbered migration scripts. This works very well for
simple schema changes, like adding a table, column, foreign key, or index,
because the SQL statements that get committed in the scripts describe exactly
what they're doing. <code>ALTER</code> statements are uncomplicated, and show
only what they're altering. You can also easily write downgrade migration
scripts to use in case something goes wrong, just by using the same script
number in a different directory. So you'd have something like this:</p>

<pre>
sql/
sql/migrations/
sql/migrations/up/
sql/migrations/up/001-create_user_table.sql
sql/migrations/up/002-add_fk_for_user.sql
sql/migrations/down/
sql/migrations/down/001-drop_user_table.sql
sql/migrations/down/002-drop_fk_for_user.sql
</pre>

<p>That's the first part, not unlike how Rails migrations work or the stuff I
wrote for a client last year. But then there's a second set of migration
scripts. These are managed like Perl or Ruby libraries or what-have-you, such
that you can just add and/or change files as necessary. It might look like
this, with one database function or procedure per file:</p>

<pre>
sql/migrations/lib/
sql/migrations/lib/generate_recurrences.sql
sql/migrations/lib/recurring_events_for.sql
</pre>

<p>Each of these files has one function defined using <code>CREATE OR REPLACE
FUNCTION</code>. This means that they can be run over and over again without
problem. If I run into a bug in my <code>recurring_events_for()</code>
function, I just change it in <code>recurring_events_for.sql</code>, commit
it, and I'm done.</p>

<p>The code that handles the database build can then track both the migration
number <em>and</em> the timestamp for the last commit migrated in the
<code>sql/migrations/lib</code> directory. Once the numbered migrations are
run, it can then decide what <code>lib</code> migrations to run by looking for
those that have been modified since the last time migrations were run. In
Perl, using Git, that'd be something like this:</p>

<pre>
sub run {
    my $cmd = shift;
    map { s/^\s+//; s/\s+$//; $_ } `$cmd`;
}

my $lib = &#x0027;lib&#x0027;;
my $date = &#x0027;2009-04-01 00:01:00&#x0027;;
my ($rev) = run &quot;git rev-list --reverse --since=&#x0027;$date&#x0027; master -- &#x0027;$lib&#x0027;&quot;;

for my $script (
    map  { $_-&gt;[0] }
    sort { $a-&gt;[1] cmp $b-&gt;[1] }
    map  { chomp; [ $_ =&gt; run &quot;git log -1 --pretty=format:%ci &#x0027;$_&#x0027;&quot; ]  }
    run &quot;git diff --name-only $rev^ &#x0027;$lib&#x0027;&quot;
) {
    system qw(psql -f), $script;
}
</pre>

<p>First, we get the oldest revision SHA1 ID since the specified date and
store it in <code>$rev</code>. The magic is in the <code>for</code> loop
which, due to the antiquity of Perl list functions, you must read
bottom-to-top (aside: this can be rectified
by <a href="http://search.cpan.org/perldoc?autobox" title="autobox on CPAN">autoboxing</a>). We use <code>git diff &#x002d;&#x002d;name-only</code> to get a list
of all the files changed in the directory since just before that revision. For
file each, we get the date of the most recent commit, sort on the date, and
then apply the migration by passing it to <code>psql -f</code>.</p>

<p>In reality, the code should also update the metadata table in the database
with the date of each script as it's applied -- but only if it succeeds. If it
fails, we just die. If you needed to migrate down, the code could just check
out the files as they were at <code>$rev^</code> and apply them. Yeah, use
the change management interface to go back in time: who'da thought it?</p>

<p>Anyway, that's the idea. I think I'll implement this for an internal app
I've been hacking on and off, just to see what kinds of issues might come up.
Anyone else thought of something like this? Maybe there's something already
out there? I'm not interested in automatic migrations
like <a href="http://search.cpan.org/perldoc?DBIx::Class::Manual::SchemaIntro" title="Introduction to DBIx::Class::Schema">DBIx::Class Schema migrations</a>,
as I don't rely on ORMs anymore (probably should blog that one of these days,
too). I'm just curious what other approaches folks have taken to database
change management. Let me know.</p>


<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/change-management.html">old layout</a>.</small></p>


