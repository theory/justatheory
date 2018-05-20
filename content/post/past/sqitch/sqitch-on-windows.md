--- 
date: 2013-02-27T00:35:36Z
slug: sqitch-on-windows
title: Sqitch on Windows (and Linux, Solaris, and OS X)
aliases: [/computers/databases/sqitch-on-windows.html]
tags: [Sqitch, Windows, Perl, ActivePerl, ActiveState]
type: post
---

Thanks to the hard-working hamsters at the [ActiveState PPM Index], Sqitch is
available for installation on Windows. According to the [Sqitch PPM Build
Status], the latest version is now available for installation. All you have to
do is:

1.  Download and install [ActivePerl]
2.  Open the Command Prompt
3.  Type `ppm install App-Sqitch`

As of this writing, only PostgreSQL is supported, so you will need to [install
PostgreSQL].

But otherwise, that’s it. In fact, this incantation works for any OS that
ActivePerl supports. Here’s where you can find the `sqitch` executable on each:

-   Windows: `C:\perl\site\bin\sqitch.bat`
-   Mac OS X: `~/Library/ActivePerl-5.16/site/bin/sqitch` (Or
    `/usr/local/ActivePerl-5.16/site/bin` if you run `sudo ppm`)
-   Linux: `/opt/ActivePerl-5.16/site/bin/sqitch`
-   Solaris/SPARC ([Business edition]-only):
    `/opt/ActivePerl-5.16/site/bin/sqitch`

This makes it easy to get started with Sqitch on any of those platforms without
having to become a Perl expert. So go for it, and then get started with [the
tutorial]!

  [ActiveState PPM Index]: http://code.activestate.com/ppm/
  [Sqitch PPM Build Status]: http://code.activestate.com/ppm/App-Sqitch/
  [ActivePerl]: http://www.activestate.com/activeperl/downloads#
  [install PostgreSQL]: http://www.postgresql.org/download/windows/
  [Business edition]: http://www.activestate.com/compare-editions
  [the tutorial]: https://github.com/theory/sqitch/blob/master/lib/sqitchtutorial.pod
