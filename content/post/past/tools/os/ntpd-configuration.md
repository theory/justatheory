--- 
date: 2004-06-16T01:33:25Z
slug: ntpd-configuration
title: NTPD Configuration on FreeBSD and Red Hat Linux
aliases: [/computers/os/freebsd/ntpd_configuration.html]
tags: [FreeBSD, NTP, Red Hat, Linux]
type: post
---

Well, I got no responses to my [request for assistance] setting up NTPD on
FreeBSD, but today I must've just been Googling better, because I found the
resources I needed.

The most important site I found was the [NTP configuration] page from Computer
Facilities Management at the University of Washington. It was valuable because
it provided some simple *ntpd.conf* file samples that set up `ntpd` to run only
as a client. So no I'm confident that no one will try to connect to my servers
and cause any mischief. The CFM NTP page also helpfully pointed out that I could
easily enable ntpd on my Red Hat box by typing `chkconfig ntpd on`.

Another interesting site I found is [www.pool.ntp.org]. The cool thing about
using `pool.ntp.org` as the time server to synchronize my servers to is that it
distributes the load to lots of time servers. So I set up my *ntpd.conf* files
to point first to `pool.ntp.org`, and then to two geographically close servers.

And finally, [this DynDNS page] gave me the instruction I needed to get `ntpd`
running on FreeBSD. All I had to do was add `xntpd_enable="YES"` to
*/etc/rc.conf*. I restarted my box, and now I'm in business!

  [request for assistance]: {{ ref "/post/past/tools/os/ntptd-help-requested" %}}
    "I ask for help with NTPD"
  [NTP configuration]: http://cfm.gs.washington.edu/network/ntp/ntp/
    "NTP Configuration"
  [www.pool.ntp.org]: http://www.pool.ntp.org/ "pool.ntp.org"
  [this DynDNS page]: http://freeunix.dyndns.org:8088/site2/howto/NTP3.shtml
    "Using NTP"
