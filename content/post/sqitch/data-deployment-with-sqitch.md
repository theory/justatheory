--- 
date: 2013-08-28T17:09:00Z
title: Data Deployment with Sqitch
aliases: [/sqitch/data/2013/08/28/data-deployment-with-sqitch/]
tags: [Sqitch, databases]
type: post
---

I've been thinking about data migrations. I love how well [Sqitch] works for
*schema* changes, but so far have avoided *data* changes. Some data ought to
be managed by the deployment process, rather than by end-user applications.
Lists of countries, for example. Yet none of [our] Sqitch-managed databases
include `INSERT`s, `UPDATE`s, or `DELETE`s in deploy scripts. Why not? Two
reasons:

1. These are mainly Postgres ports of existing Oracle databases. As such, I've
   written independent migration scripts that use [`oracle_fdw`] to copy data
   from Oracle. It made no sense to commit hard-coded changes to the deploy
   script, even for static data, as it was all to be copied from the old
   production Oracle databases --- often months after I wrote the migrations.

2. These projects include extensive [pgTAP] unit tests that expect to run many
   times against an empty database with no side effects. Having different data
   in testing than in production increases the likelihood of unforeseen
   behavioral variations. Better to expect *no* data in tests, freeing them to
   focus on units of behavior without regard to preexisting data.

Now that we have multiple Sqitch-deployed databases in production, the time
has come to address these issues.

Deploy Hooks for External Sources
---------------------------------

I propose to resolve the one-time migration requirement with [deploy hooks].
The idea is similar to [Git hooks]: Before or after any `sqitch deploy`, one
or more hook scripts can run. The impetus was to ensure some higher level of
consistency after every `deploy`. For example, a post-deploy hook might grant
privileges on all tables in a database. Another might run `VACCUM; ANALZYE;`.

But we could also use it for one-time data migrations. An option to `deploy`
will disable them, which would be useful for development and test databases.
Once the migration has been run in production, we just delete the migration
hook scripts from the project. Sqitch won't record hook executions, so adding
or removing them will be no problem.

I like this approach, as Sqitch will automatically run migration scripts, but
hooks will not change the interface of Sqitch itself. And it's more generally
useful. Hell, I might want deploy hook script that sends an email notification
announcing a deployment (though that might require adding support for
[non-SQL scripts]). There are all kinds of things for which hooks will prove
useful.

Changes for Static Data Maintenance
-----------------------------------

For data that must be tied to the deployment process, there are two
complications that have prevented me from simply managing them in normal
Sqitch changes:

1. There might be side-effects to the deployment. For example, a foreign key
   constraint to the `users` table, to identify the users who added rows to
   the database. But in a new database, perhaps there are no users --- and
   Sqitch doesn't create them, the app does. Chicken, meet egg.

2. The initial data set might derived from some external source, such as
   another database. Consequently, none of that data was defined in Sqitch
   deploy scripts. This situation complicates future updates of the data. We
   can add data via Sqitch in the future, but then we don't have the canonical
   list of all rows that should exist in all such databases.

However, I can think of no alternative that does not over-complicate Sqitch
itself. I considered adding another change-related script type, named
"update", to complement the existing deploy, verify, and revert scripts. But
oftentimes a data change would not be tied to a schema change, so the
corresponding deploy script would be a no-op. Seems silly.

I also considered adding a completely separate command specifically for
deploying data changes. Yet these data migrations are exactly like schema
changes: Sqitch must execute them in the proper order relative to other
changes, record successful or failed deployment, and be able to revert them
when required. The only difference is what's defined in them: data
modification rather than definition.

Through several drafts of this post, I have come around to the idea that I
should change nothing in Sqitch with regard to data deployments. A better
solution than the above, I believe, is organizational.

### Data Deploy Best Practice ###

Let the best practice for data deploys be this: they should be contained in
Sqitch changes, but such changes should contain *only* data modifications. No
change script should both define a table and insert its initial rows. Keep the
table and its data in separate changes --- keep DML separate from DDL.

For our list of countries, we might have a change named "countries", which
creates the `countries` table, and another, named "country_data", which
inserts the appropriate data into that table. Where necessary and appropriate,
these changes may use conditional paths to bring the data up-to-date and in
sync across deployments.

Conditions must deal with side-effects, such as foreign key constraints. Where
possible, such side effects ought be removed from deployment-managed data. For
tracking the user or users who added data to a database, for example, one can
use the tools of the source code repository (`git log`, `git blame`) to assign
blame. Other side-effects may be more necessary, but to the extent possible,
deployed data should be independent.

Naturally, unit tests must expect static data to be present, and be updated
when that data changes. We are, after all, talking about infrequently-updated
data. Frequently-updated data should have separate interfaces provided by
applications to change the data. Otherwise, how static is it, really?

  [Sqitch]: http://sqitch.org/
  [our]: http://iovation.com/
  [`oracle_fdw`]: http://pgxn.org/extension/oracle_fdw
  [pgTAP]: http://pgtap.org/
  [deploy hooks]: https://github.com/theory/sqitch/issues/96
  [Git hooks]: http://git-scm.com/docs/githooks
  [non-SQL scripts]: https://github.com/theory/sqitch/issues/1
