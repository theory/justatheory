---
date: 2003-10-22T23:43:41Z
description: Well on our way to 1.8.0!
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-devel-1.7.0
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage-Devel 1.7.0
---

It give me great pleasure to announce the release of Bricolage-Devel
1.7.0, the first development release for what will eventually become
Bricolage 1.8.0. In addition to all of the bug fixes included in the
1.6.x series, this version of the open-source content management system
adds a number of significant new features. The most significant changes
include:

*   Added multisite support. Now all stories, media, output channels,
    templates, categories, and workflows may be associated with
    different sites, and even have the same names in different sites.
    This simplifies the management of multiple Web sites with
    Bricolage. Story type and media type elements may be shared between
    sites. Funded by Portugal Telecom Multimedia.

*   Added document aliasing. Stories and media in a site may now be
    aliased and published in another site, as long as the elements on
    which they are based are shared between sites. Control over the
    content of aliased documents remains in the original site, thus
    ensuring the editorial integrity of the document for that site.
    Funded by Portugal Telecom Multimedia.

*   Added `$burner->sdisplay_element` method to Bric::Util::Burner.
    This is a `sprintf`-style version of `$burner->display_element`.

*   Added the `YEAR_SPAN_BEFORE` and `YEAR_SPAN_AFTER` bricolage.conf
    directives. These directives enable control how many years before
    and after the current year to display in the list of years in the
    date and time select widget. The default values are 10 for each,
    meaning that if the current year is 2003, then the date span will
    be from 1993 to 2013.

*   Added "Email" action, which can be used to email the files
    generated by a publish to one or more email addresses. Funded by
    ETonline.

*   Callbacks were moved from Mason components to modules based on
    Params::Callback and managed by MasonX::Interp::WithCallbacks. This
    makes the UI layer more responsive and enhances maintainability.

*   Optimized performance of URI uniqueness checks by adding database
    tables to do the job, rather than constructing the URIs for all
    other documents in the same categories as the document being
    checked. This was the last major bottleneck affecting SOAP
    performance, as well as document editing in general. Funded by
    Kineticode.

*   Added `output_channel_id` parameter to the `list()` methods of
    Story and Media to enable querying for documents in output channels
    other than the primary output channel.

*   Added Keyword Management interface to centrally manage keywords.

*   Added HTML::Mason Custom tags support, allowing template developers
    to write code blocks that are context sensitive.

*   Added new page extension support to the burner, which allows
    template developers to set string extensions to use for successive
    file names, rather than the traditional use of numeric file name
    extensions for successive file names.

*   Added "Text to search" option in the Advanced search of Media and
    Stories to search for documents based on the contents of their
    field.

*   All preview links are now generated by a single widget. This widget
    adds the story or media URI to the `title` attribute of the link
    tag (which is modern browsers will automatically work as a
    roll-over tooltip), makes the story or media URI copyable (by
    relying on JavaScript to actually open a new window for the
    preview), and manages selecting an output channel in which to
    preview a story.

*   Made User Group Permissions UI wieldy with larger numbers of users
    by adding a select list to choose which type of Permission to look
    at.

*   Added `contrib_id` parameter to the `list()` methods of
    Bric::Biz::Asset::Business::Story and
    Bric::Biz::Asset::Business::Media to return a list of story or
    media documents associated with a given contributor.

*   Switched Bric::Util::CharTrans from using Text::Iconv to Encode,
    thus removing the dependency on a C library (libiconv). Note that
    this has changed the API of Bric::Util::CharTrans. Its `to_utf8()`
    and `from_utf8()` methods now always convert the argument passed in
    in place. They did this before for references, but now they do it
    for plain strings, as well. Also note that use of character
    translation also now requires Perl 5.8.0 or later.

*   Added MediaType, Site, and Keyword SOAP modules.

*   Added `element` attribute to Bric::Util::Burner so that
    `$burner->get_element` should always return the element currently
    being burned.

*   Added a `throw_error()` method to Bric::Util::Burner so that
    template developers can easily throw an exception that their users
    will see in the UI.

*   Moved category selection from Media and Story Profiles into their
    own separate components so that organizations with hundreds or
    thousands of categories don't have to load them into a dropdown
    list every time an asset is edited. The category "browser" uses an
    interface similar to 'Associate Contributors', which has the
    advantage of being searchable rather than looking through a "long
    list of all categories". This feature can be enabled via the new
    `ENABLE_CATEGORY_BROWSER` bricolage.conf directive.

*   Added list paging to Desks and My Workspace.

*   Added the ability to test templates without having to deploy them
    by using "template sandboxes" for each template developer.

*   Added Template Toolkit burner support.

*   Added support for installing and upgrading Bricolage with
    PostgreSQL on a separate host.

*   Added context-sensitive help for pages that were missing it.

  For a complete list of the changes, see the [changes file].

  **ABOUT BRICOLAGE**

  Bricolage is a full-featured, enterprise-class content management and
  publishing system. It offers a browser-based interface for ease-of use, a
  full-fledged templating system with complete [HTML::Mason], [HTML::Template],
  and [Template Toolkit] support for flexibility, and many other features. It
  operates in an [Apache]/[mod_perl] environment, and uses the [PostgreSQL]
  RDBMS for its repository. A comprehensive, actively-developed open source CMS,
  Bricolage has been hailed as "Most Impressive" in 2002 by eWeek.

  Learn more about Bricolage and download it from the [Bricolage home page].

  Enjoy!

  David

*Originally published [on use Perl;]*

  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=192790
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template   Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home   page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/15330/
    "use.perl.org journal of Theory: “Bricolage-Devel 1.7.0”"
