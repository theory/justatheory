---
date: 2003-10-04T00:18:13Z
description: Likely the last 1.6.x maintenance release.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.6-released
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.6 Released
---

I'm pleased to announce the release of Bricolage 1.6.6. This
maintenance release addresses a number issues discovered since the
release of version 1.6.5. Some of the more important changes include:

*   Added README.Solaris.

*   When an asset is published or deployed directly from the asset
    profile, it is now properly removed from the publish or deploy
    desk.

*   Templates now display their output channel associations instead of
    their element associations on desks. This seems to be more useful,
    since the element association is usually obvious from the name.

*   The category URI is now displayed for assets on desks, rather than
    the name. This is consistent with the display of the category
    elsewhere.

*   Elements to which no subelements can be added will no longer
    display an empty select list and "Add Element" button.

*   Bug fix when deploying to multiple output channels. If the output
    channel IDs matched each other partly, it could cause a file to be
    removed after it just had been uploaded.

*   Users with CREATE access to a start desk can once again create
    stories on that desk even when they don't have CREATE access to
    "All Stories."

*   Each upgrade script is now run within the confines of a single
    database transaction. If any database changes within an upgrade
    script encounter an error, all of the changes in that script will
    be rolled back.

*   An upgrade script failure will now cause "make upgrade" to halt
    installation so that any issues are immediately identified and
    correctable.

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

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=188766
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/15056/
    "use.perl.org journal of Theory: “Bricolage 1.6.6 Released”"
