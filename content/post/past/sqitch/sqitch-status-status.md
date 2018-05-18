--- 
date: 2012-07-07T12:49:37Z
slug: sqitch-status-status
title: "Sqitch Status: Now With Status"
aliases: [/computers/databases/sqitch-status-status.html]
tags: [Sqitch, SQL, database, change management]
type: post
---

<p>I’ve just released <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.60-TRIAL">Sqitch v0.60</a>. The main change is the implementation of the <code>status</code> command, which allows one to see the current deployment status of a database. An example from the <a href="https://metacpan.org/module/DWHEELER/App-Sqitch-0.60-TRIAL/lib/sqitchtutorial.pod">updated tutorial</a>:</p>

<pre><code>&gt; sqitch status
# On database flipr_test
# Change:   18d7aab59bd0c914a561dc324b1da5549605c376
# Name:     change_pass
# Deployed: 2012-07-07 13:23:42 +0200
# By:       theory
# 
Nothing to deploy (up-to-date)
</code></pre>

<p>If there are changes in the plan after the most recently deployed change, they would be listed like so:</p>

<pre><code>&gt; sqitch status
# On database flipr_test
# Change:   540359a3892d1476f9ca6ccf7d3f9993ac383b68
# Name:     delete_flip
# Tag:      @v1.0.0-dev2
# Deployed: 2012-07-06 19:31:14 +0200
# By:       theory
# 
Undeployed changes:
  * pgcrypto
  * insert_user
  * change_pass
</code></pre>

<p>You can also ask it to show the list of deployed changes and applied tags:</p>

<pre><code>&gt; sqitch status --show-tags --show-changes
# On database flipr_test
# Change:   18d7aab59bd0c914a561dc324b1da5549605c376
# Name:     change_pass
# Deployed: 2012-07-07 13:26:30 +0200
# By:       theory
# 
# Changes:
#   change_pass - 2012-07-07 13:26:30 +0200 - theory
#   insert_user - 2012-07-07 13:26:30 +0200 - theory
#   pgcrypto    - 2012-07-07 13:26:30 +0200 - theory
#   delete_flip - 2012-07-07 13:26:30 +0200 - theory
#   insert_flip - 2012-07-07 13:26:30 +0200 - theory
#   flips       - 2012-07-07 13:26:30 +0200 - theory
#   delete_list - 2012-07-07 13:26:30 +0200 - theory
#   insert_list - 2012-07-07 13:26:30 +0200 - theory
#   lists       - 2012-07-07 13:26:30 +0200 - theory
#   change_pass - 2012-07-07 13:26:30 +0200 - theory
#   insert_user - 2012-07-07 13:26:30 +0200 - theory
#   users       - 2012-07-07 13:26:30 +0200 - theory
#   appuser     - 2012-07-07 13:26:30 +0200 - theory
# 
# Tags:
#   @v1.0.0-dev2 - 2012-07-07 13:26:30 +0200 - theory
#   @v1.0.0-dev1 - 2012-07-07 13:26:30 +0200 - theory
# 
Nothing to deploy (up-to-date)
</code></pre>

<p>The <a href="https://metacpan.org/module/DWHEELER/App-Sqitch-0.60-TRIAL/lib/sqitch-status.pod#Options"><code>--date-format</code></a> option allows one to display the dates in a variety of formats, inspired by the <code>git log --date</code> option:</p>

<pre><code>&gt; sqitch status --date-format long
# On database flipr_test
# Change:   18d7aab59bd0c914a561dc324b1da5549605c376
# Name:     change_pass
# Deployed: 7 juillet 2012 13:26:30 CEST
# By:       theory
# 
Nothing to deploy (up-to-date)
</code></pre>

<p>Want to give it a try? Install it with <code>cpan D/DW/DWHEELER/App-Sqitch-0.60-TRIAL.tar.gz</code> and follow along <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a>.</p>

<p>Now I’m off to add the <code>log</code> command, which shows a history of all deploys and reverts.</p>
