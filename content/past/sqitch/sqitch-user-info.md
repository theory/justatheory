--- 
date: 2012-07-10T22:10:43Z
slug: sqitch-user-info
title: "Sqitch Status: Add User Info?"
aliases: [/computers/databases/sqitch-user-info.html]
tags: [Sqitch]
type: post
---

<p>Before I make a non-dev release of <a href="http://sqitch.org/">Sqitch</a>, I want to make sure that the plan file format is nailed down. I’m pretty happy with where it is right now, but there are a couple of changes I’m considering making now, in anticipation of possibly having to make them later. And I want your help deciding what to change.</p>

<p>tl;dr: Should the following changes be made to the Sqitch plan?</p>

<ul>
<li>Add the name and email address of the user who added a change</li>
<li>Add a comment about a change</li>
<li>Use a project name to allow cross-project dependency declaration</li>
</ul>


<p>Read on for details.</p>

<h3>User Info</h3>

<p>Right now, Sqitch requires a project URI. It puts it into the configuration when you create a new project, and then uses it in the text hashed to create unique change IDs. The point of the URI is to minimize the chances that changes in two different projects will have the same IDs, because the only other information uses to generate the hash is the change name and the name of the last preceding tag.</p>

<p>The reason I chose to do this—rather than to just hash the body of the change deploy script or to include the ID of the previous change in the hashed data—is so that, during development time, the script can be changed any number of times and the ID won’t change. This allows deploys and reverts to happen more easily as changes are made (and this would be pretty common with test-driven development). It also allows changes to be re-ordered in the plan, if necessary (though I don’t expect <em>that</em> to be a common requirement). If you don’t specify a URI when you initialize your project, Sqitch will create a UUID-based URI for you.</p>

<p>But another possible approach is to add more metadata to the plan for each change. For example, in addition to the change name and any dependencies, we might, like Git, include the name and email address of the user who added the change to the plan. Call this person the “planner”. And perhaps we include a timestamp, as well. Such a line might look like this:</p>

<pre><code>users_table :roles :pgcrypto 2012-07-10T20:51:58Z Barack Obama &lt;barack@whitehouse.gov&gt;
</code></pre>

<p>While we’re at it, why not allow a description of the change to be added, too?</p>

<pre><code>users_table :roles :pgcrypto 2012-07-10T20:51:58Z Barack Obama &lt;barack@whitehouse.gov&gt; This change adds the users table to the database.
</code></pre>

<p>Adding this thing via the <code>add</code> command would look like this:</p>

<pre><code>sqitch add users_table --requires roles --requires pgcrypto \
-m ' This change adds the users table to the database.'
</code></pre>

<p>I’m less sure about the comment than the planner info. Perhaps it could be only one line. Or maybe we allow it to be as long as the user wants, with newlines escaped. Or perhaps that just makes it too messy? On the other hand, it would discourage editing the plan file directly, which would probably be a good idea.</p>

<p>Anyway, this would allow for attribution of the change. Some of this information could be included in the database when the change was deployed. And the project would no longer need a unique URI, because the chances of the same person with the same email address adding a change to two projects with the same name at the same time would be next to nil. Not only that, it makes it easier to get a flavor for who is responsible for adding changes.</p>

<p>As with Git, this information would be available via the <code>log</code> command, which shows a history of changes to the database, including deployed changes, failed deploys, and reverts. There might be headers for the “Planner” and the “Deployer” (or “Reverter”). These are the users who added the change to the plan and the user who deployed the change to or reverted it from the database. The parallel here is Git’s “Committer” and “Author” user credits.</p>

<h3>All in a Name</h3>

<p>Another issue is cross-project dependency specification. Some databases I’ve seen at <a href="http://iovation.com/"><code>$work</code></a> and  heard about in other organizations are built from multiple projects. To some degree, I think cross-project dependencies can be managed ad-hoc, in that an database might require certain <a href="http://www.postgresql.org/docs/9.1/static/extend-extensions.html">extensions</a>, or versions of some other app. But it would be useful to allow Sqitch-based projects to be aware of each other.</p>

<p>I think this can be achieved by replacing the project URI with a name. This name would be used when hashing change IDs, of course, but it could also be used to specify dependencies. For example, say that I am adding change <code>widget_summary</code>. It’s a function that performs analytics queries against a database built by the “widgets” project, which has its own Sqitch plan. At a minimum, it needs access to a “sales” table, which is added by a change named <code>sales_table</code> in the “widgets” Sqitch plan. Normally, Sqitch dependencies are specified with a leading colon. To depend on a step from another project, we just prepend that project’s name, like so:</p>

<pre><code>sqitch add widget_summary --requires widgets:sales_table
</code></pre>

<p>The normal dependency verification of the <code>add</code> command would not apply here, because the specified step does not appear in the plan. But the <code>deploy</code> command would check for it, and hurl if it is not satisfied. This is a simple addition to the current <code>:name</code> structure for required dependencies. We can also easily specify conflicts by extending the <code>!name</code> syntax:</p>

<pre><code>sqitch add widget_summary --conflicts widgets!dr_evil
</code></pre>

<p>And of course it would support tags by extending the current <code>:@name</code> syntax (and probably recommend, since it’s completely unambiguous):</p>

<pre><code>sqitch add widget_summary --requires widgets:@v1_0_0
</code></pre>

<p>And perhaps we can even allow it to specify a project name without requiring a specific deployment target, using <code>widgets:</code> or <code>widgets!</code>.</p>

<p>I don’t plan to add the specific support for specifying and checking for dependencies in this way just now; that would be getting a bit ahead of myself, I think. But I <em>do</em> expect to need it before long, and I think it would be preferable to use a name rather than a URI when specifying dependencies. Yes, a name is less unique, but I don’t think it would be common to deploy two projects with the same names to the same database.</p>

<p>So, what do you think? Are these worthwhile changes to make now? I’m reasonably convinced that they are, but I hate operating in a vacuum, and have received great feedback to my proposals in the past. So I welcome your feedback now.</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-user-info.html">old layout</a>.</small></p>


