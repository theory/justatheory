--- 
date: 2012-06-01T18:25:00Z
slug: sqitch-vcs-again
title: "Sqitch: Back to the VCS"
aliases: [/computers/databases/sqitch-vcs-again.html]
tags: [Sqitch, SQL, change management, VCS, database]
---

<p>On reflection, the one thing that bothers me about the proposal to abandon the VCS in <a href="/computers/databases/evolving-sqitch-plan.html">yesterday’s post</a> is that things could be deployed out-of-order. Take these two sections from the example plan toward the end of the post:</p>

<pre><code># Some procedures.
+add_user :roles :users_table
+del_user :@alpha
-dr_evil
+upd_user :add_user !dr_evil
@beta     # woo!

+crypto
+add_user :roles :users_table :crypto
@gamma
</code></pre>

<p>If this was run on an empty database, it would be deployed in this order:</p>

<ul>
<li><code>+crypto</code></li>
<li><code>+add_user</code></li>
<li><code>+del_user</code></li>
<li><code>-dr_evil</code></li>
<li><code>+upd_user</code></li>
<li><code>@beta</code></li>
<li><code>@gamma</code></li>
</ul>


<p>Notice that <code>crypto</code> would be deployed <em>before</em> the <code>@beta</code> tag, despite the fact that it appears in the plan <em>after</em> <code>@beta</code>. Yes, one would end up with the correct database, but the actual deployment varies from the plan in a way that might be disconcerting to a user. I don’t like it.</p>

<p>Another issue is that there is no way to go back to <code>@beta</code> here, because there are no previous copies of   <code>add_user</code> in the database. In theory this probably would not often be a big deal, but in practice, hey, sometimes you just need to go back in time no matter what. Maybe you need to repeatedly test a data migration (as opposed to a DDL change). I can certainly imagine needing that flexibility. So much for my “insight.”</p>

<p>I’m back to thinking about VCS integration again. I know I keep going back and forth on this stuff. I apologize. I appreciate the <a href="/computers/databases/evolving-sqitch-plan.html#tb">thoughtful comments</a> and feedback I’ve received, and am taking the time to try to get this stuff right so that I can <em>stop</em> thinking about it in the future. I really want to reduce the complexity of database change management, but retain flexibility for those who need it. So yeah, I keep taking two steps forward and one step back, but there is overall forward momentum (I have had to trash less code than I expected).</p>

<h3>The Duplicative Pattern</h3>

<p>Back to my original complaint from yesterday: how can the plan indicate where to look in the VCS history for a particular copy of a file? As a corollary: is is possible to also support folks not using a VCS (which was one of the advantages to yesterday’s proposal)? Let’s take this plan as a working example:</p>

<pre><code>%plan-syntax-v1
+users_table
+add_user :users_table
+del_user :users_table
+upd_user :users_table
</code></pre>

<p>Let’s say that we need to fix a bug in <code>add_user</code>. First we have to add it to the plan again:</p>

<pre><code>% sqitch add add_user
Error: Step "add_user" already exists. Add a tag to modify it.
</code></pre>

<p>So we can’t repeat a step within a tag (or, in this case, when there are no tags). Let’s tag it and try again:</p>

<pre><code>% sqitch tag alpha
% sqitch add add_user -vv
notice: Copied sql/deploy/add_user.sql to sql/deploy/add_user@alpha.sql
notice: Copied sql/revert/add_user.sql to sql/revert/add_user@alpha.sql
notice: Copied sql/deploy/add_user.sql to sql/revert/add_user.sql
notice: Copied sql/test/add_user.sql to sql/test/add_user@alpha.sql
Backed up previous version of "add_user"
Added "add_user" step. Modify these files:
sql/deploy/add_user.sql
sql/revert/add_user.sql
sql/test/add_user.sql
</code></pre>

<p>I use added verbosity (<code>-vv</code>) here to show what files are copied for the “backup” (the “notice” lines).
So now the plan looks like this:</p>

<pre><code>%plan-syntax-v1
+users_table
+add_user :users_table
+del_user :users_table
+upd_user :users_table
@alpha

+add_user :add_user@alpha
</code></pre>

<p>Note how the new step implicitly requires the previous version of the step (as of <code>@alpha</code>), and thus all of its dependencies. This is a clean way to “upgrade” the step.</p>

<p>Now you can edit <code>sql/deploy/add_user.sql</code> to make your changes, starting with the existing code. You can also edit <code>sql/test/add_user.sql</code> in order to update the tests for the new version. You don’t need to edit <code>sql/revert/add_user.sql</code> unless your changes are not idempotent.</p>

<p>Of course, this pattern leads to all the code duplication <a href="/computers/databases/sql-change-management-sans-redundancy.html">I complained about before</a>, but there is nothing to be done in the absence of a VCS. The advantage is that we retain a complete history, so we can go back and forth as much as we want, regardless of whether we’re updating an existing database or creating a new database. The only change I need to make to the plan syntax is to ban the use of <code>@</code> in step and tag names. Probably a good idea, anyway.</p>

<p>By the way, if we omit the extra verbosity, the output would look like this:</p>

<pre><code>% sqitch add add_user
Backed up previous version of "add_user"
Added "add_user" step. Modify these files:
sql/deploy/add_user.sql
sql/revert/add_user.sql
sql/test/add_user.sql
</code></pre>

<p>Other than the “Backed up” line, the output is the same as for adding any other step. Maybe there would be something to say that the previous version was copied to the new version. But the point is to make it clear to the user what files are available to be edited.</p>

<h3>VCS Integration</h3>

<p>Let’s try again with a VCS. Starting at the same point as in the non-VCS example, we try to add a step</p>

<pre><code>% sqitch add add_user
Error: Step "add_user" already exists. Add a tag to modify it.
</code></pre>

<p>So add the tag:</p>

<pre><code>% sqitch tag alpha
% sqitch add add_user
Error: Cannot find reference to @alpha in the Git history. Please run `git tag alpha` to continue.
</code></pre>

<p>In order to be sure that we can use the VCS history, we need the tag there. Perhaps we could automatically add the tag in Git via <code>sqitch tag</code>, or have an option to do it. Either way, we need to have the same tag in the VCS so that we can travel back in time. So let’s do it:</p>

<pre><code>% git tag alpha -am 'Tag alpha for Sqitch.'
% sqitch add add_user
Added "add_user" step. Modify these files:
sql/deploy/add_user.sql
sql/revert/add_user.sql
sql/test/add_user.sql
</code></pre>

<p>Note the lack of a “Backed up” line. It’s not necessary, since the code is already preserved in the Git history. Now we can edit the files in place and commit them to Git as usual. Sqitch will ask Git for the <code>add_user</code> step files as of the <code>alpha</code> tag when deploying the first instance of the step, and the current version for the latter. One can add <code>add_user</code> as many times as one likes, as long as there are always tags between instances.</p>

<h3>Unbungled Bundle</h3>

<p>Here’s the clincher for this iteration of this thing. My <a href="http://search.cpan.org/~dwheeler/App-Sqitch-0.31-TRIAL/lib/sqitchtutorial.pod#Ship_It!">original plan for bundling</a> (that is, packaging up the plan and change scripts for distribution outside the VCS) had the generation of a plan with different names than the plan in the VCS. That is, running:</p>

<pre><code>% sqitch bundle
</code></pre>

<p>Against the above plan, the resulting plan in <code>bundle/sqitch.plan</code> would look something like this:</p>

<pre><code>%plan-syntax-v1
+users_table
+add_user :users_table
+del_user :users_table
+upd_user :users_table
@alpha

+add_user_v2 :add_user
</code></pre>

<p>Note the <code>add_user_v2</code> step there. Doesn’t exist in the original plan in the VCS, but was necessary in order to generate the change scripts for distribution bundling, so that all steps could be available for deployment outside the VCS:</p>

<pre><code>% ls bundle/sql/deploy/add_user*
bundle/sql/deploy/add_user.sql
bundle/sql/deploy/add_user_v2.sql
</code></pre>

<p>This meant that databases deployed from the VCS would have a different deployment plan (and deployment history) than those deployed from a tarball distributed with the bundled plan. But hey, if we can create the files with the tag name in them for the non-VCS environment, we can do the same when bundling. So now, the bundled plan will be <em>exactly the same as in the VCS</em>, and the migration files will just be named with the tag, as appropriate:</p>

<pre><code>% ls bundle/sql/deploy/add_user*
bundle/sql/deploy/add_user.sql
bundle/sql/deploy/add_user@alpha.sql
</code></pre>

<p><em>Much</em> better. Much more consistent throughout. And must less stuff stored in the database to boot (no full deploy scripts copied to the DB).</p>

<h3>Back to Work</h3>

<p>So, I’m off to to continue modifying the plan code to support the syntax I <a href="/computers/databases/evolving-sqitch-plan.html">proposed yesterday post</a>, as well as the ability to have duplicate steps under different tags. Then I will start working on this proposal for how to name scripts and duplicate them.</p>

<p>That is, assuming that nothing else comes up to make me revise my plans again. Man, I sure hope not. This proposal nicely eliminates inconsistencies in the plan and deployment history regardless of whether deploying from a VCS, a bundled distribution, or a non-VCS project, the results should be the same. And it was those inconsistencies that I had been struggling with.</p>

<p>But hey, if I have overlooked something (again!), please do let me know.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-vcs-again.html">old layout</a>.</small></p>


