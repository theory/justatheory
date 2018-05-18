--- 
date: 2012-05-31T21:20:42Z
slug: evolving-sqitch-plan
title: The Ever Evolving Sqitch Plan
aliases: [/computers/databases/evolving-sqitch-plan.html]
tags: [Sqitch, SQL, change management, VCS, database]
type: post
---

<p>I’ve been working on the parser for the proposed new <a href="/computers/databases/sqitch-plan.html">deployment plan format</a>, and spent a day thinking it wasn’t going to work at all. But by the end of the day yesterday, I was back on board with it. I think I’ve also figured out how to eliminate the VCS dependency (and thus a whole level of complication). So first, the plan format:</p>

<ul>
<li>Names of things (steps and tags) cannot start or end in punctuation characters</li>
<li><code>@</code> indicates a tag</li>
<li><code>+</code> indicates a step to be deployed</li>
<li><code>-</code> indicates a step to be reverted</li>
<li><code>#</code> starts a comment</li>
<li><code>:</code> indicates a required step</li>
<li><code>!</code> indicates a conflicting step</li>
<li><code>%</code> is for Sqitch directives</li>
</ul>


<p>So, here’s an example derived from a <a href="/computers/databases/sqitch-plan.html">previous example</a>:</p>

<pre><code>%plan-syntax-v1
+roles
+users_table
+dr_evil
@alpha

# Some procedures.
+add_user :roles :users_table
+del_user :@alpha
-dr_evil
+upd_user :add_user !dr_evil
@beta     # woo!
</code></pre>

<p>So we start with a directive for the version of the plan file (thanks for <a href="/computers/databases/sqitch-plan.html#comment-537891454">the suggestion</a>, Tom Davis!). Then we have deployments of the <code>roles</code>, <code>users_table</code>, and <code>dr_evil</code> steps. After that, it’s tagged as <code>alpha</code>.</p>

<p>Next, we have a comment, then the deployment of the <code>add_user</code> step. It requires that the <code>roles</code> and <code>users_table</code> steps be deployed. Then we deploy <code>del_user</code>. It requires all steps as of the <code>$alpha</code> tag. Next we revert the <code>dr_evil</code> step. Why? Because the next line deploys <code>upd_user</code>, which conflicts with <code>dr_evil</code> (and requires <code>add_user</code>). And finally, we tag it as <code>beta</code>.</p>

<p>There are a number of things I like about these changes:</p>

<ul>
<li><p>Dependencies are spelled out in the plan file, rather than the deploy scripts. This allows the deploy scripts to have nothing special about them at all.</p></li>
<li><p>We now have a way to explicitly revert a step as part of the overall plan. This is useful for ensuring that conflicts can be dealt with.</p></li>
<li><p>We can deploy to any point in the plan by specifying a step:</p>

<pre><code>sqitch deploy add_user
</code></pre>

<p>Or a tag:</p>

<pre><code>sqitch deploy @alpha
</code></pre>

<p>For steps that are duplicated, we can disambiguate by specifying a tag:</p>

<pre><code>sqitch deploy dir_evil --as-of @alpha
</code></pre>

<p>Naturally, this requires that a step not be repeated within the scope of a single tag.</p></li>
</ul>


<p>Now, as for the VCS dependency, my impetus for this was to allow <code>Sqitch</code> to get earlier versions of a particular deploy script, so that it could be modified in place and redeployed to make changes inline, as described in <a href="/computers/databases/sql-change-management-sans-redundancy.html">an earlier post</a>. However I’ve been troubled as to how to indicate in the plan where to look in the VCS history for a particular copy of a file. Yesterday, I had an insight: why do I need the earlier version of a particular deploy script at all? There are two situations where it would be used, assuming a plan that mentions the same step at two different points:</p>

<ol>
<li>To run it as it existed at the first point, and to run it the second time as it exists at <em>that</em> time.</li>
<li>To run it in order to revert from the second point to the first.</li>
</ol>


<p>As to the first, I could not think of a reason why that would be necessary. If I’m bootstrapping a new database, and the changes in that file are idempotent, is it really necessary to run the earlier version of the file at all? Maybe it is, but I could not think of one.</p>

<p>The second item is the bit I wanted, and I realized (thanks in part to prompt from <a href="https://www.pgcon.org/2012/schedule/speakers/244.en.html">Peter van Hardenberg</a> while at PGCon) that I don’t need a VCS to get the script as it was at the time it was deployed. Instead, all I have to do is <em>store the script in the database as it was at the time it was run.</em> Boom, reversion time travel without a VCS.</p>

<p>As an example, take the plan above. Say we have a database that has been deployed all the way to <code>@beta</code>. Let’s add the <code>add_user</code> step again:</p>

<pre><code>%plan-syntax-v1
+roles
+users_table
+dr_evil
@alpha

# Some procedures.
+add_user :roles :users_table
+del_user :@alpha
-dr_evil
+upd_user :add_user !dr_evil
@beta     # woo!

+crypto
+add_user :roles :users_table :crypto
@gamma
</code></pre>

<p>The last two lines are the new ones. At this point, the <code>sql/deploy/add_user.sql</code> script has been modified to fix a bug that now requires the <code>crypto</code> step. If we deploy to a new database, Sqitch will notice that the same step is listed twice and apply it only once. This works because, even though <code>add_user</code> is listed before <code>pg_crypto</code>, it is actually applied as described in its second declaration. So the run order would be:</p>

<ul>
<li><code>crypto</code></li>
<li><code>add_user</code></li>
<li><code>del_user</code></li>
<li><code>upd_user</code></li>
</ul>


<p>Note that this works because <code>crypto</code> declares no dependencies itself. If it did, it would be shuffled as appropriate. It would not work if it required, say, <code>upd_user</code>, as that would create a circular dependency (<code>add_user</code> — <code>crypto</code> — <code>upd_user</code> — <code>add_user</code>).</p>

<p>Now say we want to deploy the changes to the production database, which is currently on <code>@beta</code>. That simply runs:</p>

<ul>
<li><code>crypto</code></li>
<li><code>add_user</code></li>
</ul>


<p>If something went wrong, and we needed to revert, all Sqitch has to do is to read <code>add_user</code> from the database, <em>as it was deployed previously,</em> and run that. This will return the <code>add_user</code> function to its previous state. So, no duplication and no need for a VCS.</p>

<p>The one thing that scares me a bit is being able to properly detect circular dependencies in the plan parser. I think it will be pretty straight-forward for steps that require other steps. Less so for steps that require tags. Perhaps it will just have to convert a tag into an explicit dependence on all steps prior to that tag.</p>

<p>So, I think this will work. But I’m sure I must have missed something. If you notice it please enlighten me in the comments. And thanks for reading this far!</p>
