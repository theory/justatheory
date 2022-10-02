---
date: 2003-11-30T19:57:29Z
description: Getting closer to 1.8.0!
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-devel-1.7.1
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage-Devel 1.7.1
---

It gives me great pleasure to announce the release of Bricolage-Devel
1.7.1, the second development release for what will eventually become
Bricolage 1.8.0. This version of the open-source content management
system addresses all of the bugs discovered since the release of the
first development release, 1.7.0. The most significant changes include:

*   Eliminated the need for the Apache::ConfigFile module, and thus
    some annoying problems with the CPAN indexer when trying to install
    it. [David]

*   Passwords can be changed again. [Mike Slattery]

*   It is now virtually impossible to create media type or story type
    elements without site and output channel associations. This should
    eliminate errors when users try to create documents based on types
    without output channel associations. [David]

*   The "Output Channel" item for templates on desks now displays
    properly. [David]

*   Eliminated bogus "Use of element's 'name' field is deprecated"
    warnings. Key names are allowed to have digits and underscores, and
    we weren't consistent about that. [David]

*   The `display_element()` method in the Mason burner once again
    passes component arguments on to components. And now, so does
    `sdisplay_element()`. [David]

*   Fixed favicon.ico code so that the browser and server don't go into
    an infinite loop with redirects of redirects. The favicon.ico still
    doesn't pop up in the location field in my browser, but it does
    display properly if I point my browser at it. [David]

*   An attempt to create a document with the same URI as an existing
    document no longer litters the database with broken stories. Thanks
    to Arthur for the spot. [David]

*   Redirection after some publishes and previews works again, instead
    of returning a text page to the browser. [David]

*   Now displaying the name of the site each story and media document
    is in in Find Stories and Find Media. Suggested by Arthur. [David]

*   A number of fixes for the bric_media_upload contrib script:

      * Made it work with the 1.7.0 XML Schema.

      * Fixed a bug in its use of File::Find.

      * Fixed problem in calculating category names when given a
        directory to upload.

      * Added `--bric_soap` and `--site` options.

    See the script's usage info for details. [Dave Rolsky]

*   Changing a media item's category and then saving caused an error.
    [Dave Rolsky]

*   Changing a media document's cover date no longer causes the URI to
    disappear. Thanks to Dave Rolsky for the spot. [David]

*   Attempting to preview a story for which there are no associated
    destinations no longer causes the error 'Can't call method "ACCESS"
    without a package or object reference'. Thanks to Earle Martin for
    the spot! [David]

*   Added `output_channel_id` parameter to the `list()` method of
    Bric::Biz::Site in order to prevent sites without output channel
    associations from being listed in the select list for story type
    and media type elements. [David]

*   When a document fails to publish because there are no destinations
    configured, the UI no longer displays a message saying that it was
    published. [David]

*   Fixed page logging so that redirects to the page before the current
    page can work correctly. It was most noticeably broken when trying
    to associate a contributor with a document. [David]

*   The upgrade process no longer moves media document files to where
    Bricolage can't find them. If this happened to you, just `mv
    $BRICOLAGE_ROOT/comp.old/data $BRICOLAGE_ROOT/comp`. [David]

*   Performing an action in the contributor and category association
    interfaces in the story and media profiles no longer causes an
    empty search to be performed and return all contributors or
    categories. This could be a pain for organizations with 1000s of
    contributors or categories. Thanks to Scott for the report! [David]

*   The Key Name field in the element profile is no longer editable.
    Only new elements can type in the key name field. Thanks to Arthur
    for the spot! [David]

*   The Template toolkit burner now correctly uses element key names
    instead of names to find corresponding templates. [David]

*   Management of user groups in a double list manager UI no longer
    causes an SQL error. Spotted by Alexander Ling. [David]

*   Sites added to a site group will now be listed as members of the
    site group in the site group's profile. Thanks to Alexander Ling
    for the spot. [David]

*   Improved permission checking in the virtual FTP server. [David]

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason], [HTML::Template], and [Template
Toolkit] support for flexibility, and many other features. It operates in an
[Apache]/[mod_perl] environment, and uses the [PostgreSQL] RDBMS for its
repository. A comprehensive, actively-developed open source CMS, Bricolage has
been hailed as "Most Impressive" in 2002 by eWeek.

Learn more about Bricolage and download it from the [Bricolage home page].

Enjoy!

David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=200856
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/16084/
    "use.perl.org journal of Theory: “Bricolage-Devel 1.7.1”"
