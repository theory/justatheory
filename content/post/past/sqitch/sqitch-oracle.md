--- 
date: 2013-05-09T22:11:46Z
slug: sqitch-oracle
title: Sqitch on Oracle
aliases: [/computers/databases/sqitch-oracle.html]
tags: [Sqitch, Oracle, Databases, SQL, Change Management]
type: post
---

I found myself with a little unexpected time at [work] recently, and since we
use Oracle (for a few more months), I decided to port [Sqitch]. Last night, I
released v0.970 with full support for Oracle. I did the development against an
[11.2 VirtualBox VM], though I think it should work on 10g, as well.

Sqitch is available from the usual locations. For Oracle support, you’ll need
the [Instant Client], including SQL\*Plus. Make sure you have [`$ORACLE_HOM`]
set and you’ll be ready to install. Via CPAN, it’s

    cpan install App::Sqitch DBD::Oracle

Via [Homebrew][]:

    brew tap theory/sqitch
    brew install sqitch-oracle

Via ActiveState PPM, install [ActivePerl], then run:

    ppm install App-Sqitch DBD-Oracle

{{% figure
  src   = "https://www.pgcon.org/2013/images/pgcon-220x250.png"
  alt   = "PGCon 2013"
  class = "left"
  link  = "https://www.pgcon.org/2013/"
%}}

There are a few other minor tweaks and fixed in this release; check the [release
notes] for details.

Want more? I will be giving a half-day tutorial, entitled “[Agile Database
Development],” on database development with [Git], [Sqitch], and [pgTAP] at on
May 22 [PGCon 2013] in Ottawa, Ontario. Come on up!

  [work]: http:/iovation.com/
  [Sqitch]: https://sqitch.org/
  [11.2 VirtualBox VM]: https://www.oracle.com/technetwork/database/enterprise-edition/databaseappdev-vm-161299.html
  [Instant Client]: https://www.oracle.com/technetwork/database/features/instant-client/index-097480.html
  [`$ORACLE_HOM`]: https://www.orafaq.com/wiki/ORACLE_HOME
  [Homebrew]: https://brew.sh
  [ActivePerl]: https://www.activestate.com/activeperl/downloads
  [release notes]: https://metacpan.org/source/DWHEELER/App-Sqitch-0.970/Changes
  [Agile Database Development]: https://www.pgcon.org/2013/schedule/events/615.en.html
  [Git]: https://git-scm.com/
  [pgTAP]: https://pgtap.org/
  [PGCon 2013]: https://www.pgcon.org/2013/