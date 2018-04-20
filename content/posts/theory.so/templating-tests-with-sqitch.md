--- 
date: 2014-01-13T14:11:00Z
title: Templating Tests with Sqitch
url: /sqitch/2014/01/13/templating-tests-with-sqitch/
tags: [Sqitch, pgTAP]
---

Back in September, [I described] how to create custom deploy, revert, and
verify scripts for various types of [Sqitch] changes, such as adding a new
table. Which is cool and all, but what I've found while developing databases
at [work] is that I nearly always want to create a test script with the same
name as a newly-added change.

So for the recent v0.990 release, the [`add` command] gained the ability to
generate arbitrary script files from templates. To get it to work, we just
have to create template files. Templates can go into `~/.sqitch/templates`
(for personal use) or in `$(sqitch --etc-path)/templates` (for use by
everyone on a system). The latter is where templates are installed by
default. Here's what it looks like:

``` sh
> ls $(sqitch --etc-path)/templates
deploy  revert  verify
> ls $(sqitch --etc-path)/templates/deploy
firebird.tmpl  mysql.tmpl  oracle.tmpl  pg.tmpl  sqlite.tmpl
```

Each directory defines the type of script and the name of the directory in
which it will be created. The contents are default templates, one for each
engine.

To create a default test template, all we have to do is create a template for our preferred engine in a directory named `test`. So I created `~/.sqitch/templates/test/pg.tmpl`. Here it is:

``` postgres
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test [% change %]!');

SELECT finish();
ROLLBACK;
```

This is my standard boilerplate for tests, more or less. It just loads
[pgTAP], sets the plan, runs the tests, finishes and rolls back. See this
template in action:

``` sh
> sqitch add whatever -n 'Adds whatever.'
Created deploy/whatever.sql
Created revert/whatever.sql
Created test/whatever.sql
Created verify/whatever.sql
Added "whatever" to sqitch.plan
```

Cool, it added the test script. Here’s what it looks like:

``` postgres
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SELECT pass('Test whatever!');

SELECT finish();
ROLLBACK;
```

Note that it replaced the `change` variable in the call to `pass()`. All
ready to start writing tests! Nice, right? If we don't want the test script
created -- for example when adding a column to a table for which a test
already exists -- we use the `--without` option to omit it:

``` sh
> sqitch add add_timestamp_column --without test -n 'Adds whatever.'
Created deploy/add_timestamp_column.sql
Created revert/add_timestamp_column.sql
Created verify/add_timestamp_column.sql
Added "add_timestamp_column" to sqitch.plan
```

Naturally you'll want to update the existing test to validate the new column.

In the [previous templating post], we added custom scripts as for `CREATE
TABLE` changes; now we can add a test template, too. This one takes advantage
of the advanced features of [Template Toolkit]. We name it
`~/.sqitch/templates/test/createtable.tmpl` to complement the deploy,
revert, and verify scripts created previously:

``` postgres
-- Test [% change %]
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO [% IF schema %][% schema %],[% END %]public;

SELECT has_table('[% table or change %]');
SELECT has_pk( '[% table or change %]' );

[% FOREACH col IN column -%]
SELECT has_column(        '[% table or change %]', '[% col %]' );
SELECT col_type_is(       '[% table or change %]', '[% col %]', '[% type.item( loop.index ) or 'text' %]' );
SELECT col_not_null(      '[% table or change %]', '[% col %]' );
SELECT col_hasnt_default( '[% table or change %]', '[% col %]' );

[% END %]
SELECT finish();
ROLLBACK;
```

As [before], we tell the [`add` command] to use the `createtable` templates:

``` sh
> sqitch add corp_widgets --template createtable \
  -s schema=corp -s table=widgets \
  -s column=id -s type=SERIAL \
  -s column=name -s type=TEXT \
  -s column=quantity -s type=INTEGER \
  -n 'Add corp.widgets table.'
```

This yields a very nice test script to get you going:

``` postgres
-- Test corp_widgets
SET client_min_messages TO warning;
CREATE EXTENSION IF NOT EXISTS pgtap;
RESET client_min_messages;

BEGIN;
SELECT no_plan();
-- SELECT plan(1);

SET search_path TO corp,public;

SELECT has_table('widgets');
SELECT has_pk( 'widgets' );

SELECT has_column(        'widgets', 'id' );
SELECT col_type_is(       'widgets', 'id', 'SERIAL' );
SELECT col_not_null(      'widgets', 'id' );
SELECT col_hasnt_default( 'widgets', 'id' );

SELECT has_column(        'widgets', 'name' );
SELECT col_type_is(       'widgets', 'name', 'TEXT' );
SELECT col_not_null(      'widgets', 'name' );
SELECT col_hasnt_default( 'widgets', 'name' );

SELECT has_column(        'widgets', 'quantity' );
SELECT col_type_is(       'widgets', 'quantity', 'INTEGER' );
SELECT col_not_null(      'widgets', 'quantity' );
SELECT col_hasnt_default( 'widgets', 'quantity' );


SELECT finish();
ROLLBACK;
```

I don't know about you, but I'll be using this functionality *a lot.*

[I described]: /sqitch/2013/09/06/sqitch-templating/
[Sqitch]: http://sqitch.org/ "Sane database schema change management"
[work]: http://iovation.com/
[`add` command]: https://metacpan.org/pod/sqitch-add
[pgTAP]: http://pgtap.org/
[previous templating post]: /sqitch/2013/09/06/sqitch-templating/
[Template Toolkit]: http://tt2.org/
[before]: /sqitch/2013/09/06/sqitch-templating/

