--- 
date: 2012-05-26T00:18:02Z
slug: sqitch-dependencies
title: "Sqitch: Where to Define Dependencies?"
aliases: [/computers/databases/sqitch-dependencies.html]
tags: [Sqitch, SQL, database]
type: post
---

<p>I’ve been hard at work the last couple of days working on the new plan file format. It looks like this:</p>

<pre><code>roles
users_table
@alpha

# Some procedures.
add_user
del_user
upd_user
@beta     # woo!
</code></pre>

<p>The new code parses this, finding all steps and tags, and can rewrite the file exactly how it read it, including blank lines and comments. All of this is toward <a href="/computers/databases/sqitch-plan.html">requiring a plan file</a> and depending less on the VCS. I’ve also just added methods for adding new steps and tags to the plan. In doing so, made sure that all dependencies properly resolve, and throw an error if they don’t. Dependencies will then be written at the top of the deployment file like so:</p>

<pre><code>-- :requires: roles
-- :requires: users_table
</code></pre>

<p>The plan parser is smart enough to parse these out of the files when parsing the plan, so it’s easy for the user to add dependencies just by editing the deploy file.</p>

<p>As I was working on this, I realized that that may not be necessary. Since the plan file will now be required, we could instead specify dependencies in the plan file. Maybe something like this:</p>

<pre><code>roles
users_table
@alpha

# Some procedures.
add_user +roles +users_table
del_user +@alpha
upd_user +add_user -dr_evil
@beta     # woo!
</code></pre>

<p>The idea is that required steps and tags could be specified on the same line as the named step with preceding plus signs. Conflicting steps and tags could be specified with a preceding minus sign. Here, the <code>add_user</code> step requires the <code>roles</code> and <code>users_table</code> steps. The <code>del_user</code> step requires the <code>@alpha</code> tag. And the <code>upd_user</code> step requires the <code>add_user</code> step but conflicts with the <code>dr_evil</code> step.</p>

<p>There are a couple of upsides to this:</p>

<ul>
<li>Dependencies are specified all in once place.</li>
<li>Plan parsing is much faster, because it no longer has to also parse every deploy script.</li>
<li>There is no need for any special syntax in the deploy scripts, which could theoretically conflict with some database-specific script formatting (a stretch, I realize).</li>
</ul>


<p>But there are also downsides:</p>

<ul>
<li>Changing dependencies would require editing the plan file directly.</li>
<li>The appearance of the plan file is someone more obscure.</li>
<li>It’s more of a PITA to edit the plan file.</li>
<li>Adding commands to change dependencies in the plan file might be tricky.</li>
</ul>


<p>But I am thinking that the advantages might outweigh the disadvantages. Thoughts?</p>
