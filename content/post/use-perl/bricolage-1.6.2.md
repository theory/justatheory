---
date: 2003-07-28T14:50:08Z
description: The most solid and reliable release to date.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.2
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.2
---

I'm pleased to announce announce the release of Bricolage-Devel 1.6.2. This
maintenance release addresses numerous issues discovered since the release of
version 1.6.1. Some of the more important changes since 1.6.1 include:

*   New help pages for the destination, server, and action profiles.

*   Fixed issue where new output channels added to a document type
    element were not always actually saved as a part of that element.

*   Fixed installer to again work with versions of PostgreSQL prior to
    7.3.

*   Alert types can once again be deleted from the alert type profile.

*   Users can now only add subelements to a story if they have at least
    READ permission to those subelements.

*   The media type profile again allows extensions to be added and
    removed.

*   Perl 5.8.0 or later is now strongly recommended for better Unicode
    support.

*   Fixed deleting an Alert Type Rule. Also fixed Editing Alert Type
    Recipients.

*   Clicking "Cancel" in an element no longer saves the changes in that
    element before going up to the parent element.

*   Added Localization support to widgets that were missing it. Added
    pt_pt localized images.

*   Documents are no longer distributed to deleted (deactivated)
    destinations.

*   Eliminated several error log authentication message such as "No
    cookie found." These tended only to confuse users when they were
    just starting to use Bricolage.

*   Elements added with the same name as an existing, active or
    inactive element no longer trigger an SQL error to be displayed.

*   Fixed issue where adding an output channel to a document type
    element removed that output channel from another document type
    element.

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason] and [HTML::Template] support for
flexibility, and many other features. It operates in an [Apache]/[mod_perl]
environment, and uses the [PostgreSQL RDBMS] for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
"Most Impressive" in 2002 by [eWeek].

Learn more about Bricolage and download it from the [Bricolage home
page].

Enjoy!

--- David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=174317
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL RDBMS]: http://www.postgresql.org/
  [eWeek]: http://www.eweek.com/article2/0,3959,800596,00.asp
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/13727/
    "use.perl.org journal of Theory: “Bricolage 1.6.2”"
