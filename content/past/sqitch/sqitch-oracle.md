--- 
date: 2013-05-09T22:11:46Z
slug: sqitch-oracle
title: Sqitch on Oracle
aliases: [/computers/databases/sqitch-oracle.html]
tags: [Sqitch, Oracle, database, SQL, change management]
type: post
---

<p>I found myself with a little unexpected time at <a href="http:/iovation.com/">work</a> recently, and since we use Oracle (for a few more months), I decided to port <a href="http://sqitch.org/">Sqitch</a>. Last night, I released v0.970 with full support for Oracle. I did the development against an <a href="https://www.oracle.com/technetwork/database/enterprise-edition/databaseappdev-vm-161299.html">11.2 VirtualBox VM</a>, though I think it should work on 10g, as well.</p>

<p>Sqitch is available from the usual locations. For Oracle support, you’ll need the <a href="https://www.oracle.com/technetwork/database/features/instant-client/index-097480.html">Instant Client</a>, including SQL*Plus. Make sure you have <a href="https://www.orafaq.com/wiki/ORACLE_HOME"><code>$ORACLE_HOM</code></a> set and you’ll be ready to install. Via CPAN, it’s</p>

<pre><code>cpan install App::Sqitch DBD::Oracle
</code></pre>

<p>Via <a href="https://brew.sh">Homebrew</a>:</p>

<pre><code>brew tap theory/sqitch
brew install sqitch-oracle
</code></pre>

<p>Via ActiveState PPM, install <a href="https://www.activestate.com/activeperl/downloads">ActivePerl</a>, then run:</p>

<pre><code>ppm install App-Sqitch DBD-Oracle
</code></pre>

<a href="https://www.pgcon.org/2013/"><img class="left" src="https://www.pgcon.org/2013/images/pgcon-220x250.png" alt="PGCon 2013" /></a>

<p>There are a few other minor tweaks and fixed in this release; check the <a href="https://metacpan.org/source/DWHEELER/App-Sqitch-0.970/Changes">release notes</a> for details.</p>

<p>Want more? I will be giving a half-day tutorial, entitled “<a href="https://www.pgcon.org/2013/schedule/events/615.en.html">Agile Database Development</a>,” on database development with <a href="https://git-scm.com/">Git</a>, <a href="http://sqitch.org/">Sqitch</a>, and <a href="https://pgtap.org/">pgTAP</a> at on May 22 <a href="https://www.pgcon.org/2013/">PGCon 2013</a> in Ottawa, Ontario. Come on up!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-oracle.html">old layout</a>.</small></p>
