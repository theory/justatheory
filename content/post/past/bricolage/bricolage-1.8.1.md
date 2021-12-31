--- 
date: 2004-07-08T22:12:24Z
slug: bricolage-1.8.1
title: Bricolage 1.8.1 Released
aliases: [/bricolage/announce/1.8.1.html]
tags: [Bricolage, Shipping]
type: post
---

The Bricolage development team is pleased to announce the release of Bricolage
1.8.1. This maintenance release address a number of issues in Bricolage 1.8.0.
Here are the highlights:

### Improvements

-   More complete Traditional Chinese and Simplified Chinese localizations.
    Also, the Mandarin localization now simply inherits from the Traditional
    Chinese localization.
-   `make clone` now copies the *lib* directory and all of the *bin* scripts
    from the target to the clone, rather than from the sources. This allows any
    changes that have been made to scripts and classes to be properly cloned.
-   When installing Bricolage, it will now allow you to proceed if the database
    already exists by asking if you want to create the Bricolage tables in the
    existing database. Suggested by Mark Fournier and Marshall Roch.
-   The installer is now a bit smarter in how it handles loading the
    `log_config` (or `config_log`, as the case may be) module.
-   Added language-specific style sheets. This is especially useful for
    right-to-left languages or for languages that require special fonts.
-   The “New Alias” search interface now displays thumbnails when searching for
    media documents to alias and the `USE_THUMBNAILS` *bricolage.conf* directive
    is enabled.
-   Aliases can now be made to documents within the same site.
-   The SOAP interface for importing and exporting elements now properly has
    “key\_name” XML elements instead of “name” XML elements. The changes are
    backwards compatible with XML exported from Bricolage 1.8.0 servers,
    however.
-   Added `move()` method to the virtual FTP interface. This means that to
    deploy a template, rather than having to rename it locally to append
    “.deploy” one can simply move in FTP to its new name with “.deploy” on
    appended to the new name.
-   Document expirations are now somewhat more intelligent. Rather than just
    scheduling an expiration job only if there is an expiration date the first
    time a document is published, Bricolage will now always schedule an
    expiration job for a document provided that one does not already exist
    (scheduled or completed) for the same time and for one of the file resources
    for the document. This should allow people to more easily and arbitrarily
    expire content whenever necessary.
-   Burner notes now persist for all sub burns (triggered by `publish_another()`
    and `preview_another()` in a single burn.
-   Added ability to create and manage groups of objects for several different
    types of objects. Also added the ability manage group membership within the
    administrative profiles for those objects. This change makes it possible to
    give users permission to administer subsets of objects. The new groupable
    objects are:
    -   Preferences
    -   Groups
    -   Alert Types
    -   Element Types
    -   Keywords
    -   Contributors
-   Alert rules are now evaluated within a safe compartment (using Safe.pm) to
    prevent security exploits.
-   The Bulk Publish admin tool is no longer limited to use only by members of
    the Global Admins group. Now anyone can use it. All one needs is READ
    permission to the categories of stories, and PUBLISH permission to the
    stories and media documents to be published.

### Bug Fixes

-   Eliminated “Bareword "ENABLE\_HTMLAREA" not allowed while "strict subs" in
    use” warning that prevented startup for some installations.
-   Changes made to user or contributor contacts without changing any other part
    of the user or contributor object are now properly saved.
-   The upgrade to 1.8.0 now correctly updates story URIs that use the URI
    Suffix of an output channel instead of using the URI Prefix twice.
-   Aliases of Image, Audio, or Video media documents no longer remain stuck on
    desks.
-   Related media and story subelements of media documents now work properly.
-   Calls to `preview_another()` in Bric::Util::Burner will now use any
    templates in the current user's sandbox and properly burn them to the
    preview root rather than to the staging root used for publishing.
-   Contributor fields for roles other than the default role now properly store
    and retain their values.
-   The virtual FTP server now properly checks out templates when a template is
    uploaded and is already in workflow.
-   Uploading a non-existent template via the virtual FTP server now correctly
    creates a new template. The type of template depends on the name of the
    template being uploaded, and for element templates, on whether there is an
    element with the appropriate key name. The user must have CREATE permission
    to All Templates or to the start desk in the first template workflow in the
    relevant site.
-   Reverting a document or template to the current version number now properly
    reverts all changes to the time the user checked out the document or
    template. Reversion is also a bit more efficient in how it looks up the
    previous version in the database.
-   The SOAP server now rolls back any changes whenever an error is thrown. This
    prevents problems when a few objects are created or updated before an
    exception is thrown. Now any error will cause the entire SOAP request to
    fail. Thanks to Neal Sofge for the spot!

For a complete list of the changes, see the [release notes and changes list].
For the complete history of ongoing changes in Bricolage, see [Bric::Changes].

Download Bricolage 1.8.1 now from the [SourceForge download page] or from the
[Kineticode download page]

### About Bricolage

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete HTML::Mason, HTML::Template, and Template
Toolkit support for flexibility, and many other features. It operates in an
Apache/mod\_perl environment and uses the PostgreSQL RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage was hailed as “Most
Impressive” in 2002 by eWeek.

Enjoy!

--The Bricolage Team

  [release notes and changes list]: http://sourceforge.net/project/shownotes.php?release_id=251820
    "Read the 1.8.1 rlease notes and changes"
  [Bric::Changes]: http://www.bricolage.cc/docs/api/current/Bric::Changes
    "See Bric::Changes"
  [SourceForge download page]: http://sourceforge.net/project/showfiles.php?group_id=34789
    "Download 1.8.1 from SourceForge"
  [Kineticode download page]: https://kineticode.com/bricolage/index2.html
    "Download 1.8.1 from Kineticode"
