--- 
date: 2013-04-10T00:27:57Z
slug: sqitch-sqlite
title: "Sqitch: Now with SQLite Support"
aliases: [/computers/databases/sqitch-sqlite.html]
tags: [Sqitch, Git, SQLite, database]
type: post
---

<p>This week I released <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.961/">Sqitch v0.961</a>. There are a number of great new features v0.95x, including the beginning of two features I’ve had in mind since the beginning: VCS integration and support for multiple databases.</p>

<p>First the VCS integration. This comes in the form of the new <a href="https://metacpan.org/module/sqitch-checkout"><code>checkout</code> command</a>, which automatically makes database changes for you when you change VCS branches. Say you have two branches, “widgets” and “big-fix”, and that their Sqitch plans diverge. If you’re in the “widgets” branch and want to switch to “big-fix”, just run</p>

<pre><code>sqitch checkout big-fix
</code></pre>

<p>Sqitch will look at the “big-fix” plan, figure out the last change in common with “widgets”, and revert to it. Then it checks out “big-fix” and deploys. That’s it. Yes, you could do this yourself, but do you really remember the last common change between the two branches? Do you want to take the time to look for it, then revert, check out the new branch, and deploy? This is exactly the sort of common developer task that Sqitch aims to take the pain out of, and I’m thrilled to provide it.</p>

<p>You know what’s awesome, though? <em>This feature never occurred to me.</em> I didn’t come up with it, and didn’t implement it. No, it was dreamt up and submitted in a pull request by <a href="https://github.com/rdunklau/">Ronan Dunklau</a>. I have wanted VCS integration since the beginning, but had yet to get &lsquo;round to it. Now Ronan has jumpstarted it. A million thanks!</p>

<p>One downside: it’s currently Git-only. I plan to add infrastructure for <a href="https://github.com/theory/sqitch/issues/25">supporting multiple VCSes</a>, probably with Git and Subversion support to begin with. Watch for that in v0.970 in the next couple months.</p>

<p>The other big change is the addition of <a href="http://sqlite.org/">SQLite</a> support alongside the existing <a href="http://postgresql.org/">PostgreSQL</a> support. Fortunately, I was able to re-use nearly all the code, so the SQLite adapter is just <a href="https://github.com/theory/sqitch/blob/master/lib/App/Sqitch/Engine/sqlite.pm">a couple hundred lines long</a>. For the most part, Sqitch on SQLite works just like on PostgreSQL. The main difference is that Sqitch stores its metadata in a separate SQLite database file. This allows one to use a single metadata file to maintain multiple databases, which can be important if you use multiple databases as schemas pulled into a single connection via <a href="http://www.sqlite.org/lang_attach.html"><code>ATTACH DATABASE</code></a>.</p>

<p>Curious to try it out? Install Sqitch <a href="https://metacpan.org/release/App-Sqitch">from CPAN</a> or <a href="https://github.com/theory/homebrew-sqitch">via the Homebrew Tap</a> and then follow the new <a href="https://metacpan.org/module/sqitchtutorial-sqlite">Sqitch SQLite tutorial</a>.</p>

<p>Of the multitude of other <a href="https://metacpan.org/source/DWHEELER/App-Sqitch-0.961/Changes">Changes</a>, one other bears mentioning: the new <a href="https://metacpan.org/module/sqitch-plan"><code>plan</code> command</a>. This command is just like <a href="https://metacpan.org/module/sqitch-log"><code>log</code></a>, except that it shows what is in the plan file, rather than what changes have been made to the database. This can be useful for quickly listing what’s in a plan, for example when you need to remember the names of changes required by a change you’re about to <a href="https://metacpan.org/module/sqitch-add"><code>add</code></a>. The <code>--oneline</code> option is especially useful for this functionality. An example from <a href="https://metacpan.org/module/sqitchtutorial">the tutorial</a>’s plan:</p>

<pre><code>&gt; sqitch plan --oneline
In sqitch.plan
6238d8 deploy change_pass
d82139 deploy insert_user
7e6e8b deploy pgcrypto
87952d deploy delete_flip @v1.0.0-dev2
b0a951 deploy insert_flip
834e6a deploy flips
d0acfa deploy delete_list
77fd99 deploy insert_list
1a4b9a deploy lists
0acf77 deploy change_pass @v1.0.0-dev1
ec2dca deploy insert_user
bbb98e deploy users
ae1263 deploy appschema
</code></pre>

<p>I personally will be using this a lot, Yep, scratching my own itch here. What itch do you have to scratch with Sqitch?</p>

<p>In related news, I’ll be giving a tutorial at <a href="http://pgcon.org/2013/">PGCon</a> next month, entitled “<a href="https://www.pgcon.org/2013/schedule/events/615.en.html">Agile Database Development</a>”. We’ll be developing a database for a web application using <a href="http://git-scm.com/">Git</a> for source code management, <a href="http://sqitch.org/">Sqitch</a> for database change management, and <a href="http://pgtap.org/">pgTAP</a> for unit testing. This is the stuff I do all day long at work, so you can also think of it as “Theory’s Pragmatic approach to Database Development.” See you there?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-sqlite.html">old layout</a>.</small></p>


