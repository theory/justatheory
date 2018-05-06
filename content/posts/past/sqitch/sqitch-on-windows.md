--- 
date: 2013-02-27T00:35:36Z
slug: sqitch-on-windows
title: Sqitch on Windows (and Linux, Solaris, and OS X)
aliases: [/computers/databases/sqitch-on-windows.html]
tags: [Sqitch, Windows, Perl, ActivePerl, ActiveState]
---

<p>Thanks to the hard-working hamsters at the <a href="http://code.activestate.com/ppm/">ActiveState PPM Index</a>, Sqitch is available for installation on Windows. According to the <a href="http://code.activestate.com/ppm/App-Sqitch/">Sqitch PPM Build Status</a>, the latest version is now available for installation. All you have to do is:</p>

<ol>
<li>Download and install <a href="http://www.activestate.com/activeperl/downloads#">ActivePerl</a></li>
<li>Open the Command Prompt</li>
<li>Type <code>ppm install App-Sqitch</code></li>
</ol>


<p>As of this writing, only PostgreSQL is supported, so you will need to <a href="http://www.postgresql.org/download/windows/">install PostgreSQL</a>.</p>

<p>But otherwise, that’s it. In fact, this incantation works for any OS that ActivePerl supports. Here’s where you can find the <code>sqitch</code> executable on each:</p>

<ul>
<li>Windows: <code>C:\perl\site\bin\sqitch.bat</code></li>
<li>Mac OS X: <code>~/Library/ActivePerl-5.16/site/bin/sqitch</code> (Or <code>/usr/local/ActivePerl-5.16/site/bin</code> if you run <code>sudo ppm</code>)</li>
<li>Linux: <code>/opt/ActivePerl-5.16/site/bin/sqitch</code></li>
<li>Solaris/SPARC (<a href="http://www.activestate.com/compare-editions">Business edition</a>-only): <code>/opt/ActivePerl-5.16/site/bin/sqitch</code></li>
</ul>


<p>This makes it easy to get started with Sqitch on any of those platforms without having to become a Perl expert. So go for it, and then get started with <a href="https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod">the tutorial</a>!</p>

<p class="past"><small>Missing something? Try the <a rel="nofollow" href="http://past.justatheory.com/computers/databases/sqitch-on-windows.html">old layout</a>.</small></p>


