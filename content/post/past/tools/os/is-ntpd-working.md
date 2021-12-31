--- 
date: 2004-06-18T05:29:11Z
slug: is-ntpd-working
title: How Do I Know Whether NTPD is Working?
aliases: [/computers/os/freebsd/is_ntpd_working.html]
tags: [FreeBSD, NTP, Red Hat, Linux]
type: post
---

Well, after figuring out [how to configure NTPD], it appears to be working well:
there are two processes running, and there's a drift file. However, the drift
file just has “0.000” in it, and `ntpq` doesn't seem to know much:

    % ntpq -p
    127.0.0.1: timed out, nothing received
    ***Request timed out

So, how do I know if it's working? Is it working? Shouldn't `ntpq -p` be more
informative?

  [how to configure NTPD]: {{% ref "/post/past/tools/os/ntpd-configuration" %}}
    "NTPD Configuration on FreeBSD and Red Hat Linux"
