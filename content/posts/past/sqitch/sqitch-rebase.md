--- 
date: 2012-12-04T07:27:27Z
slug: sqitch-rebase
title: "Sqitch Update: All Your Rebase Are…Never Mind"
aliases: [/computers/databases/sqitch-rebase.html]
tags: [Sqitch, SQL, change management, database]
---

<p>I’m pleased to announce the release of <a href="https://metacpan.org/release/App-Sqitch/">Sqitch v0.940</a>. The focus of this release? <em>Sanity</em>.</p>

<p>I’ve been doing a lot of Sqitch-based database development at <a href="http://iovation.com/">work</a>. Overall it has worked quite well. Except for one thing: often the order in which changes would be arranged would change from one run to the next. Oy.</p>

<h3>Out of Order</h3>

<p>The reason? The plan parser would perform a <a href="https://en.wikipedia.org/wiki/Topological_sorting" title="Wikipedia: âTopological sortingâ">topological sort</a> of all the changes between tags based on their dependencies. I’ve been careful, for the most part, to keep my changes in the proper order in our plan files, but the topological sort would often pick a different order. Still valid in terms of dependency ordering, but different from the plan file.</p>

<p>Given the same inputs, the sort always produced the same order. However, whenever I added a new changes (and I do that all the time while developing), there would then be a new input, which could result in a completely different order. The downside is that I would add a change, run <code>sqitch deploy</code>, and it would die because it thought something needed to be deployed that had already been deployed, simply because it sorted it to come after an undeployed change. <em>So annoying.</em>. It also caused problems in for production deployments, because different machines with different Perls would sort the plans in different ways.</p>

<p>So I re-wrote the sorting part of the the plan parser so that it no longer sorts. The list of changes is now always identical to the order in the plan file. It still checks dependencies, of course, only now it throws an exception if it finds an ordering problem, rather than re-ordering for you. I’ve made an effort to tell the user how to move things around in the plan file to fix ordering issues, so hopefully everything will be less mysterious.</p>

<p>Of course, many will never use dependencies, in which case this change has effect. But it was important to me, as I like to specify dependencies as much as I can, for my own sanity.</p>

<p>See? There’s that theme!</p>

<h3>Everyone has a Mom</h3>

<p>Speaking of ordering, as we have been starting to do production deployments, I realized that my previous notion to allow developers to reorder changes in the plan file without rebuilding databases was a mistake. It was too easy for someone to deploy to an existing database and miss changes because there was nothing to notice that changes had not been deployed. This was especially a problem before I addressed the ordering issue.</p>

<p>Even with ordering fixed, I thought about how <code>git push</code> works, and <a href="/computers/databases/changing-sqitch_ids.html">realized</a> that it was much more important to make sure things really were consistent than it was to make things slightly more convenient for developers.</p>

<p>So I changed the way change IDs are generated. The text hashed for IDs now includes the ID of the parent change (if there is one), the change dependencies, and the change note. If any of these things change, the ID of the change will change. So they might change a lot during development, while one moves things around, changes dependencies, and tweaks the description. But the advantage is for production, where things have to be deployed exactly right, with no modifications, or else the deploy will fail. This is sort of like requiring all Git merges to be fast-forwarded, and philosophically in line with the Git practice of never changing commits after they’re pushed to a remote repository accessible to others.</p>

<p>Curious what text is hashed for the IDs? Check out the new <a href="(https://metacpan.org/module/sqitch-show"><code>show</code> command</a>!</p>

<h3>Rebase</h3>

<p>As a database hacker, I still need things to be relatively convenient for iterative development. So I’ve also added the <a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-rebase.pod"><code>rebase</code> command</a>. It’s simple, really: It just does a <code>revert</code> and a <code>deploy</code> a single command. I’m doing this all day long, so I’m happy to save myself a few steps. It’s also nice that I can do <code>sqitch rebase @HEAD^</code> to revert and re-apply the latest change over and over again without fear that it will fail because of an ordering problem. But I already mentioned that, didn’t I?</p>

<h3>Order Up</h3>

<p>Well, mostly. Another ordering issue I addressed was for the <code>revert --to</code> option. It used to be that it would find the change to revert to in the <em>plan</em>, and revert based on the plan order. (And did I mention that said order might have <em>changed since the last deploy?</em>) v0.940 now searches the <em>database</em> for the revert target. Not only that, the full list of changes to deploy to revert to the target is <em>also</em> returned from the database. In fact, the <code>revert</code> no longer consults the plan file at all. This is great if you’ve re-ordered things, because the revert will <em>always</em> be the reverse order of
the <em>previous</em> deploy. Even if IDs have changed, <code>revert</code> will find the changes to revert by name. It will only fail if you’ve removed the revert script for a change.</p>

<p>So simple, conceptually: <code>revert</code> reverts in the proper order based on what was deployed before. <code>deploy</code> deploys based on the order in the plan.</p>

<h3>Not <code>@FIRST</code>, Not <code>@LAST</code></h3>

<p>As a result of the improved intelligence of <code>revert</code>, I have also deprecated the <code>@FIRST</code> and <code>@LAST</code> symbolic tags. These tags forced a search of the database, but were mainly used for <code>revert</code>. Now that <code>revert</code> always searches the database, there’s nothing to force. They’re still around for backward compatibility, but no longer documented. Use <code>@ROOT</code> and <code>@HEAD</code>, instead.</p>

<h3>Not Over</h3>

<p>So lots of big changes, including some compatibility changes. But I’ve tried hard to make them as transparent as possible (old IDs will automatically be updated by <code>deploy</code>). So take it for a spin!</p>

<p>Meanwhile, I still have quite a few other improvements I need to make. On my short list are:</p>

<ul>
<li><a href="https://github.com/theory/sqitch/issues/39">Checking all dependencies</a>  before deploying or reverting <em>any</em> changes.</li>
<li><a href="https://github.com/theory/sqitch/issues/15">Adding the <code>verify</code> command</a>  to run acceptance tests.</li>
<li><a href="https://github.com/theory/sqitch/issues/54">Adding a <code>--no-run</code> option to <code>deploy</code></a> so that existing databases can be upgraded to Sqitch.</li>
<li><a href="https://github.com/theory/sqitch/issues/13">Adding a <code>check</code> command</a> to sanity-check a plan, scripts, and a database.</li>
</ul>


<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-rebase.html">old layout</a>.</small></p>


