---
date: 2004-03-02T06:13:10Z
description: 'Next up, RC1.'
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-devel-1.7.3
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage-Devel 1.7.3
---

I'm thrilled to announce the release of Bricolage-Devel 1.7.3, the
fourth development release for what will soon become Bricolage 1.8.0.
This version of the open-source content management system addresses all
of the bugs discovered since the release of the third development
release, 1.7.2, and adds several new features and numerous
improvements. The most significant changes since 1.7.2 include:

*   New Features

    * The virtual FTP server now moves templates into workflow when
      they're uploaded and puts them into the user's sandbox. This
      behavior allows the user to test the template changes without
      imposing possible bugs upon other Bricolage users. This approach
      is much safer than the previous behavior, which simply checked in
      and deployed a template upon upload. Templates can still be
      deployed via the virtual FTP server by appending `.deploy` to
      their names. The original behavior of always deploying templates
      upon upload can be restored by enabling the `FTP_DEPLOY_ON_UPLOAD`
      bricolage.conf directive. [David]

    * Added `ANY` function to be used with select parameters to story,
      media, and template (formatting) list. Pass a list of values to
      this function to have any of of them match for a given parameter.
      This is especially useful for matching on, say, a list of URIs or
      category IDs. This function is automatically available in
      templates. [David]

    * Added a feature that counts characters used in a textarea
      subelement on the fly. It displays this figure and the number of
      characters left, immediately above the textarea. This feature is
      enabled when the Max size attribute for the textarea is given a
      non zero value when adding it to the element profile stage. The
      JavaScript will also not allow you to have more than max size
      characters in the textarea by truncating the data to that number
      of characters every time someone adds another character beyond
      the maximum. [Paul Orrock/Digital Craftsmen]

    * Added a feature to display image thumbnails in the search results
      and active view for media objects that are image objects. This
      feature uses the Perl module Imager from CPAN and the relevant
      image library for each format you want to display. It can be
      turned on or off using the `USE_THUMBNAILS` bricolage.conf
      directive. See Bric::Biz::Asset::Business::Media::Image for more
      information. [Paul Orrock/ Digital Craftsmen]

*   Improvements

    * More story, media, and template query optimization. [David]

    * The story, media, and template queries now use aggregates to
      create arrays of group IDs, instead of returning a separate row
      for each individual group ID. Since all story, media, and
      template objects are now returned in single rows instead of
      potentially many rows, this greatly cuts down on the overhead of
      fetching data from the database. Suggested by Josh Berkus.
      [David]

    * Thanks to the aggregation of group IDs into a single row for each
      story, media and template object, the `Offset` and `Limit`
      parameters to the `list()` methods of the story, media, and
      template (formatting) classes are now handled by the database
      back end, instead of in Perl space. This makes using these
      parameters much more efficient.

    * Added `get_element()` method to Bric::Biz::Asset::Business and
      deprecated the `get_tile()` method. This will make things a bit
      more consistent for template developers, at least. [David]

    * Added `primary_category_id` parameter to the story class' `list()`
      method. [David]

    * The list of output channels available to be included in an output
      channel now has the name of the site with which each is
      affiliated listed as well. This is to prevent confusion between
      output channels with the same names in different sites. [David]

    * The Contributor manager no longer presents a "New" link if the
      Contributor Type on which the contributor is based has no custom
      fields. This will prevent folks from creating new contributor
      roles in the UI only to find that Bricolage hasn't created them
      because there are no custom fields. [David]

    * In the formBuilder interface used by the Element and Contributor
      Type profiles, the maximum length of text and textarea fields is
      no "0", or unlimited. [David]

    * When publishing from a publish desk, you can now uncheck related
      assets in order to not publish them. [Scott]

*   Bug Fixes

    * The virtual FTP server now correctly creates a utility template
      when a template with an unknown name is uploaded. [David]

    * The virtual FTP server now pays proper attention to all
      permissions. [David]

    * A number of upgrade script annoyances were cleared up. [David]

    * The `simple` parameter to the Media class' `list()` method works
      again. As a result, so does "Find Stories" in the UI. [David]

    * Several Alert Type fixes. Rule regular expression matching (=~,
      !~) now handles patterns containing slashes (important for URIs,
      for example). Attributes no longer show up as stringified hash
      references in subject or message variable substitution.
      $trig_password was removed from the Profile as it caused an error
      and was useless anyway. And finally, duplicate and spurious
      attributes were removed from the rules and message variable
      lists. [Scott & David]

    * Fixed Template Element list, where container elements appeared
      twice. [Joao Pedro]

    * Changes to site settings are now correctly reflected in the UI
      for all users as soon as they are made. [David]

    * Autopopulated fields in media elements can once again have their
      values fetched in templates. This problem was due to bad key
      names being created for new image elements created after
      upgrading to 1.7.0. [David]

    * The workflow profile no longer displays deactivated sites in the
      site select list. Thanks to Serge Sozonoff for the spot. [David]

    * Fixed URI uniqueness upgrade scripts, which were having problems
      with PostgreSQL permissions. [David]

    * `make clone` works again. [David]

    * Distribution jobs can be edited via the UI again. Thanks to
      Marshall Roch for the spot. [David]

    * Publishes once again work when the "Date/Time Format" preference
      is set to something other than ISO-8601. Reported by Marshall
      Roch. [David]

    * Fixed previewing with multiple OCs. [Serge Sozonoff]

    * Fixed a bug in `bric_soap story create/update` caused by
      refactoring in version 1.7.0. Found by David during a demo.
      [Scott]

    * An attempt to preview a story for which no template exists now
      gives a friendly error message again. This was broken by the
      change in 1.7.2 that made the Mason burner use document templates
      as true dhandlers. [Dave Rolsky]

    * The workflow menus in the side navigation layer no longer
      disappear after a server restart. Reported by Ben Bangert.
      [David]

    * The Mason burner's special `<%publish>`, `<%preview>`, and
      <%chk_syntax> tags now work as advertised. Reported by Ben
      Bangert. [David]

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

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=220916
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17709/
    "use.perl.org journal of Theory: “Bricolage-Devel 1.7.3”"
