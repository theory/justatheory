--- 
date: 2012-09-25T22:59:59Z
slug: sqitch-symbolism
title: Sqitch Symbolism
aliases: [/computers/databases/sqitch-symbolism.html]
tags: [Sqitch, SQL, change management, localization, internationalization]
type: post
---

<p>It has been a while since I <a href="/computers/databases/sqitch-depend-on-it.html">last blogged about Sqitch</a>. The silence is in part due to the fact that I’ve moved from full-time Sqitch development to actually putting it to use building databases at work. This is exciting, because it needs the real-world experience to grow up.</p>

<p>That’s not to say that nothing has happened with Sqitch. I’ve just released <a href="https://metacpan.org/release/DWHEELER/App-Sqitch-0.931/">v0.931</a> which includes a bunch of improvement since I wrote about v0.90. First a couple of the minor things:</p>

<ul>
<li>Sqitch now checks dependencies before reverting, and dies if they would be broken by the revert. This change, introduced in v0.91, required that the dependencies be moved to their own table, so if you’ve been messing with an earlier version of Sqitch, you’ll have to rebuild the database. Sorry about that.</li>
<li>I fixed a bunch of Windows-related issues, including finding the current user’s full name, correctly setting the locale for displaying dates and times, executing shell commands, and passing tests. The awesome <a href="http://code.activestate.com/ppm/App-Sqitch/">ActiveState PPM Index</a> has been invaluable in tracking these issues down.</li>
<li>Added the <a href="https://metacpan.org/module/sqitch-bundle"><code>bundle</code> command</a>. All it does is copy your project configuration file, plan, and deploy, revert, and test scripts to a directory you identify. The purpose is to be able to export the project into a directory structure suitable for distribution in a tarball, RPM, or whatever. That my not sound incredibly useful, since copying files is no big deal. However, the long-term plan is to add VCS support to Sqitch, which would entail fetching scripts from various places in VCS history. At that point, it will be essential to use <code>bundle</code> to do the export, so that scripts are properly exported from the VCS history. That said, I’m actually using it already to build RPMs. Useful already!</li>
</ul>


<h3>Symbolic References</h3>

<p>And now the more immediately useful changes. First, I added new symbolic tags,  <code>@FIRST</code> and <code>@LAST</code>. These represent the first and last changes currently deployed to a database, respectively. These complement the existing <code>@ROOT</code> and <code>@HEAD</code> symbolic tags, which represent the first and last changes listed in the <em>plan.</em> The distinction is important: The change plan vs actual deployments to a database.</p>

<p>The addition of <code>@FIRST</code> and <code>@LAST</code> may not sounds like much, but there’s more.</p>

<p>I also added forward and reverse change reference modifiers <code>^</code> and <code>~</code>. The basic idea was stolen from <a href="http://git-scm.com/docs/gitrevisions">Git Revisions</a>, though the semantics vary. For <a href="https://metacpan.org/module/sqitchchanges">Sqitch changes</a>, <code>^</code> appended to a name or tag means “the change before this change,” while <code>~</code> means “the change after this change”. I find <code>^</code> most useful when doing development, where I’m constantly deploying and reverting a change as I work. Here’s how I do that revert:</p>

<pre><code>sqitch revert --to @LAST^
</code></pre>

<p>That means “revert to the change before the last change”, or simply “revert the last change”. If I want to revert two changes, I use two <code>^</code>s:</p>

<pre><code>sqitch revert --to @LAST^^
</code></pre>

<p>To go back any further, I need to use an integer with the <code>^</code>. Here’s how to revert the last four changes deployed to the database:</p>

<pre><code>sqitch revert --to @LAST^4
</code></pre>

<p>The cool thing about this is that I don’t have to remember the name of the change to revert, as was previously required. And of course, if I just wanted to deploy two changes since the last deployment, I would use <code>~~</code>:</p>

<pre><code>sqitch deploy --to @LAST~~
</code></pre>

<p>Nice, right? One thing to bear in mind, as I was reminded while giving a <a href="https://www.slideshare.net/justatheory/sane-sql-change-management-with-sqitch">Sqitch presentation</a> to <a href="http://pdxpug.wordpress.com/2012/09/07/pdxpug-september-meeting-coming-up/">PDXPUG</a>: Changes are deployed in a sequence. You can think of them as a linked list. So this command:</p>

<pre><code>sqitch revert @LAST^^
</code></pre>

<p>Does <em>not</em> mean to revert the second-to-last change, leaving the two after it. It will revert the last change <em>and</em> the penultimate change. This is why I actually encourage the use of the <code>--to</code> option, to emphasize that you’re deploying or reverting all changes <em>to</em> the named point, rather than deploying or reverting the named point in isolation. Sqitch simply doesn’t do that.</p>

<h3>Internationalize Me</h3>

<p>One more change. With today’s release of v0.931, there is now proper internationalization support in Sqitch. The code has been localized for a long time, but there was no infrastructure for internationalizing. Now there is, and I’ve stubbed out files for translating Sqitch messages into <a href="https://github.com/theory/sqitch/blob/master/po/fr.po">French</a> and <a href="https://github.com/theory/sqitch/blob/master/po/de.po">German</a>. Adding others is easy.</p>

<p>If you’re interested in translating Sqitch’s messages (only 163 of them, should be quick!), just <a href="https://github.com/theory/sqitch/">fork Sqitch</a>, juice up your favorite <a href="http://www.google.com/search?q=gettext+editor">gettext editor</a>, and start editing. Let me know if you need a language file generated; I’ve built the tools to do it easily with <a href="http://dzil.org/">dzil</a>, but haven’t released them yet. Look for a post about that later in the week.</p>

<h3>Presentation</h3>

<p>Oh, and that <a href="http://pdxpug.wordpress.com/2012/09/07/pdxpug-september-meeting-coming-up/">PDXPUG presentation</a>? Here are the slides. Enjoy!</p>

<iframe src="https://www.slideshare.net/slideshow/embed_code/14459486" width="597" height="486" frameborder="0" marginwidth="0" marginheight="0" scrolling="no" style="border:1px solid #CCC;border-width:1px 1px 0;margin-bottom:5px" allowfullscreen> </iframe>


<p> <div style="margin-bottom:5px"> <strong> <a href="https://www.slideshare.net/justatheory/sane-sql-change-management-with-sqitch" title="Sane SQL Change Management with Sqitch" target="_blank">Sane SQL Change Management with Sqitch</a> </strong> from <strong><a href="https://www.slideshare.net/justatheory" target="_blank">David E. Wheeler</a></strong> </div></p>
