--- 
date: 2004-06-18T05:29:11Z
slug: is-ntpd-working
title: How Do I Know Whether NTPD is Working?
aliases: [/computers/os/freebsd/is_ntpd_working.html]
tags: [FreeBSD, NTP, Red Hat, Linux]
type: post
---

<p>Well, after figuring out <a href="http://www.justatheory.com/computers/os/freebsd/ntpd_configuration.html" title="NTPD Configuration on FreeBSD and Red Hat Linux">how to configure NTPD</a>, it appears to be working well: there are two processes running, and there's a drift file. However, the drift file just has <q>0.000</q> in it, and <code>ntpq</code> doesn't seem to know much:</p>

<pre>% ntpq -p
127.0.0.1: timed out, nothing received
***Request timed out</pre>

<p>So, how do I know if it's working? Is it working? Shouldn't <code>ntpq
-p</code> be more informative?</p>

<p class="past"><small>Looking for the comments? Try the <a rel="nofollow" href="//past.justatheory.com/computers/os/freebsd/is_ntpd_working.html">old layout</a>.</small></p>


