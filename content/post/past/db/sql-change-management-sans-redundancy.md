--- 
date: 2012-01-30T16:00:00Z
description: Here’s how I propose to eliminate the duplication of code between deploy and revert SQL change management scripts.
slug: sql-change-management-sans-redundancy
title: SQL Change Management Sans Duplication
aliases: [/computers/databases/sql-change-management-sans-redundancy.html]
tags: [databases, SQL, databases, change management, version control, Git]
type: post
---

In the [previous episode] in this series, I had one more issue with regard to
SQL change management that I wanted to resolve:

1.  There is still more duplication of code than I would like, in that a
    procedure defined in one change script would have to be copied whole to a
    new script for any changes, even simple single-line changes.

So let’s see what we can do about that. Loading it into Git, our [first example]
looks like this:

    > alias sqlhist="git log -p --format='[%H%d]' --name-only --reverse sql/deploy \
    | awk '/^\[/ {print \"\"} /./'"
    > sqlhist

    [3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
    sql/deploy/users_table.sql

    [32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [b8b9f5c152675305c6b2d3e105d55a25019e0828 (HEAD, gamma, master)]
    sql/deploy/add_user.sql

(Aside: I’ve created an alias, `sqlhist`, on the first line, so that all the Git
and Awk magic doesn’t clutter the remaining examples.)

So, we’ve got the creation of the `users` table under the `alpha` tag, the
addition of the `widgets` table and an accompanying `add_widget()` function
under the `beta` tag, and the creation of the `add_user()` function under the
`gamma` tag. So far so good. Now, let’s say that `gamma` has been deployed to
production, and now we’re ready to add a feature for the next release.

### Modify This

It turns out that our users really want a timestamp for the time a widget was
created. So let’s add a new change script that adds a `created_at` column to the
`widgets` table. First we add `sql/deploy/widgets_created_at.sql` with:

    -- requires: widgets_table
    ALTER TABLE widgets ADD created_at TIMESTAMPTZ;

And then the accompanying revert script, `sql/revert/widgets_created_at.sql`:

    ALTER TABLE widgets DROP COLUMN IF EXISTS created_at;

Commit them and now our deployment configuration looks like this:

    > sqlhist

    [3852b378aa029cc610a03806e8268ed452dce8a6 (alpha)]
    sql/deploy/users_table.sql

    [32883d5a08691351b07928fa4e4fb7e68c500973 (beta)]
    sql/deploy/add_widget.sql
    sql/deploy/widgets_table.sql

    [b8b9f5c152675305c6b2d3e105d55a25019e0828 (gamma)]
    sql/deploy/add_user.sql

    [44ba615b7813531f0acb6810cbf679791fe57bf2 (HEAD, master)]
    sql/deploy/widgets_created_at.sql

So far so good. We have a simple delta script that modifies the existing table,
and there is no code duplication. Time to modify the `add_widget()` function to
insert the timestamp. Recall that, in the [first article][first example] in this
series, I created a separate `sql/deploy/add_widgets_v2.sql` file, copied the
existing function in its entirety into the new file, and modified it there. If
we were to do that here, the resulting deployment configuration would look
something like this:

    > sqlhist

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

Which would be fine, except that if someone else wanted to see what had changed,
here’s what `git diff` would output:

``` patch
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
```

So, what changed in the `add_widget()` function between `gamma` and now? One
cannot tell from this diff: it looks like a brand new function. And no web-based
VCS interface will show you, either; it’s just not inherent in the commit. We
have to actually *know* that it was just an update to an existing function, and
what files to manually diff, like so:

``` patch
> diff -u sql/deploy/add_widget.sql sql/deploy/add_widget_v2.sql 
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
```

Much better, but how annoying is that? It doesn’t allow us to really take
advantage of the VCS, all because we need SQL changes to run in a very specific
order.

But let’s ignore that for the moment. Let’s just throw out the commit with
`add_widgets_v2.sql` and go ahead and change the `add_widget` change script
directly. So the history now looks like this:

    > sqlhist

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

Naturally, the `add_widget` script appears twice now, once under the `beta` tag
and once under `epsilon` (which I’ve just tagged). What are the consequences for
our migration? Well, if we were to build a new database from the beginning,
running these migrations as listed here, we would get an error while applying
the `beta` changes:

    ERROR:  column "created_at" of relation "widgets" does not exist
    LINE 5:     INSERT INTO widgets (created_by, name, created_at)

This is because the `created_at` column won’t exist until the
`widgets_created_at` change is applied. That won’t do, will it? Fortunately, Git
knows exactly what the `add_widget` deploy script looked like under the `beta`
tag, and we can ask it:

``` postgres
> git show beta:sql/deploy/add_widget.sql
-- requires: widgets_table

CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
$$;
```

Boom, there it is, with no reference to `created_at`. Using this technique, our
SQL deployment app can successfully apply all of our database changes by
iterating over the list of changes and applying the contents of each script *at
the time of the appropriate commit or tag.* In other words, it could apply the
output from each of these commands:

    git show alpha:sql/deploy/users_table.sql
    git show beta:sql/deploy/widgets_table.sql
    git show beta:sql/deploy/add_widget.sql
    git show gamma:sql/deploy/add_user.sql
    git show 44ba615b7813531f0acb6810cbf679791fe57bf2:sql/deploy/widget_created_at.sql
    git show epsilon:sql/deploy/add_widget.sql

And everything will work exactly as it should: the original version of the
`add_widget` change script will be for the `beta` tag, and the next version will
be applied for the `epsilon` tag. Not bad, right? We get a nice, clean Git
history *and* can exploit it to manage the changes.

### Reversion to the Mean

But what about reversion? What if the deploy to `epsilon` failed, and we need to
revert back to `gamma`? Recall that in the [first article][first example], I
eliminated duplication by having the `add_widget_v2` revert script simply call
the `add_widget` deploy script. But such is not possible now that we’ve changed
`add_widget` in place. What to do?

The key is for the change management script to know the difference between a new
change script and a modified one. Fortunately, Git knows that, too, and we can
get it to cough up that information with a simple change to the `sqlhist` alias:
instead of passing `--name-only`, pass `--name-status`:

    % alias sqlhist="git log -p --format='[%H%d]' --name-status --reverse sql/deploy \
    | awk '/^\[/ {print \"\"} /./'"

Using this new alias, our history looks like:

    > sqlhist

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

Now we have a letter defining the status of each file. An “A” means the file was
added in that commit; an “M” means it was modified. But the upshot is that, to
revert to `gamma`, our change management can see that `add_widget` was modified
in `epsilon`, and, rather than apply a revert change script, it can just apply
the version of the script as it existed under `gamma`:

``` postgres
> git show gamma:sql/deploy/add_widget.sql
-- requires: widgets_table

CREATE OR REPLACE FUNCTION add_widget(
    username   TEXT,
    widgetname TEXT
) RETURNS VOID LANGUAGE SQL AS $$
    INSERT INTO widgets (created_by, name) VALUES ($1, $2);
$$;
```

And there we are, right back to where we should be. Of course, the remaining
`epsilon` deploy script, `widget_created_at`, was added in its commit, so we
just apply the revert script and we’re set, back to `gamma`.

### Still Configurable

To get back to the original idea of a migration configuration file, I still
think it’s entirely do-able. All we need to is to have the change management app
generate it, just [as before]. When it comes to modified — rather than added —
deploy scripts, it can automatically insert new scripts with the full copies of
previous versions, much as before. The resulting configuration would look
something like this:

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
    sql/deploy/add_widget_v2.sql

Note that last line, where we now have `add_widget_v2`. The change management
script would simply generate this file, and create an additional revert script
with the same name that just contains the contents of the deploy script as it
was under the `gamma` tag.

### Too Baroque?

Having written down these ideas that have plagued by brain for the last week,
along with some examples using Git to confirm them, I’m convinced more than ever
that this is entirely workable. But it also leads me to wonder if it’s too
baroque. I intend these posts as a rough spec for how this thing should work,
and I plan to implement it in the coming weeks. But I’m wondering how difficult
it will be to explain it all to people?

So let me see if I can break it down to a few simple rules.

-   In general, you should create independent deploy and revert scripts for your
    SQL. Put a `CREATE TABLE` statement into its own script. If it requires some
    some other table, require declare the dependency. If you need to change it
    later, create a new script that uses `ALTER TABLE`.
-   In special cases where a simple change cannot be made without copying
    something wholesale, and where the deploy script is idempotent, you may
    simply modify the deploy script in-place.

That’s about it. The [idempotence] of the deploy script is important for
ensuring consistency, and applies very well to features such as [user-defined
functions]. For other objects, there are generally `ALTER` statements that allow
changes to be made without wholesale copying of existing code.

So what am I missing? What have I overlooked? What mistakes in my logic have I
made? Do you think this will be too tricky to implement, or to use? Is it hard
to understand? Your comments would be greatly appreciated, because I *am* going
to write an app to do this stuff, and want to get it *right*.

Thanks for sticking with me through all the thought experiments. For my next
post on this topic, I expect to have an interface spec for the new app.

  [previous episode]: /computers/databases/vcs-sql-change-management.html
  [first example]: /computers/databases/simple-sql-change-management.html
  [as before]: /databases/vcs-sql-change-management.html
  [idempotence]: https://en.wikipedia.org/wiki/Idempotence
  [user-defined functions]: http://www.postgresql.org/docs/current/static/xfunc.html
