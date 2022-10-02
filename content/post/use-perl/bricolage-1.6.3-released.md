---
date: 2003-08-12T22:12:08Z
description: Important fixes make this upgrade a must.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.6.3-released
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.6.3 Released
---

I'm pleased to announce announce the release of Bricolage-Devel 1.6.3.
This maintenance release addresses a number issues discovered since the
release of version 1.6.2. Some of the more important changes since
1.6.2 include:

*   Document and contributor type field information (label, options) is
    no longer pushed through Locale::Maketext, thus preventing errors
    when element and contributor type admins create field options with
    brackets in them.

*   Documents associated with categories that have been deleted will
    once again work properly. Even though a category may be
    deactivated, any documents previously put into that category should
    still work, and still treat the category as a working category. And
    so they do.

*   Permissions granted on the "All" groups work again.

*   Resize now works in super bulk edit.

*   When a template is deployed, Bricolage now checks to see if its
    file name has changed since it was last deployed, and if it has, it
    deletes the old file.

*   Optimized performance of Bric::Dist::Resource queries and wrote
    lots of tests for them.

*   When a story or media document is published, Bricolage now looks to
    see if any files distributed for previous versions of the document
    are no longer associated with the document, and expires them if
    they are. It does so on a per-output channel basis, so note that if
    output channel settings have changed since the document was last
    published, the expiration may miss some stale files. The same goes
    for when destinations are changed. But this should cover the vast
    majority of cases.

*   Text input fields no longer impose a default maximum field length.
    This is so that element fields that have their maximum length set
    to 0 can truly be unlimited in length.

*   Passing an undef via the `workflow__id` parameters to the `list()`
    method of Story, Media, or Template once again causes Bricolage to
    correctly return only those assets that are not in workflow.

*   Extra blank lines between subelement tags in super bulk edit no
    longer causes an error.

*   Searches no longer return unexpected results or all objects when
    pagination is enabled.

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason] and [HTML::Template] support for
flexibility, and many other features. It operates in an [Apache]/[mod_perl]
environment, and uses the [PostgreSQL RDBMS] for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
"Most Impressive" in 2002 by [eWeek].

Learn more about Bricolage and download it from the [Bricolage home page].

Enjoy!

--- David

*Originally published [on use Perl;]*

  [changes file]: https://sourceforge.net/project/shownotes.php?release_id=177689
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL RDBMS]: http://www.postgresql.org/
  [eWeek]: http://www.eweek.com/article2/0,3959,800596,00.asp
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/14071/
    "use.perl.org journal of Theory: “Bricolage 1.6.3 Released”"
