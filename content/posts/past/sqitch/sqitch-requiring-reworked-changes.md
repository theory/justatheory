--- 
date: 2013-07-17T15:12:20Z
slug: sqitch-requiring-reworked-changes
title: Requiring Reworked Sqitch Changes
aliases: [/computers/databases/sqitch-requiring-reworked-changes.html]
tags: [Sqitch]
---

<p>I recently discovered a mildly annoying <a href="https://github.com/theory/sqitch/issues/103">bug</a> in <a href="http://sqitch.org/">Sqitch</a>, the Git-inspired database schema change management app I’ve been working on for the past year. One of its key features is the ability to “rework” changes. For example, if you have a change that defines a function <code>change_password()</code>, and discover sometime after release that it has a bug (maybe the hashing algorithm is too weak), you can “rework” it – essentially modify it in place – and save some headaches. Check out the “In Place Changes” section of the  (<a href="https://metacpan.org/module/sqitchtutorial#In-Place-Changes">PostgreSQL</a>, <a href="https://metacpan.org/module/sqitchtutorial-sqlite#In-Place-Changes">SQLite</a>, <a href="https://metacpan.org/module/sqitchtutorial-oracle#In-Place-Changes">Oracle</a>, or <a href="https://metacpan.org/module/sqitchtutorial-mysql#In-Place-Changes">MySQL</a> (coming soon) tutorials for detailed examples of how it works.</p>

<p>The bug was about what happens when one adds a new change that depends on a reworked change, but just specifies it by name, such as <code>change_password</code>:</p>

<pre><code>sqitch add meow --requires change_password
</code></pre>

<p>This added the change fine, but at deploy time, Sqitch complained that there were multiple instances of a change in the database. Of course, that’s true, because <code>change_password</code> will have been deployed twice: once for the original version, and the second time for the reworked version. This was inconsistent with how it looked up changes in the plan, where it would just return the first instance of a change in the plan. So I <a href="https://github.com/theory/sqitch/compare/edcd84a...f501e88">changed it</a> so that dependency lookups in the database also return the first instance of the change. I believe this makes sense, because if you require <code>change_password</code>, without specifying which instance you want, you probably want <em>any</em> instance, starting with the earliest.</p>

<p>But what if you actually need to require a specific instance of a reworked change? Let’s say your plan looks like this:</p>

<pre><code>users
widgets
change_pass
sleep
@v1.0

work_stuff
change_pass [change_pass@v1.0]
</code></pre>

<p>The third change is <code>change_pass</code>, and it has been reworked in the sixth change (requiring the previous version, as of the <code>@v1.0</code> tag). If you want to require <em>any</em> instance of <code>change_pass</code>, you specify it as in the previous example. But what if there were changes in the reworked version that you require? You might try to require it as-of the symbolic tag <code>@HEAD</code>:</p>

<pre><code>sqitch add meow --requires change_password@HEAD
</code></pre>

<p>This means, “Require the last instance of <code>change_password</code> in the plan.” And that would workâ¦until you reworked it again, then it would be updated to point at the newer instance. Sqitch will choke on that, because you can’t require changes that appear <em>later</em> in the plan.</p>

<p>So what we have to do instead is add a <em>new</em> tag after the second instance of <code>change_pass</code>:</p>

<pre><code>sqitch tag rehash
</code></pre>

<p>Now the plan will look like this:</p>

<pre><code>users
widgets
change_pass
sleep
@v1.0

work_stuff
change_pass [change_pass@v1.0]
@rehash
</code></pre>

<p>Now we can identify exactly the instance we need by specifying that tag:</p>

<pre><code>sqitch add meow --requires change_password@rehash
</code></pre>

<p>Meaning “The instance of <code>change_password</code> as of <code>@rehash</code>.” If what you really needed was the first version, you can specify the tag that follows it:</p>

<pre><code>sqitch add meow --requires change_password@v1.0
</code></pre>

<p>Which, since it is the first instance is the same as specifying no tag at all. But if there were, say, four instances of <code>change_pass</code>, you can see how it might be important to use tags to specify specific instances for dependencies.</p>

<p>For what it’s worth, this is how to get around the <a href="https://github.com/theory/sqitch/issues/103">original bug</a> referenced above: just specify <em>which</em> instance of the change to require by using a tag that follows that instance, and the error should go away.</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-requiring-reworked-changes.html">old layout</a>.</small></p>


