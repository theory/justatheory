--- 
date: 2012-05-01T04:09:12Z
slug: sqitch-steps
title: "Sqitch Status: A Step at a Time"
aliases: [/computers/databases/sqitch-steps.html]
tags: [Sqitch, SQL change management, SQL]
type: post
---

I've just released [Sqitch v0.20-TRIAL], the third testing release of Sqitch.
Since last week, I've implemented [`add-step`]. So let's have a look-see at what
all it can do. First, let's initialize a Sqitch project.

    > mkdir myproj 
    > cd myproj 
    myproj> git init
    Initialized empty Git repository in myproj/.git/
    myproj> sqitch --engine pg init
    Created sql/deploy
    Created sql/revert
    Created sql/test
    Created ./sqitch.conf

Doesn't look like much, does it? Let's set the database name and look at the
configuration:

    myproj> sqitch config core.pg.db_name flipr_test
    myproj> less sqitch.conf
    [core]
        engine = pg
        # plan_file = sqitch.plan
        # sql_dir = sql
        # deploy_dir = sql/deploy
        # revert_dir = sql/revert
        # test_dir = sql/test
        # extension = sql
    # [core "pg"]
        # db_name = 
        # client = psql
        # sqitch_schema = sqitch
        # password = 
        # port = 
        # host = 
        # username = 
    [core "pg"]
        db_name = flipr_test

I've made an effort to make the default configuration file as useful as possible
by including all the core and engine settings. Defaults are present, too, but
commented-out. Some you'd probably never want to change in the local file, but
might in your user file or in the system configuration file. Peruse the
[`sqitch-config` man page][`add-step`] for all the Git-like awesomeness.s

So now we can add a step:

    myproj> sqitch add-step user_roles
    Created sql/deploy/user_roles.sql
    Created sql/revert/user_roles.sql
    Created sql/test/user_roles.sql

Wee! Again, doesn't look like much, I know. But in fact the generated scripts
are created from [Template::Tiny] templates, and again, they can be overridden
on a user or system basis. Have a look at the [`add-step` man page][`add-step`]
for the details. Or just start with what's there: edit the generated scripts to
deploy and revert your changes. Go crazy. The deploy script looks like this:

    myproj> less sql/deploy/user_roles.sql 
    -- Deploy user_roles

    BEGIN;

    -- XXX Add DDLs here.

    COMMIT;

Next up, deployment. I think that will require that the plan interface be
written, first. I'll be getting on that tomorrow.

  [Sqitch v0.20-TRIAL]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.20-TRIAL
  [`add-step`]: https://metacpan.org/release/DWHEELER/App-Sqitch-0.20-TRIAL/view/lib/sqitch-add-step.pod
  [Template::Tiny]: https://metacpan.org/pod/Template::Tiny
