---
date: 2004-03-19T06:38:41Z
description: Alllmoooost therre...
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-devel-1.7.4
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage-Devel 1.7.4
---

I'm thrilled to announce the release of Bricolage-Devel 1.7.4
"Sacramento", the first release candidate for Bricolage 1.8.0. This
version of the open-source content management system addresses all of
the bugs discovered since the release of the fourth development
release, 1.7.4, and adds several new features and numerous
improvements. The most significant changes since 1.7.3 include:

*   New Features

    * A "Bulk Publish" link in ADMIN->PUBLISHING that lets members of
      the Global Admins group publish story and media documents by
      category. [Scott]

    * Added `notes()` method to Bric::Util::Burner, along with the
      accompanying `clear_notes()`. The `notes()` method provides a
      place to store burn data data, giving template developers a way
      to share data among multiple burns over the course of publishing
      a single story in a single category to a single output channel.
      Any data stored here persists for the duration of a call to
      `burn_one()`. [David]

    * Added new contributed scripts for Bricolage button generation.
      These scripts use the Gimp to generate localized buttons for the
      Bricolage UI based on the contents of an input file. See
      contrib/button_gen/README for details. [Florian Rossol]

    * Added support for icons for all media documents when the `USE_THUMBNAILS`
      bricolage.conf directive is enabled. These rely on the presence
      of PNG icon files for each MIME type in comp/media/mime. Only one
      such icons is distributed with Bricolage,
      comp/media/mime/none.png (borrowed from the KDE project under [a
      free license]),
      which is the default icon when the MIME type of a media file is
      unknown or when no icon file exists for the MIME type of the
      media file. Administrators are free to add their own icons, and
      the `copy_gnome_icons` script in contrib makes it easy to use
      GNOME icons. [David]

    * Added `bric_template_diff` and `bric_template_patch` scripts in
      contrib/bric_template_diff. These scripts can be used to sync
      templates between two Bricolage servers. [Sam]

    * added `bric_media_load` to `contrib/`. This script copies media
      into Bricolage while accounting for the new to update existing
      media. [Sam]

    * Added HTMLArea support. This adds a new type of field to be added
      to elements and contributor types, "WYSIWYG". Such fields are
      then displayed in the UI using HTMLArea, a WYSIWYG HTML editor.
      This can be useful in particular for simple fields that often
      need emphasis added or links. It is not currently available in
      Bulk Edit or Super Bulk edit. See Bric::Admin for installation
      and configuration details. [Eric Sellers]

*   Improvements

    * The list of categories for which permissions can be granted to
      user groups to access the documents and templates in the category
      now displays the categories for each site separately, so that
      categories with same URIs (such as for the root category in each
      site) can be easily told apart. Reported by Ho Yin Au. [David]

    * The list of workflows for which permissions can be granted in the
      permissions page now includes the parenthesized name of the site
      each workflow is associated with. [David]

    * Modified the indexes on the `workflow__id` and `desk__id` columns
      of the story, media, and formatting (template) tables to be more
      efficient, being indexed only when their IDs are greater than 0
      (that is, when a story, media document, or template is actually
      on a desk and in a workflow). [David]

    * Added a method `is_fixed` to story and media objects, to
      determine whether a business asset has a fixed URL (for example,
      a Cover page). Refer to Bric::Biz::Asset::Business. [Scott]

    * Added the `ENABLE_OC_ASSET_ASSOCIATION` bricolage.conf directive
      to remove the ability to associate output channels from the story
      and media profiles. [Scott]

    * The element admin profile now automatically adds the currently
      selected site context to new elements, thus generally saving a
      step when creating new elements. [João Pedro]

    * Added an interface to 'Clone' for stories so that you can change
      the category, slug, and cover date, because otherwise an
      identical story is created, which would cause errors for some
      stories. Clones are no longer allowed to have URIs that are
      identical to the stories they were cloned from. [Scott & David]

    * Added the ability to Delete from desks (same as My Workspace).
      Note however, that you can't delete from a publish desk. [Scott]

    * Completely documented the document element classes:
      Bric::Biz::Asset::Business::Parts::Tile,
      Bric::Biz::Asset::Business::Parts::Tile::Data, and
      Bric::Biz::Asset::Business::Parts::Tile::Container. This should
      make it a bit easier on templators learning their way around the
      Bricolage API. [David]

    * Refactored quite a bit of the code in the element classes.
      Renamed the methods with "tile" in their names to use "element"
      instead (but kept the old ones around as aliases, since they're
      used throughout the UI). Added a few methods to make the
      interface more complete. [David]

    * Modified the `get_containers()` method of
      Bric::Biz::Asset::Business::Parts::Tile::Container to take an
      optional list of key name arguments, and to return only the
      container subelements with those key names. This is most useful
      in templates, where it's fairly common to get a list of container
      subelements of only one or two particular types out all at once.
      It neatly replaces code such as this:

        ``` perl
        for ( my $x = 1; my $quote = $element->get_container('quote', $x); $x++ ) {
            $burner->display_element($quote);
        }
        ```

      With this:

        ``` perl
        for my $quote ($element->get_containers('quote')) {
            $burner->display_element($quote);
        }
        ```

      And is more efficient, too. [David]

    * Modified the `get_elements()` method of
      Bric::Biz::Asset::Business::Parts::Tile::Container to take an
      optional list of key name arguments, and to return only the
      subelements with those key names. [David]

    * Added the `get_data_elements()` method to
      Bric::Biz::Asset::Business::Parts::Tile::Container. This method
      functions exactly like `get_containers()` except that it returns
      data element objects that are subelements of the container
      element. It also takes an optional list of key name arguments,
      and, if passed, will return only the subelements with those key
      names. [David]

    * The `ANY()` subroutine will now throw an exception if no
      arguments are passed to it. Suggested by Dave Rolsky. [David]

    * Added the `unexpired` parameter to the `list()` method of the
      story and media classes. It selects for stories without an expire
      date, or with an expire date set in the future. [David]

    * The "User Override" admin tool is now available to all users. But
      a user can only override another user if she has EDIT permission
      to that other user. This makes it easier for user administrators
      to masquerade as other users without having to change passwords.
      [David]

    * Eliminated another SQL performance bottleneck with simple
      searches of media assets. [João Pedro]

    * Images with no dimension greater than the `THUMBNAIL_SIZE`
      bricolage.conf directive are no longer expanded to have one side
      at least `THUMBNAIL_SIZE` pixels, but are left alone. [David]

    * Thumbnails are now displayed when searching media to related to
      an element. [David]

    * Thumbnails are now displayed in related media subelements.
      [David]

    * Added `preview_another()` method to Bric::Util::Burner. This
      method is designed to be the complement of `publish_another()`,
      to be used in templates during previews to burn and distribute
      related documents so that they'll be readily available on the
      preview server within the context of previewing another document.
      [Serge Sozonoff]

    * Added the `subelement_key_name` parameter to the `list()` method
      of the story and media classes. This parameter allows searches on
      the key name for a container element that's a subelement of a
      story or media document. [David]

    * Added support for all of the parameters to the `list_ids()`
      method of the Story, Media, and Template classes to the `list_ids()`
      method of the corresponding SOAP classes. This allows for much
      more robust searches via the SOAP interface. [David & Scott]

    * Eliminated `login_avail()` PostgreSQL function, replacing it with
      a partial constraint. This not only makes things simpler
      code-wise, but it also eliminates backup and restore problems
      where the `usr` table is missing. The downside is that it
      requires PostgreSQL 7.2 instead of our traditional minimum
      requirement of 7.1. So any PostgreSQL 7.1 users will need to
      upgrade before upgrading to this version of Bricolage. Suggested
      by Josh Berkus. [David]

*   Bug Fixes

    * `make clone` will now properly clone a database on a different
      database server, provided the host name (and port, if necessary)
      have been provided. Thanks to Ho Yin Au for the spot! [David]

    * Admin tool lists that include the number "9" in the corner of a
      table of items is now properly orange instead of green. Reported
      by Ho Yin Au. [David]

    * Bricolage works with Perl 5.6.x again, although it's pretty
      strongly deprecated. Perl 5.8.0 or later is required for
      character set conversion and if any content uses characters
      outside of US ASCII. Thanks to John Greene for the spot! [David]

    * Image files uploaded in formats not recognized by Image::Info no
      longer trigger an error. Reported by Alexander Ling. [David]

    * Changing the cover date of a media document once again correctly
      updates the primary URI of the media document. Reported by Serge
      Sozonoff. [David]

    * Fixed API that was causing no elements to be returned on "Add
      sub-elements" page, when "Filter by site context" was turned on.
      [João Pedro]

    * When the SOAP server serializes and deserializes element
      templates, it now correctly identifies the element by its key
      name, rather than its name. Thanks to João Pedro for the spot!
      [David]

    * The template profile's "cheat sheet" of the subelements of an
      element now correctly display subelement key names instead of
      munging element names, as was required before version 1.7.0.
      [João Pedro]

    * `Bric::SOAP::Category->list_ids` now converts site names to site
      IDs. [João Pedro]

    * `Bric::Util::Burner->preview` once again defaults to previewing
      in an asset's primary output channel instead of using the
      element's primary output channel. [João Pedro]

    * Added `first_publish_date` attribute to the SOAP input and output
      for stories and media. [David]

    * The category SOAP class now correctly calls `lookup()` with the
      site ID to prevent multiple categories with the same names but in
      different sites from being looked up. [João Pedro]

    * User overrideable preferences are now properly checked for
      permissions to allow users with READ permission to a user to see
      the permissions. [David]

    * Users can now edit their own user-overrideable preferences.
      [David]

    * Group management now works more correctly in user profiles where
      users have on READ access to the user object. [David]

    * Removed queries added in 1.7.2 that were running at Bricolage
      startup time. They could cause DBI to cache a database handle and
      return it after Apache forks, leading to strange errors such as
      "message type 0x49 arrived from server while idle", and
      occasionally a frozen server. [David]

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

  [a       free license]: http://artist.kde.org/new/license.html#others
  [changes file]: http://sourceforge.net/project/shownotes.php?release_id=224711
  [HTML::Mason]: http://www.masonhq.com/
  [HTML::Template]: http://search.cpan.org/dist/HTML-Template/
  [Template Toolkit]: http://www.tt2.org/
  [Apache]: http://httpd.apache.org/
  [mod_perl]: http://perl.apache.org/
  [PostgreSQL]: http://www.postgresql.org/
  [Bricolage home page]: http://bricolage.cc/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/17961/
    "use.perl.org journal of Theory: “Bricolage-Devel 1.7.4”"
