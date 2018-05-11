--- 
date: 2013-02-22T07:09:46Z
slug: sqitch-homebrew-tap
title: Sqitch Homebrew Tap
aliases: [/computers/databases/sqitch-homebrew-tap.html]
tags: [Sqitch, SQL, change management, development, Homebrew, Test Anything Protocol, macOS]
---

<p>If <a href="http://sqitch.org/" title="Sqitch: Sane database schema change management">Sqitch</a> is to succeed, it needs to get into the hands of as many people as possible. That means making it easy to install for people who are not Perl hackers and don’t want to deal with CPAN. The <a href="https://github.com/theory/homebrew-sqitch">Sqitch Homebrew Tap</a> is my first public stab at that. It provides a series of “Formulas” for <a href="http://mxcl.github.com/homebrew/">Homebrew</a> users to easily download, build, and install Sqitch and all of its dependencies.</p>

<p>If you are one of these lucky people, here’s how to configure the Sqitch tap:</p>

<pre><code>brew tap theory/sqitch
</code></pre>

<p>Now you can install the core Sqitch application:</p>

<pre><code>brew install sqitch
</code></pre>

<p>That’s it. Make sure it works:</p>

<pre><code>&gt; sqitch --version
sqitch (App::Sqitch) 0.953
</code></pre>

<p>It won’t do you much good without support for your database, though.
Currently, there is a build for PostgreSQL. Note that this requires the
Homebrew core PostgreSQL server:</p>

<pre><code>brew install sqitch_pg
</code></pre>

<p>Sqitch hasn’t been ported to other database engines yet, but once it is, expect other formulas to follow. But if you use PostgreSQL (or just want to experiment with it), you’re ready to rock! I suggest following along <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a> or taking in <a href="https://speakerdeck.com/theory/sane-database-change-management-with-sqitch">the latest iteration of the introductory presentation</a> (video of an older version <a href="https://vimeo.com/50104469">here</a>).</p>

<p>My thanks to IRC user “mistym” for the help and suggestions in getting this going. My Ruby is pretty much rusted through, soI could not have done it without the incredibly responsive help!</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-homebrew-tap.html">old layout</a>.</small></p>


