---
date: 2003-10-22T22:37:46Z
description: Gearing up for 1.7.0.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.7
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.7
---

I'm pleased to announce the release of Bricolage 1.6.7. This
maintenance release addresses a few issues discovered since the release
of version 1.6.6. Some of the more important changes include:

*   Fixed "bric_soap" to accept a "--server" argument starting with
    "https", which is more friendly to an SSI environment.

*   The PostgreSQL admin username and password arguments were reversed
    during "make upgrade".

*   Added partial index to speed queries against the job table, and
    thus to speed distribution.

*   Updated slug RegExen. They were a bit too strict, and should be
    better now, allowing dots, dashes, and underscores.

*   Inactive alert types no longer trigger the sending of alerts.

*   Fixed "element_data_id" parameter to
    Bric::Biz::Asset::Business::Parts::Tile::Data to actually work.

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason] and [HTML::Template] support for
flexibility, and many other features. It operates in an [Apache]/[mod_perl]
environment, and uses the [PostgreSQL] RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
"Most Impressive" in 2002 by eWeek.

Learn more about Bricolage and download it from the [Bricolage home page].

Enjoy!

David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=192775
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/15328/
    "use.perl.org journal of Theory: “Bricolage 1.6.7”"
