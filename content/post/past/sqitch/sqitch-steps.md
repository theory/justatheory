--- 
date: 2012-05-01T04:09:12Z
slug: sqitch-steps
title: "Sqitch Status: A Step at a Time"
aliases: [/computers/databases/sqitch-steps.html]
tags: [Sqitch, SQL change management, SQL]
type: post
---

<p>I've just released <a href="http://search.cpan.org/dist/App-Sqitch-0.20-TRIAL/">Sqitch v0.20-TRIAL</a>, the third testing release of Sqitch. Since last week, I've implemented <a href="http://search.cpan.org/dist/App-Sqitch-0.20-TRIAL/lib/sqitch-add-step.pod"><code>add-step</code></a>. So let's have a look-see at what all it can do. First, let's initialize a Sqitch project.</p>

<pre><code>&gt; mkdir myproj 
&gt; cd myproj 
myproj&gt; git init
Initialized empty Git repository in myproj/.git/
myproj&gt; sqitch --engine pg init
Created sql/deploy
Created sql/revert
Created sql/test
Created ./sqitch.conf
</code></pre>

<p>Doesn't look like much, does it? Let's set the database name and look at the configuration:</p>

<pre><code>myproj&gt; sqitch config core.pg.db_name flipr_test
myproj&gt; less sqitch.conf
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
</code></pre>

<p>I've made an effort to make the default configuration file as useful as possible by including all the core and engine settings. Defaults are present, too, but commented-out. Some you'd probably never want to change in the local file, but might in your user file or in the system configuration file. Peruse the <a href="http://search.cpan.org/dist/App-Sqitch-0.20-TRIAL/lib/sqitch-add-step.pod"><code>sqitch-config</code> man page</a> for all the Git-like awesomeness.s</p>

<p>So now we can add a step:</p>

<pre><code>myproj&gt; sqitch add-step user_roles
Created sql/deploy/user_roles.sql
Created sql/revert/user_roles.sql
Created sql/test/user_roles.sql
</code></pre>

<p>Wee! Again, doesn't look like much, I know. But in fact the generated scripts are created from <a href="http://search.cpan.org/perldoc?Template::Tiny">Template::Tiny</a> templates, and again, they can be overridden on a user or system basis. Have a look at the <a href="http://search.cpan.org/dist/App-Sqitch-0.20-TRIAL/lib/sqitch-add-step.pod"><code>add-step</code> man page</a> for the details. Or just start with what's there: edit the generated scripts to deploy and revert your changes. Go crazy. The deploy script looks like this:</p>

<pre><code>myproj&gt; less sql/deploy/user_roles.sql 
-- Deploy user_roles

BEGIN;

-- XXX Add DDLs here.

COMMIT;
</code></pre>

<p>Next up, deployment. I think that will require that the plan interface be written, first. I'll be getting on that tomorrow.</p>
