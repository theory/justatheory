---
date: 2003-09-11T01:19:20Z
description: More goodness delivered!
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.5-released
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.5 Released
---

I'm pleased to announce announce the release of Bricolage 1.6.5. This
maintenance release addresses a number issues discovered since the
release of version 1.6.4. Some of the more important changes include:

*   Previewing stories with related media that have no associated file
    no longer causes an error.

*   Switched to using `DBI->connect_cached()` from using our own
    database connection caching. This change does bump up the minimum
    required version of DBI to 1.18, though the latest version is
    always recommended. It's also the right thing to do.

*   Fixed issue that could cause Bric::Util::DBI to create inconsistent
    transaction states.

*   Passing an undef via the `workflow__id` parameters to the `list()`
    method of Story, Media, or Template really does again cause
    Bricolage to correctly return only those assets that are not in
    workflow. It wasn't as fixed in 1.6.3 as I had thought.

*   Vastly improved the speed of the query that lists events, and added
    an index to help it along, as well.

*   The FTP mover now properly deletes files rather than erroring out.

*   Users without EDIT access to the start desk in a workflow can no
    longer create assets in that workflow. Nor can they check out
    assets from the library, as there's no start desk for them to check
    them in to. But they can still check them out from other desks that
    they have EDIT access to.

*   Time zone issues have been fixed to be more portable. Some
    platforms that experienced Bricolage unexpectedly shifting cover
    dates and other dates and times by several hours should no longer
    see this problem.

*   Adding a new element type with the same name as an existing or
    deleted element type no longer causes an SQL error.

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

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=183771
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/14640/
    "use.perl.org journal of Theory: “Bricolage 1.6.5 Released”"
