---
date: 2004-02-13T02:09:45Z
description: Massive performance improvements abound.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-devel-1.7.2
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage-Devel 1.7.2
---

I'm thrilled to announce the release of Bricolage-Devel 1.7.2, the
third development release for what will eventually become Bricolage
1.8.0. This version of the open-source content management system
addresses all of the bugs discovered since the release of the second
development release, 1.7.1, and adds several new features and some
tremendous performance optimizations. The most significant changes
since 1.7.1 include:

*   New Features

    * Bricolage now has a much more robust security policy. Users with
      permission to edit various objects and groups in the
      administrative interface can no longer increase their
      permissions. Nor can they manage the membership of groups of
      which they are not members or do not have EDIT access to the
      members. All this is to prevent users from giving themselves
      higher permissions. [David]

    * Added "publish_another()" method to Bric::Util::Burner. This
      method publishes a document other than the one currently being
      published. This is useful when a template for one document type
      needs to trigger the publish of another document. [David]

    * Added new permissions "RECALL" and "PUBLISH". These permissions
      apply only to asset groups, including desks, categories, and
      workflows. Now users must have RECALL permission to recall assets
      from the library and bring them into workflow, and PUBLISH
      permission to publish assets. This should make it much easier to
      create more flexible permissions to manage approval processes.
      [David]

    * Bricolage now supports per-user preferences. Admins can mark a
      preference as override-able, which allows users to set this
      preference to their preferred value. [Dave Rolsky]

    * The character set and language preferences have been moved into
      the database, so that these can be overridden by individual users
      if needed. [Dave Rolsky]

    * Added the "bric_queued" daemon to take advantage of the new
      publication scheduling of Bric::Util::Job::Pub. Together with the
      use of a carefully tuned instance of Bricolage, these new
      features allows the Bricolage administrator to control the amount
      of system resources given over to publishing. [Mark]

    * German localization completed. [Thorsten Biel]

    * Added User and Desk (asset) modules to the SOAP API, added asset
      commands to the Workflow module, and made corresponding changes
      to bric_soap. [Scott]

    * Added "burn_again" attribute to the Mason burner. This method can
      be called from within a template to force the burner to burn the
      current page again, creating a new file. This can be useful for
      creating multi-file output without extra paginated subelements.
      [David]

    * Added zh-cn localization, with translation based on zh-tw.
      [Kang-min Liu]

*   Improvements

    * Fixed upgrade scripts to be more intelligent in their handling of
      transactions. They no longer allow SQL errors without failing the
      upgrade. The upgrade scripts have also been updated to ensure
      successful upgrades to Bricolage installations as far back as
      1.4.0. [David]

    * Added "element_key_name" parameter to the "list()" method of the
      story, media, and formatting classes. This makes it easier to use
      the name of a story type element, media type element, or template
      element to search for assets, rather than the "element__id"
      parameter, which isn't as friendly. [David]

    * Added "Filter by Site Context" preference. When active, search
      results only return assets relative to the site context instead
      of all the sites the user has access to [JoÃ¢â¬Å¾o Pedro]

    * The Mason burner now uses document templates as true dhandlers,
      enabling full Mason-style inheritance from autohandlers to work
      properly. [David & Dave Rolsky]

    * "All *" groups can now be accessed via the Group Manager. Their
      names and memberships cannot be edited, but their permissions
      can. Inspired by a bug report from Patrick Walsh. [David]

    * Queries for stories, media, and templates have been greatly
      optimized. Thanks to a large database from *The Register* and
      query optimization from Josh Berkus (under sponsorship from WHO)
      and Simon Myers of GBDirect, searches for stories in the UI are
      now 10-40 times faster than they were before (depending on the
      version of PostgreSQL you're running). [David]

    * Added the "story.category" parameter to the "list()" method of
      Bric::Biz::Asset::Business::Story. Pass in a story ID, and a list
      of stories in the same categories as the story with that ID will
      be returned, minus the story with that ID. This parameter
      triggers a complex join, which can slow the query time
      significantly on underpowered servers or systems with a large
      number of stories. Still, it can be very useful in templates that
      want to create a list of stories in all of the categories the
      current story is in. But be sure to use the parameter! Thanks to
      Josh Berkus for his help figuring out the query syntax. [David]

*   Bug Fixes

    * Category groups can be edited again. Reported by Alexander Ling.
      [David]

    * Elements can be edited again. Thanks to Alexander Ling for the
      spot! [David]

    * Element fields can be edited again without encountering the
      "called the removed method 'get_name'" error. Reported by
      Alexander Ling. [David]

    * Templates can be deleted again. Thanks to Adeola Awoyemi for the
      spot! [David]

    * Stories and media with non-unique URIs can now be deleted.
      Reported by Simon Wilcox. [David]

    * Checkin and Publish once again works in the media profile. Thanks
      to Alexander Ling for the spot. [David]

    * The inline "Bulk Edit" feature in story and media profiles works
      again. Thanks to Neal Sofge for the spot! [David]

    * Templates are now correctly saved to the user's sandbox when
      "Save and Stay" is pressed. [JoÃ¢â¬Å¾o Pedro]

    * Select lists now correctly save their states so that, for
      example, dropdown menus in New Story remember the element and
      category that was selected last time. [Scott]

    * Sites can now be disassociated with elements. Reported by
      Alexander Ling. [David]

    * Redirects during previews work again. [David]

    * The virtual FTP server works again for the first time since
      before the release of 1.7.0. Now when you log in to the FTP
      server, the root directory will contain a list of sites. When you
      change directories into one of the site directories, you'll see a
      list of the output channels in that site. [David]

    * The virtual FTP server no longer displays output channels or
      categories (or sites) that the user does not have at least READ
      permission to access. [David]

For a complete list of the changes, see the [changes file].

**ABOUT BRICOLAGE**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete [HTML::Mason], [HTML::Template], and [Template
Toolkit] support for flexibility, and many other features. It operates in an
[Apache]/[mod_perl] environment, and uses the [PostgreSQL] RDBMS for its
repository. A comprehensive, actively-developed open source CMS, Bricolage has
been hailed as "Most Impressive" in 2002 by eWeek.

Learn more about Bricolage and download it from the [Bricolage home
page].

Enjoy!

David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=216763
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17387/
    "use.perl.org journal of Theory: “Bricolage-Devel 1.7.2”"
