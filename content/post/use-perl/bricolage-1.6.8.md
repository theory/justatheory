---
date: 2003-11-30T02:35:59Z
description: Includes support for PostgreSQL 7.4.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.8
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.8
---

I'm pleased to announce the release of Bricolage 1.6.8. This
maintenance release addresses a few issues discovered since the release
of version 1.6.7. Here is the complete list of changes for this
release:

*   Custom select fields now correctly pay attention to the size
    attribute. Reported by Dave Rolsky. [David]

*   The element type manager now displays "Subelement" instead of
    "Story" for subelement element types. Suggested by Dave Rolsky.
    [David]

*   Updated to work with PostgreSQL 7.4. [David]

*   Improved error message in Bric::Util::Trans::SFTP. [David]

*   It's possible to create new stories again without running into
    errors saying that a URI is not unique because the cover date and
    slug were accidentally excluded from the URI. [David]

*   Mason story templates now inherit from all category templates, thus
    enabling the access of `<%attr>`s and calling of `<%method>`s in
    category templates from story templates. [David]

*   Permission to edit element fields is now based on the permissions
    granted to edit the elements they belong to. This means that users
    other Global Admin group members can now edit fields. [David]

*   Dates are no longer editable if a user doesn't have permission to
    edit them. [David]

*   Users without EDIT access to an element no longer see a link to
    Edit fields of that element, but a link to View them, instead. They
    will also no longer see an "Add Subelements" button. [David]

*   Fixed bug that triggered an invalid error message when a story URI
    is non-unique. Reported by Kevin Elliott. [David]

*   Assets with the same IDs but in different classes (media vs.
    stories vs. templates) no longer prevent each other from being
    added to a desk that can contain different classes of assets.
    Thanks to Scott for the spot and doing the research that lead to
    the replication of the problem. [David]

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason] and [HTML::Template] support for
flexibility, and many other features. It operates in an [Apache]/[mod_perl]
environment, and uses the [PostgreSQL] RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
"Most Impressive" in 2002 by *eWeek*.

Learn more about Bricolage and download it from the [Bricolage home page].

Enjoy!

David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=200747
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/16073/
    "use.perl.org journal of Theory: “Bricolage 1.6.8”"
