--- 
date: 2013-07-04T13:12:34Z
slug: upcoming-sqitch-improvements
title: Notes on Upcoming Sqitch Improvements
aliases: [/computers/databases/upcoming-sqitch-improvements.html]
tags: [Sqitch, database, change management, MySQL, Cubrid, SQLite]
type: post
---

<p>I was traveling last week, and knowing I would be offline a fair bit, not to mention seriously jet-lagged, I put my hacking efforts into getting MySQL support into <a href="http://sqitch.org/">Sqitch</a>. I merged it in yesterday; check out <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial-mysql.pod">the tutorial</a> if you’re interested in it. I expect to release v0.980 with the MySQL support in a couple of weeks; testing and feedback would most appreciated.</p>

<p>There is a caveat, though: it requires MySQL v5.6.4. So if you’re stuck with an older MySQL, it won’t work. There are two reasons to require v5.6.4:</p>

<ul>
<li>The microsecond precision support in <code>DATETIME</code> values, added in v5.6.4. This makes it much easier to keep things in the proper order (deployments usually take less than a second).</li>
<li>The <code>SIGNAL</code> functionality, introduced in v5.5. This allows the schema to <a href="https://github.com/theory/sqitch/blob/master/lib/App/Sqitch/Engine/mysql.sql#L132">mock a check constraint</a> in the Sqitch database, as well as make it much easier to write verify tests (as described in the tutorial and figured out <a href="http://stackoverflow.com/q/17406675/79202">on StackOverflow</a>).</li>
</ul>


<p>But if you can afford to take advantage of a relatively modern MySQL, give it a shot!</p>

<p>The next release also makes a backwards-incompatible change to the SQLite engine: the default Sqitch database is no longer <code>$db_dir/$db_name-sqitch.$suffix</code>, but <code>$db_dir/sqitch.$suffix</code>. In other words, if you were deploying to a db named <code>/var/db/myapp.db</code>, Sqitch previously kept its metadata in <code>/var/db/myapp-sqitch.db</code>, but now will keep it in <code>/var/db/sqitch.db</code>. This is to make it more like the other engines (MySQL defaults to a database named “sqitch”, and Postgres and Oracle default to a schema named “sqitch”).</p>

<p>It’s also useful if you use the SQLite <a href="http://www.sqlite.org/lang_attach.html"><code>ATTACHDATABASE</code></a> command to manage multiple database files in a single project. In that case, you will want to use the same metadata file for all the databases. Keep them all in the same directory with the same suffix and you get just that with the default sqitch database.</p>

<p>If you’d like it to have a different name, use <code>sqitch config core.sqlite.sqitch_db $name</code> to configure it. This will be useful if you don’t want to use the same Sqitch database to manage multiple databases, or if you do, but they live in different directories.</p>

<p>I haven’t released this change yet, and I am not a big-time SQLite user. So if this makes no sense, please <a href="https://github.com/theory/sqitch/issues/98">comment on this issue</a>. It’ll be a couple of weeks before I release v0.980, so there is time to reverse if if there’s consensus that it’s a bad idea.</p>

<p>But given another idea I’ve had, I suspect it will be okay. The idea is to expand on the concept of a Sqitch “target” by giving it <a href="https://github.com/theory/sqitch/issues/100">its own command</a> and configuration settings. Basically, it would be sort of like Git remotes: use URIs to specify database connection and parameter info (such as the sqitch database name for SQLite). These can be passed to database-touching commands, such as <code>deploy</code>, <code>revert</code>, <code>log</code>, and the like. They can also be given names and stored in the configuration file. The upshot is that it would enable invocations such as</p>

<pre><code>sqitch deploy production
sqitch log qa
sqitch status pg://localhost/flipr?sqitch_schema=meta
</code></pre>

<p>See <a href="https://github.com/theory/sqitch/issues/100">the GitHub issue</a> for a fuller description of this feature. I’m certain that this would be useful <a href="http://iovation.com/">at work</a>, as we have a limited number of databases that we deploy each Sqitch project to, and it’s more of a PITA for my co-workers to remember to use different values for the <code>--db-host</code>, <code>--db-user</code>, <code>--db-name</code> and friends options. The project itself would just store the named list of relevant deployment targets.</p>

<p>And it alleviates the issue of specifying a different Sqitch database on SQLite or MySQL, as one can just create a named target that specifies it in the URI.</p>

<p>Not sure when I will get to this feature, though. I think it would be great to have, and maybe iovation would want me to spend some time on it in the next couple of months. But it might also be a great place for someone else to get started adding functionality to Sqitch.</p>

<p>Oh, and before I forget: it looks like Sqitch might soon get <a href="https://github.com/theory/sqitch/issues/93">CUBRID support</a>, too, thanks to <a href="https://github.com/stefansbv">Ștefan Suciu</a>. Stay tuned!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/upcoming-sqitch-improvements.html">old layout</a>.</small></p>


