--- 
date: 2010-06-15T17:56:33Z
lastMod: 2022-05-22T21:36:57Z
slug: pgxn-development-project
title: PGXN Development Project
aliases: [/computers/databases/postgresql/pgxn-development-project.html]
tags: [Postgres, PGXN, CPAN, Fundraising]
type: post
---

I'm pleased to announce the launch of the [PGXN] development project. I've
written a [detailed specification] and pushed it through general approval [on
pgsql-hackers]. I've written up a detailed [project plan] and estimated things
at a highly reduced [PostgreSQL Experts] rate to come up with a fundraising
goal: $25,000. And now, thanks to [founding contributions] from
[myYearbook.com], and [PostgreSQL Experts], we have started the fundraising
phase of the project.

So what’s this all about? PGXN, the PostgreSQL Extension Network, is modeled on
[CPAN], the Perl community’s archive of “all things Perl.” PGXN will provide
four major pieces of infrastructure to the PostgreSQL community:

-   An upload and distribution infrastructure for extension developers (models:
    [PAUSE] & [CPAN][1], [JAUSE])
-   A centralized index and API of distribution metadata (models: [CPAN Meta
    DB], [02packages.details.txt])
-   A website for searching extensions and perusing their documentation (models:
    [search.cpan.org], [Kobesearch], [JSAN])
-   A command-line client for downloading, testing, and installing extensions
    (models: [cpanminus], [CPAN.pm], [JSAN Shell])

I've been wanting to start this project for a long time, but given my need to
pay the bills, it didn’t seem like I'd ever be able to find the time for it.
Then Josh Berkus suggested that we try to get community interest and raise money
for me to have the time to work on it. So I jumped on that, putting in the hours
needed to get general approval from the core PostgreSQL developers and to create
a reasonable project plan and web site. And thanks to MyYearbook’s and PGX’s
backing, I'm really excited about it. I hope to start on it in August.

If you'd like to contribute, first: **Thank You!**. The [PGXN site] has a Google
Checkout widget that makes it easy to make a donation. If you'd rather pay by
some other means (checks are great for us!), [drop me a line] and we'll work
something out. We have a few levels of [contribution][founding contributions] as
well, including permanent linkage on the PGXN site for your organization, as
well as the usual t-shirts launch party invitations.

  [PGXN]: http://pgxn.org/ "PostgreSQL Extension Network"
  [detailed specification]: http://wiki.postgresql.org/wiki/PGXN
    "PGXN Specification"
  [on pgsql-hackers]: http://www.mail-archive.com/pgsql-hackers@postgresql.org/msg143645.html
    "pgsql-hackers archive: RFC: PostgreSQL Add-On Network"
  [project plan]: http://pgxn.org/status.html "PGXN Project Status"
  [PostgreSQL Experts]: http://www.pgexperts.com/
  [founding contributions]: http://pgxn.org/contributors.html
    "PGXN Contributors"
  [myYearbook.com]: http://www.myyearbook.com
  [CPAN]: http://cpan.org
  [PAUSE]: http://pause.perl.org
  [1]: http://cpan.org/
  [JAUSE]: http://openjsan.org/jause/
  [CPAN Meta DB]: http://cpanmetadb.appspot.com/
  [02packages.details.txt]: http://cpan.perl.org/modules/02packages.details.txt
  [search.cpan.org]: https://search.cpan.org/
  [Kobesearch]: https://web.archive.org/web/20100528163151/http://kobesearch.cpan.org/
  [JSAN]: http://openjsan.org/
  [cpanminus]: http://cpanmin.us/
  [CPAN.pm]: https://metacpan.org/pod/cpan
  [JSAN Shell]: https://metacpan.org/pod/jsan
  [PGXN site]: http://pgxn.org/ "PGXN"
  [drop me a line]: mailto:pgxn@pgexpergts.com
