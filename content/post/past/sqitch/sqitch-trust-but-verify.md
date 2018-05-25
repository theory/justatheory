--- 
date: 2013-01-04T00:57:11Z
slug: sqitch-trust-but-verify
title: "Sqitch: Trust, But Verify"
aliases: [/computers/databases/sqitch-trust-but-verify.html]
tags: [Sqitch, SQL, Version Control, Change Management]
type: post
---

New today: [Sqitch v0.950]. There are a few bug fixes, but the most interesting
new feature in this release is the [`verify` command], as well as the
complementary `--verify` option to the [`deploy` command]. The [`add` command]
has created `test` scripts since the beginning; they were renamed `verify` in
v0.940. In v0.950 these scripts are actually made useful.

The idea is simply to test that a deploy script did what it was supposed to do.
Such a test should make no assumptions about data or state other than that
affected by the deploy script, so that it can be run against a production
database without doing any damage. If it finds that the deploy script failed, it
should die.

This is easier than you might at first think. Got a Sqitch change that creates a
table with two columns? Just `SELECT` from it:

    SELECT user_id, name
      FROM user
     WHERE FALSE;

If the table does not exist, the query will die. Got a change that creates a
function? Make sure it was created by checking a privilege:

    SELECT has_function_privilege('insert_user(text, text)', 'execute');

PostgreSQL will throw an error if the function does not exist. Not running
PostgreSQL? Well, you’re probably not using Sqitch [yet], but if you were, you
might force an error by dividing by zero. Here’s an example verifying that a
schema exists:

    SELECT 1/COUNT(*)
      FROM information_schema.schemata
     WHERE schema_name = 'myapp';

At this point, Sqitch doesn’t care at all what you put into your verify scripts.
You just need to make sure that they indicate failure by throwing an error when
passed to the database command-line client.

The best time to run a change verify script is right after deploying the change.
The `--verify` option to the [`deploy` command] does just that. If a verify
script fails, the deploy is considered to have failed. Here’s what failure looks
like:

    > sqitch deploy
    Deploying changes to flipr_test
      + appschema ................. ok
      + users ..................... ok
      + insert_user ............... ok
      + change_pass @v1.0.0-dev1 .. ok
      + lists ..................... psql:verify/lists.sql:7: ERROR:  column "timestamp" does not exist
    LINE 1: SELECT nickname, name, description, timestamp
                                                ^
    Verify script "verify/lists.sql" failed.
    not ok
    Reverting all changes
      - change_pass @v1.0.0-dev1 .. ok
      - insert_user ............... ok
      - users ..................... ok
      - appschema ................. ok
    Deploy failed

Good, right? In addition, you can always verify the state of a database using
the [`verify` command]. It runs the verify scripts for all deployed changes. It
also ensures that all the deployed changes were deployed in the same order as
they’re listed in the plan, and that no changes are missing. The output is
similar to that for `deploy`:

    > sqitch verify
    Verifying flipr_test
      * appschema ................. ok
      * users ..................... ok
      * insert_user ............... ok
      * change_pass @v1.0.0-dev1 .. ok
      * lists ..................... ok
      * insert_list ............... ok
      * delete_list ............... ok
      * flips ..................... ok
      * insert_flip ............... ok
      * delete_flip @v1.0.0-dev2 .. ok
      * pgcrypto .................. ok
      * insert_user ............... ok
      * change_pass ............... ok
    Verify successful

Don’t want verification tests/scripts? Use `--no-verify` when you call
[`sqitch add`][`add` command] and none will be created. Or tell it never to
create verify scripts by setting the turning off the `add.with_verify` option:

    sqitch config --bool add.with_verify no

If you somehow run `deploy --verify` or `verify` anyway, Sqitch will emit a
warning for any changes without verify scripts, but won’t consider them
failures.

### Up Front Dependency Checking

The other significant change in v0.950 is that the `deploy` and `revert`
commands (and, by extension the [`rebase` command][`deploy` command]) now verify
that dependencies have been checked before deploying or reverting anything.
Previously, Sqitch checked the dependencies for each change before deploying it,
but it makes much more sense to check them for all changes to be deployed before
doing anything at all. This reduces the chances of unexpected reversions.

Still hacking on Sqitch, of course, though nearly all the commands I initially
envisioned are done. [Next up], I plan to finally implement support for
[SQLite], add a few more commands to simplify plan file modification, and to
create a new site, since [the current site][SQLite] is woefully out-of-date.
Until then, though, check out [this presentation] and, of course, [the
tutorial].

  [Sqitch v0.950]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.950/
  [`verify` command]: https://metacpan.org/module/App::Sqitch::Command::verify
  [`deploy` command]: https://metacpan.org/module/App::Sqitch::Command::deploy
  [`add` command]: https://metacpan.org/module/App::Sqitch::Command::add
  [yet]: https://github.com/theory/sqitch/issues?labels=engine&state=open
  [Next up]: https://github.com/theory/sqitch/issues?milestone=3
  [SQLite]: http://sqlite.org/
  [this presentation]: https://www.slideshare.net/justatheory/sane-sql-change-management-with-sqitch
  [the tutorial]: https://metacpan.org/module/sqitchtutorial
