--- 
date: 2013-09-06T13:44:00Z
title: Sqitch Templating
aliases: [/sqitch/2013/09/06/sqitch-templating/]
tags: [Sqitch, templating]
categories: [Sqitch]
---

Last week saw the v.980 release of [Sqitch], a database change management
system. The headline feature in this version is support for [MySQL] 5.6.4 or
higher. Why 5.6.4 rather than 5.1 or even 5.5? Mainly because 5.6.4 finally
added support for fractional seconds in `DATETIME` columns (details in the
[release notes]). This feature is essential for Sqitch, because changes often
execute within a second of each other, and the deploy time is included in the
log table's primary key.

With the requirement for fractional seconds satisfied by 5.6.4, there was
nothing to prevent usage of [`SIGNAL`], added in 5.5, to
[mimic check constraints] in a trigger. This brings the Sqitch MySQL
implementation into line with what was already possible in the Postgres,
SQLite, and Oracle support. Check out the [tutorial] and the accompanying
[Git repository] to get started managing your MySQL databases with Sqitch.

[Sqitch]: http://sqitch.org/ "Sane database change management"
[MySQL]: http://dev.mysql.com/ "The world's most popular open source database"
[release notes]: https://dev.mysql.com/doc/relnotes/mysql/5.6/en/news-5-6-4.html "Changes in MySQL 5.6.4 (2011-12-20, Milestone 7)"
[`SIGNAL`]: http://dev.mysql.com/doc/refman/5.5/en/condition-handling.html "MySQL 5.5 Reference Manual: Condition Handling"
[mimic check constraints]: http://stackoverflow.com/a/17424570/79202 "How do I get MySQL to throw a conditional runtime exception in SQL"
[tutorial]: https://metacpan.org/module/sqitchtutorial-mysql "A tutorial introduction to Sqitch change management on MySQL"
[Git repository]: https://github.com/theory/sqitch-mysql-intro "Sqitch MySQL Intro Sample Repository"

The MySQL support might be the headliner, but the change in v0.980 I'm most
excited about is improved template support. Sqitch executes templates to
create the default deploy, revert, and verify scripts, but up to now they have
not been easy to customize. With v0.980, you can create as many custom
templates as you like, and use them as appropriate.

<!-- more -->

A Custom Template
-----------------

Let's create a custom template for creating a table. The first step is to
create the template files. Custom templates can live in <code>\`sqitch
--etc-path\`/templates</code> or in `~/.sqitch/templates`. Let's use the
latter. Each template goes into a directory for the type of script, so we'll
create them:

``` sh
mkdir -p ~/.sqitch/templates/deploy
mkdir -p ~/.sqitch/templates/revert 
mkdir -p ~/.sqitch/templates/verify
```

Copy the default templates for your preferred database engine; here I copy the
Postgres templates:

``` sh
tmpldir=`sqitch --etc-path`/templates
cp $tmpldir/deploy/pg.tmpl ~/.sqitch/templates/deploy/createtable.tmpl
cp $tmpldir/revert/pg.tmpl ~/.sqitch/templates/revert/createtable.tmpl
cp $tmpldir/verify/pg.tmpl ~/.sqitch/templates/verify/createtable.tmpl
chmod -R +w ~/.sqitch/templates
```

Here's what the default deploy template looks like:

``` postgres
-- Deploy [% change %]
[% FOREACH item IN requires -%]
-- requires: [% item %]
[% END -%]
[% FOREACH item IN conflicts -%]
-- conflicts: [% item %]
[% END -%]

BEGIN;

-- XXX Add DDLs here.

COMMIT;
```

The code before the `BEGIN` names the template and lists dependencies, which
is reasonably useful, so we'll leave it as-is. We'll focus on replacing that
comment, `-- XXX Add DDLs here.`, with the template for a `CREATE TABLE`
statement. Start simple: just use the change name for the table name. In
`~/.sqitch/templates/deploy/createtable.tmpl`, replace the comment with these
lines:

``` postgres
CREATE TABLE [% change %] (
    -- Add columns here.
);
```

In the revert template, `~/.sqitch/templates/deploy/createtable.tmpl`, replace
the comment with a `DROP TABLE` statement:

``` postgres
DROP TABLE [% change %];
```

And finally, in the verify template,
`~/.sqitch/templates/verify/createtable.tmpl`, replace the comment with a
simple `SELECT` statement, which is just enough to verify the creation of a
table:

``` postgres
SELECT * FROM [% change %];
```

Great, we've created a set of simple customized templates for adding a
`CREATE TABLE` change to a Sqitch project. To use them, just pass the
`--template` option to [`sqitch add`], like so:

``` sh
> sqitch add widgets --template createtable -n 'Add widgets table.'
Created deploy/widgets.sql
Created revert/widgets.sql
Created verify/widgets.sql
Added "widgets" to sqitch.plan
```

Now have a look at `deploy/widgets.sql`:

``` postgres
-- Deploy widgets

BEGIN;

CREATE TABLE widgets (
    -- Add columns here.
);

COMMIT;
```

Cool! The revert template should also have done its job. Here's
`revert/widgets.sql`:

``` postgres
-- Revert widgets

BEGIN;

DROP TABLE widgets;

COMMIT;
```

And the verify script, `verify/widgets.sql`:

``` postgres
-- Verify widgets

BEGIN;

SELECT * FROM widgets;

ROLLBACK;
```

[`sqitch add`]: http://metacpan.org/module/sqitch-add "Add a database change to the Sqitch plan"

Custom Table Name
-----------------

What if you want to name the change one thing and the table it creates
something else? What if you want to schema-qualify the table? Easy! Sqitch's
dead simple default [templating language], [Template::Tiny], features `if`
statements. Try using them with custom variables for the schema and table
names:

``` postgres
SET search_path TO [% IF schema ][% schema %],[% END %]public;

CREATE TABLE [% IF table %][% table %][% ELSE %][% change %][% END %] (
    -- Add columns here.
);
```

If the `schema` variable is set, the `search_path`, which determines where
objects will go, gets set to `$schema,public`. If `schema` is not set, the
path is simply `public`, which is the default schema in Postgres.

We take a similar tack with the `CREATE TABLE` statement: If the `table`
variable is set, it's used as the name of the table. Otherwise, we use the
change name, as before.

The revert script needs the same treatment:

``` postgres
SET search_path TO [% IF schema ][% schema %],[% END %]public;
DROP TABLE [% IF table %][% table %][% ELSE %][% change %][% END %];
```

As does the verify script:

``` postgres
SET search_path TO [% IF schema ][% schema %],[% END %]public;
SELECT * FROM [% IF table %][% table %][% ELSE %][% change %][% END %];
```

Take it for a spin:

``` sh
> sqitch add corp_widgets --template createtable \
  --set schema=corp --set table=widgets \
  -n 'Add corp.widgets table.'
Created deploy/corp_widgets.sql
Created revert/corp_widgets.sql
Created verify/corp_widgets.sql
Added "corp_widgets" to sqitch.plan
```

The resulting deploy script will create `corp.widgets`:

``` postgres
-- Deploy corp_widgets

BEGIN;

SET search_path TO corp,public;

CREATE TABLE widgets (
    -- Add columns here.
);

COMMIT;
```

Cool, right? The revert and verify scripts of course yield similar results.
Omitting the `--set` option, the template falls back on the change name:

``` postgres
-- Deploy widgets

BEGIN;

SET search_path TO public;

CREATE TABLE widgets (
    -- Add columns here.
);

COMMIT;
```

[Template::Tiny]: https://metacpan.org/module/Template::Tiny
[templating language]: https://metacpan.org/module/sqitch-add#Syntax "Sqitch Template Syntax"

Add Columns
-----------

Template variables may contain array values. The default templates takes
advantage of this feature to list dependencies in SQL comments. It works great
for custom variables, too. For the purposes of our `CREATE TABLE` template,
let's add columns. Replace the `-- Add columns here` comment in the deploy
simple with these three lines:

``` postgres
[% FOREACH col IN column -%]
    [% col %] TEXT NOT NULL,
[% END -%]
```

We can similarly improve the verify script: change its `SELECT` statement to:

``` postgres
SELECT [% FOREACH col IN column %][% col %], [% END %]
  FROM [% IF table %][% table %][% ELSE %][% change %][% END %];
```

Just pass multiple `--set` (or `-s`) options to `sqitch add` to add as many
columns as you like:

``` sh
> sqitch add corp_widgets --template createtable \
  -s schema=corp -s table=widgets \
  -s column=id -s column=name -s column=quantity \
  -n 'Add corp.widgets table.'
```

Behold the resulting deploy script!

``` postgres
-- Deploy corp_widgets

BEGIN;

SET search_path TO corp,public;

CREATE TABLE widgets (
    id TEXT NOT NULL,
    name TEXT NOT NULL,
    quantity TEXT NOT NULL,
);

COMMIT;
```

You still have to edit the resulting file, of course. Maybe `NULL`s should be
allowed in the `name` column. And I suspect that `quantity` ought be an
integer. There's that pesky trailing comma to remove, too. The verify script
suffers the same deficiency:

``` postgres
-- Verify corp_widgets

BEGIN;

SET search_path TO corp,public;
SELECT id, name, quantity, 
  FROM widgets;

ROLLBACK;
```

Still, these templates remove much of the grudge work of adding `CREATE TABLE`
changes, giving you the scaffolding on which to build the objects you need.

Upgraded Templates
------------------

We call Sqitch's [templating language] "default" because it can be replaced
with a more capable one. Simply install [Template Toolkit] to transparently
upgrade your Sqitch templates. Template Toolkit's comprehensive feature set
covers just about any functionality you could want out of a templating system.
It's big and complex, but relatively straight-forward to install: just run
`cpan Template`, `cpanm Template`, `yum install perl-Template-Toolkit`, or the
like and you'll be in business.

We can resolve the trailing comma issue thanks to Template Toolkit's `loop`
variable, which is implicitly created in the `FOREACH` loop. Simply replace
the comma in the template with the expression `[% loop.last ? '' : ',' %]`:

``` postgres
[% FOREACH col IN column -%]
    [% col %] TEXT NOT NULL[% loop.last ? '' : ',' %]
[% END -%]
```

Now the comma will be omitted for the last iteration of the loop. The fix for
the verify script is even simpler: use `join()` [VMethod] instead of a
`FOREACH` loop to emit all the columns in a single expression:

``` postgres
SELECT [% column.join(', ') %]
  FROM [% IF table %][% table %][% ELSE %][% change %][% END %];
```

Really simplifies things, doesn't it?

Better still, going back to the deploy template, we can add data types for
each column. Try this on for size:

``` sh
[% FOREACH col IN column -%]
    [% col %] [% type.item( loop.index ) or 'TEXT' %] NOT NULL[% loop.last ? '' : ',' %]
[% END -%]
);
```

As we iterate over the list of columns, simply pass `loop.index` to the
`item()` [VMethod] on the `type` variable to get the corresponding type.
Then specify a type for each column when you create the change:

``` sh
> sqitch add corp_widgets --template createtable \
  -s schema=corp -s table=widgets \
  -s column=id -s type=SERIAL \
  -s column=name -s type=TEXT \
  -s column=quantity -s type=INTEGER \
  -n 'Add corp.widgets table.'
```

This yields a much more comprehensive deploy script:

``` postgres
-- Deploy corp_widgets

BEGIN;

SET search_path TO corp,public;

CREATE TABLE widgets (
    id SERIAL NOT NULL,
    name TEXT NOT NULL,
    quantity INTEGER NOT NULL
);

COMMIT;
```

[Template Toolkit]: http://tt2.org/
[VMethod]: http://tt2.org/docs/manual/VMethods.html "Template Toolkit Docs: Virtual Methods"

Go Crazy
--------

The basics for creating task-specific change templates are baked into Sqitch,
and a transparent upgrade to advanced templating is a simple install away. I
can imagine lots of uses for task-specific changes, including:

* Adding schemas, users, procedures, and views
* Modifying tables to add columns, constraints and indexes
* Inserting or Updating data

Maybe folks will even start sharing templates! You should subscribe to the
[mail list] to find out. See you there?

[mail list]: https://groups.google.com/forum/#!forum/sqitch-users


