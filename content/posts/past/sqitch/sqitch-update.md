--- 
date: 2012-04-28T04:32:52Z
slug: sqitch-update
title: Sqitch Update
aliases: [/computers/databases/sqitch-update.html]
tags: [Sqitch, SQL, change management]
---

<p>A quick update on <a href="https://github.com/theory/sqitch/">Sqitch</a>. I started implementation about a couple of weeks ago. It’s coming a long a bit more slowly than I'd like, given that I need to give <a href="https://www.pgcon.org/2012/schedule/events/479.en.html">a presentation</a> on it soon. But I did things a little differently than I usually do with project like this: I wrote documentation first. In addition to the basic docs I <a href="/computers/databases/sqitch-draft.html">posted</a> a couple weeks back, I’ve written <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">a tutorial</a>. I put quite a lot of time into it, studying the <a href="http://git-scm.com/">Git</a> interface as I did so, to try to develop useful workflows. The nice thing about this it that it will not only serve as the foundation for my presentation (<em>PHEW!</em> Half the work done already!), but it also serves as a design specification.</p>

<p>So I've been diligently plugging away on it, and have uploaded a couple of trial releases <a href="http://search.cpan.org/dist/App-Sqitch/">to CPAN</a>. So far, we have decent support for:</p>

<ul>
<li><code>sqitch help</code> and <code>sqitch help command</code>. The latter only works for the implemented commands, of course.</li>
<li><code>sqitch config</code>, which is a near perfect duplication of <a href="http://www.gitmanual.org/git-config.html"><code>git-config</code></a>, thanks to the very useful <a href="https://metacpan.org/module/Config::GitLike/">Config::GitLike</a>. It supports a local, project-specific config file, a user config file, and a system config file.</li>
<li><code>sqitch init</code>, which creates a new project by creating directories for the deploy, revert, and test scripts, and writes a  project-specific config file. This file has options you specify in the call to <code>sqitch</code> (such as the database engine you plan to use), and all unmodified settings or settings set in user or system configuration are written out as comments.</li>
</ul>

<p>So yeah, not a ton so far, but the foundations for how it all goes together are there, so it should take less time to develop other commands, all things being equal.</p>

<p>Next up:</p>

<ul>
<li><code>sqitch add-step</code>, which will create deploy and revert scripts for a new step, based on simple templates.</li>
<li><code>sqitch deploy</code>, which is the big one. Initial support will be there for PostgreSQL and SQLite (and perhaps MySQL).</li>
</ul>

<p>Interested in helping out?</p>

<ul>
<li><p>I'm going to need a parser for <a href="https://github.com/theory/sqitch/blob/master/lib/sqitch.pod#plan-file">the plan file</a> pretty soon. The interface will need an iterator to move back and forth in the file, as well as a way to write to the file, add steps to it, etc. The <a href="https://github.com/theory/sqitch/blob/master/lib/sqitch.pod#grammar">grammar</a> is pretty simple, so anyone familiar with parsers and iterators could probably knock something out pretty quickly.</p></li>
<li><p>The interface for testing needs some thinking through. I had been thinking that it could be something as simple as just diffing the output of a script file against an expected output file, at least to start. One could even use <a href="http://pgtap.org/">pgTAP</a> or <a href="http://theory.github.com/mytap/">MyTAP</a> in such scripts, although it might be a pain to get the output exactly right for varying environments. But maybe that doesn't matter for deployment, so much? Because it tends to be to a more controlled environment than your typical open-source library test suite, I mean.</p></li>
</ul>

<p>Got something to add? <a href="https://github.com/theory/sqitch">Fork it!</a></p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/databases/sqitch-update.html">old layout</a>.</small></p>


