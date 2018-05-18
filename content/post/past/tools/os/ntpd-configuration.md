--- 
date: 2004-06-16T01:33:25Z
slug: ntpd-configuration
title: NTPD Configuration on FreeBSD and Red Hat Linux
aliases: [/computers/os/freebsd/ntpd_configuration.html]
tags: [FreeBSD, NTP, Red Hat, Linux]
type: post
---

<p>Well, I got no responses to my <a href="/computers/os/freebsd/ntptd_help_requested.html" title="I ask for help with NTPD">request for assistance</a> setting up NTPD on FreeBSD, but today I must've just been Googling better, because I found the resources I needed.</p>

<p>The most important site I found was the <a href="http://cfm.gs.washington.edu/network/ntp/ntp/" title="NTP Configuration">NTP configuration</a> page from Computer Facilities Management at the University of Washington. It was valuable because it provided some simple <em>ntpd.conf</em> file samples that set up <code>ntpd</code> to run only as a client. So no I'm confident that no one will try to connect to my servers and cause any mischief. The CFM NTP page also helpfully pointed out that I could easily enable ntpd on my Red Hat box by typing <code>chkconfig ntpd on</code>.</p>

<p>Another interesting site I found is <a href="http://www.pool.ntp.org/" title="pool.ntp.org">www.pool.ntp.org</a>. The cool thing about using <code>pool.ntp.org</code> as the time server to synchronize my servers to is that it distributes the load to lots of time servers. So I set up my <em>ntpd.conf</em> files to point first to <code>pool.ntp.org</code>, and then to two geographically close servers.</p>

<p>And finally, <a href="http://freeunix.dyndns.org:8088/site2/howto/NTP3.shtml" title="Using NTP">this DynDNS page</a> gave me the instruction I needed to get <code>ntpd</code> running on FreeBSD. All I had to do was add <code>xntpd_enable=&quot;YES&quot;</code> to <em>/etc/rc.conf</em>. I restarted my box, and now I'm in business!</p>
