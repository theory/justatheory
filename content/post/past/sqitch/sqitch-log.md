--- 
date: 2012-07-12T17:33:12Z
slug: sqitch-log
title: Sqitch’s Log
aliases: [/computers/databases/sqitch-log.html]
tags: [Sqitch, SQL, database, change management]
type: post
---

<p>Just uploaded Sqitch <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.70-TRIAL">v0.70</a> and <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.71-TRIAL">v0.71</a>. The big change is the introduction of the <code>log</code> command, which allows one to view the deployment history in a database. All events are logged and searchable, including deploys, failed deploys, and reverts. Unlike most other database migration systems, Sqitch has the whole history, so even if you revert back to the very beginning, there is still a record of everything that happened.</p>

<p>I stole most of the interface for <a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-log.pod">the <code>log</code> command</a> from <a href="http://git-scm.com/docs/git-log"><code>git-log</code></a>, including:</p>

<ul>
<li>Colorized output</li>
<li>Searching against change and committer names via regular expressions</li>
<li>A variety of formatting options (“full”, “long”, “medium”, “oneline”, etc.)</li>
<li>Extensible formatting with <a href="https://github.com/theory/sqitch/blob/master/lib/sqitch-log.pod#formats"><code>printf</code>-style codes</a></li>
</ul>


<p>Here are a couple of examples searching <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a>’s test database:</p>

<pre style="background:black;color:white"><code>&gt; sqitch -d flipr_test log -n 3
On database flipr_test
<span style="color:yellow">Deploy 18d7aab59bd0c914a561dc324b1da5549605c376</span>
Name:   change_pass
Date:   2012-07-07 13:26:30 +0200

<span style="color:yellow">Deploy 87b4e131897ec370d78be177a3f91fdc877a2515</span>
Name:   insert_user
Date:   2012-07-07 13:26:30 +0200

<span style="color:yellow">Deploy 20d9af30b97a3071dce12d91665dcd6237265d60</span>
Name:   pgcrypto
Date:   2012-07-07 13:26:30 +0200
</code></pre>

<pre style="background:black;color:white"><code>&gt; sqitch -d flipr_test log -n 6 --format oneline --abbrev 7
On database flipr_test
18d7aab deploy change_pass
87b4e13 deploy insert_user
20d9af3 deploy pgcrypto
540359a deploy delete_flip
d4dce7d deploy insert_flip
b715d73 deploy flips
</code></pre>

<pre style="background:black;color:white"><code>&gt; sqitch -d flipr_test log -n 4 --event revert --event fail --format \
'format:%a %eed %{blue}C%{6}h%{reset}C - %c%non %{cldr:YYYY-MM-dd}d at %{cldr:h:mm a}d%n' 
On database flipr_test
theory reverted <span style="color:blue">9df095</span> - appuser
on 2012-07-07 at 1:26 PM

theory reverted <span style="color:blue">9df095</span>9d078b</span> - users
on 2012-07-07 at 1:26 PM

theory reverted <span style="color:blue">9df095</span>131e25</span> - insert_user
on 2012-07-07 at 1:26 PM

theory reverted <span style="color:blue">9df095</span>02c559</span> - change_pass
on 2012-07-07 at 1:26 PM
</code></pre>

<p>I’m pretty happy with this. Not sure how much it will be used, but it works great!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-log.html">old layout</a>.</small></p>


