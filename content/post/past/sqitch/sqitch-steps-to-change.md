--- 
date: 2012-06-22T14:28:31Z
slug: sqitch-steps-to-change
title: "Sqitch: Rename Step Objects and the SQL Directory?"
aliases: [/computers/databases/sqitch-steps-to-change.html]
tags: [Sqitch, SQL, database, change management, naming]
type: post
---

After all of the [thinking] and [rethinking] about how to manage a Sqitch plan,
I am just about done with all the changes to make it all work. One of the
changes I’ve made is that tags are no longer objects that stand on their own
between change steps, but are simply names the refer to specific change steps.
Not only is this much more like how a VCS thinks of tags (basically another name
for a single commit), but it also greatly simplifies the code for iterating over
a plan and updating metadata in the database.

But now that a plan is, in its essence, just a list of “steps”, I’m wondering if
I should change that term. I originally used the term “steps” because the
original plan was to have a deploy work on a tag-to-tag basis, where a single
tag could have a series of changes associated with it. By that model, each
change was a “step” toward deploying the tag. If any of the steps for a single
tag failed, they were all reverted.

But while one can still specify a tag as a deploy target (and optionally have it
revert to an earlier tag one failure), it no longer makes sense to think of each
change script as a step toward deploying a target. It’s just a change. Yes, as
an object it has separate deploy, revert, and test scripts associated with it,
but I’m thinking it still makes sense to call them “changes” instead of “steps.”
Because they’re individual things, rather than collections of things that lead
to some goal.

What do you think?

In other renaming news, I’m thinking of changing the default directory that
stores the step/change scripts. Right now it’s `sql` (though you can make it
whatever you want). The plan file goes into the current directory (assumed to be
the root directory of your project), as does the local configuration file. So
the usual setup is:

    % find .
    ./sqitch.conf
    ./sqitch.plan
    ./sql/deploy/
    ./sql/revert/
    ./sql/test/

I’m thinking of changing this in two ways:

-   Make the default location of the plan file be in the top-level script
    directory. This is because you might have different Sqitch change
    directories for different database platforms, each with its own plan file.
-   Change the default top-level script directory to `.`.

As a result, the usual setup would be:

    % find .
    ./sqitch.conf
    ./sqitch.plan
    ./deploy/
    ./revert/
    ./test/

If you still wanted the change scripts kept in all in a subdirectory, say `db/`,
it would be:

    % find .
    ./sqitch.conf
    ./db/sqitch.plan
    ./db/deploy/
    ./db/revert/
    ./db/test/

And if you have a project with, say, two sqitch deployment setups, one for
PostgreSQL and one for SQLite, you might make it:

    % find .
    ./sqitch.conf
    ./postgres/sqitch.plan
    ./postgres/deploy/
    ./postgres/revert/
    ./postgres/test/
    ./sqlite/sqitch.plan
    ./sqlite/deploy/
    ./sqlite/revert/
    ./sqlite/test/

This works because the configuration file has separate sections for each engine
(PostgreSQL and SQLite), and so can be used for all the projects; only the
`--top-dir` option would need to change to switch between them. Each engine has
its own plan file.

And yeah, having written out here, I’m pretty convinced. What do you think?
Comments welcome.

  [thinking]: /computers/databases/evolving-sqitch-plan.html
  [rethinking]: /computers/databases/sqitch-vcs-again.html
