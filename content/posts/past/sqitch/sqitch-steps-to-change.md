--- 
date: 2012-06-22T14:28:31Z
slug: sqitch-steps-to-change
title: "Sqitch: Rename Step Objects and the SQL Directory?"
aliases: [/computers/databases/sqitch-steps-to-change.html]
tags: [Sqitch, SQL, database, change management, naming]
---

<p>After all of the <a href="/computers/databases/evolving-sqitch-plan.html">thinking</a>
and <a href="/computers/databases/sqitch-vcs-again.html">rethinking</a> about how to
manage a Sqitch plan, I am just about done with all the changes to make it all
work. One of the changes I’ve made is that tags are no longer objects that
stand on their own between change steps, but are simply names the refer to
specific change steps. Not only is this much more like how a VCS thinks of
tags (basically another name for a single commit), but it also greatly
simplifies the code for iterating over a plan and updating metadata in the
database.</p>

<p>But now that a plan is, in its essence, just a list of “steps”, I’m wondering
if I should change that term. I originally used the term “steps” because the
original plan was to have a deploy work on a tag-to-tag basis, where a single
tag could have a series of changes associated with it. By that model, each
change was a “step” toward deploying the tag. If any of the steps for a single
tag failed, they were all reverted.</p>

<p>But while one can still specify a tag as a deploy target (and optionally have
it revert to an earlier tag one failure), it no longer makes sense to think of
each change script as a step toward deploying a target. It’s just a change.
Yes, as an object it has separate deploy, revert, and test scripts associated
with it, but I’m thinking it still makes sense to call them “changes” instead
of “steps.” Because they’re individual things, rather than collections of
things that lead to some goal.</p>

<p>What do you think?</p>

<p>In other renaming news, I’m thinking of changing the default directory that
stores the step/change scripts. Right now it’s <code>sql</code> (though you can make it
whatever you want). The plan file goes into the current directory (assumed to
be the root directory of your project), as does the local configuration file.
So the usual setup is:</p>

<pre><code>% find .
./sqitch.conf
./sqitch.plan
./sql/deploy/
./sql/revert/
./sql/test/
</code></pre>

<p> I’m thinking of changing this in two ways:</p>

<ul>
<li>Make the default location of the plan file be in the top-level script
directory. This is because you might have different Sqitch change
directories for different database platforms, each with its own plan file.</li>
<li>Change the default top-level script directory to <code>.</code>.</li>
</ul>


<p>As a result, the usual setup would be:</p>

<pre><code>% find .
./sqitch.conf
./sqitch.plan
./deploy/
./revert/
./test/
</code></pre>

<p>If you still wanted the change scripts kept in all in a subdirectory, say <code>db/</code>, it would be:</p>

<pre><code>% find .
./sqitch.conf
./db/sqitch.plan
./db/deploy/
./db/revert/
./db/test/
</code></pre>

<p>And if you have a project with, say, two sqitch deployment setups, one for PostgreSQL and one for SQLite, you might make it:</p>

<pre><code>% find .
./sqitch.conf
./postgres/sqitch.plan
./postgres/deploy/
./postgres/revert/
./postgres/test/
./sqlite/sqitch.plan
./sqlite/deploy/
./sqlite/revert/
./sqlite/test/
</code></pre>

<p>This works because the configuration file has separate sections for each
engine (PostgreSQL and SQLite), and so can be used for all the projects; only
the <code>--top-dir</code> option would need to change to switch between them. Each
engine has its own plan file.</p>

<p>And yeah, having written out here, I’m pretty convinced. What do you think?
Comments welcome.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-steps-to-change.html">old layout</a>.</small></p>


