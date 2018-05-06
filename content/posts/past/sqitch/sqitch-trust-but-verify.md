--- 
date: 2013-01-04T00:57:11Z
slug: sqitch-trust-but-verify
title: "Sqitch: Trust, But Verify"
aliases: [/computers/databases/sqitch-trust-but-verify.html]
tags: [Sqitch, SQL, version control, change management]
---

<p>New today: <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.950/">Sqitch v0.950</a>. There are a few bug fixes, but the most interesting new feature in this release is the <a href="https://metacpan.org/module/App::Sqitch::Command::verify"><code>verify</code> command</a>, as well as the complementary <code>--verify</code> option to the <a href="https://metacpan.org/module/App::Sqitch::Command::deploy"><code>deploy</code> command</a>. The <a href="https://metacpan.org/module/App::Sqitch::Command::add"><code>add</code> command</a> has created <code>test</code> scripts since the beginning; they were renamed <code>verify</code> in v0.940. In v0.950 these scripts are actually made useful.</p>

<p>The idea is simply to test that a deploy script did what it was supposed to do. Such a test should make no assumptions about data or state other than that affected by the deploy script, so that it can be run against a production database without doing any damage. If it finds that the deploy script failed, it should die.</p>

<p>This is easier than you might at first think. Got a Sqitch change that creates a table with two columns? Just <code>SELECT</code> from it:</p>

<pre><code>SELECT user_id, name
  FROM user
 WHERE FALSE;
</code></pre>

<p>If the table does not exist, the query will die. Got a change that creates a function? Make sure it was created by checking a privilege:</p>

<pre><code>SELECT has_function_privilege('insert_user(text, text)', 'execute');
</code></pre>

<p>PostgreSQL will throw an error if the function does not exist. Not running PostgreSQL? Well, you’re probably not using Sqitch <a href="https://github.com/theory/sqitch/issues?labels=engine&amp;state=open">yet</a>, but if you were, you might force an error by dividing by zero. Here’s an example verifying that a schema exists:</p>

<pre><code>SELECT 1/COUNT(*)
  FROM information_schema.schemata
 WHERE schema_name = 'myapp';
</code></pre>

<p>At this point, Sqitch doesn’t care at all what you put into your verify scripts. You just need to make sure that they indicate failure by throwing an error when passed to the database command-line client.</p>

<p>The best time to run a change verify script is right after deploying the change. The <code>--verify</code> option to the <a href="https://metacpan.org/module/App::Sqitch::Command::deploy"><code>deploy</code> command</a> does just that. If a verify script fails, the deploy is considered to have failed. Here’s what failure looks like:</p>

<pre><code>&gt; sqitch deploy
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
</code></pre>

<p>Good, right? In addition, you can always verify the state of a database using the <a href="https://metacpan.org/module/App::Sqitch::Command::verify"><code>verify</code> command</a>. It runs the verify scripts for all deployed changes. It also ensures that all the deployed changes were deployed in the same order as they’re listed in the plan, and that no changes are missing. The output is similar to that for <code>deploy</code>:</p>

<pre><code>&gt; sqitch verify
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
</code></pre>

<p>Don’t want verification tests/scripts? Use <code>--no-verify</code> when you call <a href="https://metacpan.org/module/App::Sqitch::Command::add"><code>sqitch add</code></a> and none will be created. Or tell it never to create verify scripts by setting the turning off the <code>add.with_verify</code> option:</p>

<pre><code>sqitch config --bool add.with_verify no
</code></pre>

<p>If you somehow run <code>deploy --verify</code> or <code>verify</code> anyway, Sqitch will emit a warning for any changes without verify scripts, but won’t consider them failures.</p>

<h3>Up Front Dependency Checking</h3>

<p>The other significant change in v0.950 is that the <code>deploy</code> and <code>revert</code> commands (and, by extension the <a href="https://metacpan.org/module/App::Sqitch::Command::deploy"><code>rebase</code> command</a>) now verify that dependencies have been checked before deploying or reverting anything. Previously, Sqitch checked the dependencies for each change before deploying it, but it makes much more sense to check them for all changes to be deployed before doing anything at all. This reduces the chances of unexpected reversions.</p>

<p>Still hacking on Sqitch, of course, though nearly all the commands I initially envisioned are done. <a href="https://github.com/theory/sqitch/issues?milestone=3">Next up</a>, I plan to finally implement support for <a href="http://sqlite.org/">SQLite</a>, add a few more commands to simplify plan file modification, and to create a new site, since <a href="http://sqlite.org/">the current site</a> is woefully out-of-date. Until then, though, check out <a href="http://www.slideshare.net/justatheory/sane-sql-change-management-with-sqitch">this presentation</a> and, of course, <a href="https://metacpan.org/module/sqitchtutorial">the tutorial</a>.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-trust-but-verify.html">old layout</a>.</small></p>


