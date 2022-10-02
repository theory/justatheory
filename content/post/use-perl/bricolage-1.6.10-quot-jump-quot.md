---
date: 2004-02-29T21:41:16Z
description: Get ready to jump to 1.8.0!
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.10-quot-jump-quot
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.10 &quot;Jump&quot;
---

I'm pleased to announce the release of Bricolage 1.6.10 "Jump". This
maintenance release addresses a number issues discovered since the
release of version 1.6.9. Here is the complete list of changes for this
release:

*   Added missing index to the "workflow__id" column of the "story",
    "media", and "formatting" (template) tables. [David]

*   Made index on the "desk__id" column of the "story", "media", and
    "formatting" (template) tables a partial index, since the column
    will usually be "NULL". [David]

*   Added an index to the description column of the "story_instance",
    "media_instance", and "formatting" (template) tables to speed up
    simple searches. [David]

*   Added missing foreign key constraints for the "desk_id" column of
    the "story", "media", and "formatting" (template) tables. [David]

*   "make clone" no longer fails when it can't find httpd.conf, because
    it no longer looks for it. [David]

*   "make clone" no longer assumes that the conf directory is in
    $BRICOLAGE_ROOT, and prompts the user to find out. [David]

*   Bricolage once again works with Perl 5.6.x and Perl 5.8.1. [David]

*   Made bric_republish and bric_dev_sync safe to use with "https://".
    [Geoff Richards]

*   The user object is no longer instantiated from the database every
    time a user sends a request to Bricolage. It appears that this bit
    of overhead has unfortunately been imposed on every request since
    Bricolage 1.0 due to a very stupid typo. [David]

*   The creation of the Bricolage PostgreSQL user and database during
    installation no longer complains about usernames or database names
    with dashes and other non-alphanumeric characters in them. Thanks
    to Marshall Roch for the spot! [David]

*   Fixed ancient bug revealed by the release of DBI 1.41. [David]

*   Photoshop-generated images no longer make Bricolage choke when
    they're uploaded to a Media profile that autopopulates fields.
    Reported by Paul Orrock. [David]

*   The "lookup()" method of the story, media, and template classes
    will now correctly return inactive objects. [David]

*   Fixed typo of "CHECK_FREQUENCY" in Bric::Config that made it always
    use the default of 1. [Scott]

*   The "lookup()" method of the story, media, and template classes
    once again attempt to retrieve objects from the per-request cache
    before looking them up in the database. [David]

*   Changed the name of the event logged when templates are checked out
    from "Template Checked Out Canceled" to the correct "Template
    Checked Out." [David]

  See the [changes page]
  for a complete history of Bricolage changes.

  **ABOUT BRICOLAGE**

  Bricolage is a full-featured, enterprise-class content management and
  publishing system. It offers a browser-based interface for ease-of use, a
  full-fledged templating system with complete [HTML::Mason] and
  [HTML::Template] support for flexibility, and many other features. It operates
  in an [Apache]/[mod_perl] environment, and uses the [PostgreSQL] RDBMS for its
  repository. A comprehensive, actively-developed open source CMS, Bricolage has
  been hailed as "Most Impressive" in 2002 by *eWeek*.

  Learn more about Bricolage and download it from the [Bricolage home page].

  Enjoy!

  David

*Originally published [on use Perl;]*

  [changes page]: http://sourceforge.net/project/shownotes.php?release_id=220606
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home   page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17684/
    "use.perl.org journal of Theory: “Bricolage 1.6.10 &quot;Jump&quot;”"
