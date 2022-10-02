---
date: 2004-04-11T15:38:41Z
description: Expect 1.8.0 in two weeks.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.7.5-ashland-1.8.0-rc2
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.7.5 "Ashland" (1.8.0 RC2)
---

I'm thrilled to announce the release of Bricolage-Devel 1.7.5
"Ashland", the second release candidate for Bricolage 1.8.0. This
version of the open-source content management system addresses all of
the bugs discovered since the release of the first release candidate,
1.7.4, and adds several new features and numerous improvements. The
changes since 1.7.4 include:

*   New Features

    * Added bric_template_dump to contrib. This script uses the
      Bricolage SOAP server to export all of the templates in a single
      output channel. [David]

    * Added `SFTP_MOVER_CIPHER` bricolage.conf directive to tune the
      SFTP mover (if enabled) to the best cipher for good performance
      on the wire. [David]

*   Improvements

    * Added site and output channel support to bric_template_diff and
      bric_template_patch in contrib. [David]

    * When cloning a story, you can now select a new primary output
      channel, in addition to category, slug, cover date, etc.
      Suggested by Serge Sozonoff. [David]

    * Spell checking now works in HTMLArea. [Eric Sellers]

    * When creating a new story without a slug, Bricolage will now
      autogenerate a slug based on the title. [João Pedro]

    * Added single underscore parameters to the `list()` methods of the
      Story, Media, and Template classes to complement those that have
      the awful double underscores. [David]

    * Made SOAP modules more tolerant of lack of sites in 1.6. [Scott]

    * The collection API now checks newly added members when deleting
      members. This ensures that newly added objects won't be saved to
      the database if they are deleted, first. [David]

    * Turned off browser autocompletion in the Server and User
      profiles. This prevents some browsers (e.g., Camino) from filling
      in your username and password where it doesn't belong. [David]

    * When the "Filter by Site Context" preference is enabled, it no
      longer filters documents when searching for documents to alias.
      Reported by Patrick Walsh. [David]

    * The "Cancel Checkout" button in the Story, Media, and Template
      profiles now tries to do the right thing instead of just leaving
      the asset on a desk in workfow every time. If the asset was just
      created by the user, it will be deleted. If it was just recalled
      from the library by the user, it will be removed from workflow
      and shelved in the library. Otherwise, clicking the "Cancel
      Checkout" button will leave the asset in workflow. Requested by
      Sara Wood, Rachel Murray, and others. [David]

    `make clone` now provides the current date and time for the default
    name for the cloned package. Suggested by Marshall Roch. [David]

*   Bug Fixes

    * Bricolage no longer tries to display thumbnails for related
      stories, since stories don't have thumbnails and would therefore
      create an error. [Eric Sellers]

    * Text::Levenshtein is again correctly loaded as an optional
      module, not a required module. Reported by Marshall Roch. [David]

    * Bric::Util::Burner's `preview_another()` method now actually
      works. Thanks to Serge Sozonoff for the spot. [David]

    * Fixed clone interface for IE users. Spotted by Serge Sozonoff.
      [Scott]

    * Some of the supported values for the `Order` parameter to the
      Story, Media, and Template classes, such as `category_uri`, did
      not work before. Now they do. [David]

    * Changing categories on a template no longer creates
      Frankensteinian template paths. [David]

    * Added constant `HAS_MULTISITE` to the Bric base class so that
      all classes properly declare themselves for UI search results.
      [João Pedro]

    * Story and Media SOAP calls now correctly use the element's key
      name to identify the element. [João Pedro]

    * Story, Media, and Template creation via SOAP now correctly look
      up the Category by URI and site ID. [João Pedro & David]

    * The Template SOAP interface now suports the `site` parameter to `list_ids()`.
      [David]

    * The Story, Template, and Media SOAP `list_ids()` interfaces now
      properly look up categories, output channels, and workflows with
      the `site` parameter, if there is one. [David]

    * The `LOAD_LANGUGES` and `LOAD_CHAR_SETS` directives are now space
      delimited, to better match other bricolage.conf options. [David]

    * Aliased media documents now correctly point to the file name for
      the aliased media document. Reported by Patrick Walsh. [David]

    * Thanks to the improvements to the collection class, cloning
      stories and putting them into new output channels to ensure that
      they have unique URIs now works properly. Reported by Serge
      Sozonoff. [David]

    * The publish status and version is once again properly set for
      media when they are published. Reported by Serge Sozonoff.
      [David]

    * The group manager now properly displays the names of the sites
      that member objects are associated with if the class of the
      objects being managed knows that its objects are associated with
      sites. Reported by Ho Yin Au. [David]

    * The list of output channels to add to a media or story document
      in the media and story profiles now includes only those output
      channels associated with the site that the story or media
      document is in. [David]

    * Thanks to the fix to 1.6.13 that prevents deleted groups from
      affecting permissions, there is no longer any need to provide a
      checkbox to get access to deleted groups in the permissions
      interface. So it has been removed. [David]

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

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=230340
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/18283/
    "use.perl.org journal of Theory: “Bricolage 1.7.5 "Ashland" (1.8.0 RC2)”"
