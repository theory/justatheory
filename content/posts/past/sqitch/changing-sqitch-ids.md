--- 
date: 2012-11-14T01:46:23Z
slug: changing-sqitch-ids
title: Thinking about Changing Sqitch Change IDs
aliases: [/computers/databases/changing-sqitch_ids.html]
tags: [Sqitch, Git, hashing, ID]
---

<p>When <a href="http://sqitch.org/">Sqitch</a>, (the database change management app I’ve been working on for the last several months) parses a deployment plan, it creates a unique ID for each change in the plan. This ID is a SHA1 hash generated from information about the change, which is a string that looks something like this:</p>

<pre><code>project flipr
change add_users_table
planner Marge N. O’Vera &lt;marge@example.com&gt;
date 2012-11-14T01:10:13Z
</code></pre>

<p>The nice thing about the ID is that it’s unique: it’s unlikely that the same user with the same email address will add a change with the same name to a project with the same name within a single second. If the plan includes a URI, that’s included, too, for additional uniqueness.</p>

<p>Note, however, that it does not include information about any other changes. Git, from which I modeled the generation of these IDS, always includes the parent commit SHA1 in its uniquely-identifying info. An example:</p>

<pre><code>&gt; git cat-file commit 744c01bfa3798360c1792a8caf784b650e52d89e               
tree d3a64897cca4538ff5c0c41db3f82ab033a09bec
parent 482a79ae2cda5085eed731be2e70739ab37997ee
author David E. Wheeler &lt;david@justatheory.com&gt; 1337355746 -0400
committer David E. Wheeler &lt;david@justatheory.com&gt; 1337355746 -0400

Timestamp v0.30.
</code></pre>

<p>The reason Git does this is so that a commit is not just uniquely identified globally, but so that it can <em>only follow an existing commit</em>. Mark Jason Dominus calls this <a href="http://perl.plover.com/yak/git/">Linus Torvalds' greatest invention</a>. Why? This is now Git knows it can fast-forward changes.</p>

<p>Why doesn’t Sqitch do something similar? My original thinking had been to make it easier for a database developer to do iterative development. And one of the requirements for that, in my experience, is the ability to freely reorder changes in the plan. Including the SHA1 of the preceding change would make that trickier. But it also means that, when you deploy to a production database, you lose that extra layer of security that ensures that, yes, the next change <em>really should be deployed</em>. That is, it would be much harder to deploy with changes missing or changed from what was previously expected. And I think that’s only sane for a production environment.</p>

<p>Given that, I’ve started to rethink my decision to omit the previous change SHA1 from the identifier of a change. Yes, it could be a bit more of hassle for a developer, but not, I think, <em>that</em> much of a hassle. The main thing would be to allow <code>revert</code>s to look up their scripts just by change name or even file name, rather than ID. We <em>want</em> deploys to always be correct, but I’m thinking that reverts should always just try very hard to remove changes. Even in production.</p>

<p>I am further thinking that the ID should even include the list of prerequisite changes for even stronger identification. After all, one might change just the dependencies and nothing else, but it would <em>still</em> be a different change. And maybe it should include the note, too? The end result would be a hash of something like this:</p>

<pre><code>project flipr
change add_users_table
parent 7cd96745746cd6baa5da352de782354b21838b25
requires [schemas roles common:utils]
planner Marge N. O’Vera &lt;marge@example.com&gt;
date 2012-11-14T01:10:13Z

Adds the users table to the database.
</code></pre>

<p>This will break existing installations, so I’d need to add a way to update them, but otherwise, I think it might be a win overall. Thoughts?</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/changing-sqitch_ids.html">old layout</a>.</small></p>


