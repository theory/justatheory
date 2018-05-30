--- 
date: 2004-11-10T01:21:15Z
slug: bricolage-1.8.3
title: Bricolage 1.8.3 Released
aliases: [/bricolage/announce/1.8.3.html]
tags: [Bricolage, Shipping, Perl, Postgres, Apache, mod_perl]
type: post
---

The Bricolage development team is pleased to announce the release of Bricolage
1.8.3. This maintenance release addresses a number of issues in Bricolage 1.8.2.
The most important changes eliminate or greatly reduce the number of deadlocks
caused during bulk publishes of many documents. Other changes include new
contributed scripts for importing contributors and for generating thumbnail
images, Russian localization, and various fixes for database transaction,
template formatting, and various user interface fixes. Here are the other
highlights of this release:

### Improvements

-   Added *contrib/thumbnails/precreate-thumbs.pl* script to pre-create
    thumbnails from images. Useful for upgraders. \[Scott\]
-   Added *contrib/bric\_import\_contribs* to import contributors from a
    tab-delimited file. Development by Kineticode, sponsored by the RAND
    Corporation. \[David\]
-   Added the `published_version` parameter to the `list()` methods of the
    story, media, and template classes. This parameter forces the search to
    return the versions of the assets as they were last published, rather than
    the most recent version. This will be most useful to those looking up other
    documents in templates and publishing them, as a way of avoiding pulling
    documents out from other anyone who might have them checked out! \[David\]
-   All publishing and distribution jobs are now executed in their own
    transactions when they are triggered by the user interface. This is to
    reduce the chances of a deadlock between long-running publishing
    transactions. \[David\]
-   Optimized SQL queries for key names or that order by string values to use
    indexes in the `list()` and `list_ids()` methods of the story, media, and
    template classes. \[David\]
-   Added Russian localization. \[Sergey Samoilenko\].
-   Changed the foreign keys in the story, media, and formatting (template)
    tables so that `DELETE`s do not cascade, but are restricted. This means that
    before deleting any source, element, site, workflow, or other related object
    that has a foreign key reference in an asset table, those rows must be
    deleted. Otherwise, PostgreSQL will throw an exception. Hopefully, this will
    put a stop to the mysterious but very rare disappearance of stories from
    Bricolage. \[David\]
-   A call to `$burner->burn_another` in a template that passes in a date/time
    string in the future now causes a publish job to be scheduled for that time,
    rather than immediate burning the document and then scheduling the
    distribution to take place in the future. Reported by Ashlee Caul. \[David\]
-   Changing the sort order of a list of items in a search interface now
    properly reverses the entire collection of object over the pages, rather
    than just the objects for the current page. Thanks to Marshall for the spot!
    \[David\]

### Bug Fixes

-   Publishing stories not in workflow via the SOAP server works again.
    \[David\]
-   The Burner object’s `encoding` attribute is now setable as well as readable.
    \[David\]
-   The category browser works again. \[David\]
-   Fixed Media Upload bug where the full local path was being used, by adding a
    “winxp” key to Bric::Util::Trans::FS to account for an update to
    HTTP::BrowserDetect. \[Mark Kennedy\]
-   Instances of a required custom field in story elements is no longer required
    once it has been deleted from the element definition in the element manager.
    Reported by Rod Taylor. \[David\]
-   A false value passed to the `checked_out` parameter of the `list()` and
    `list_ids()` methods of the story, media, and template (formatting) classes
    now properly returns only objects or IDs for assets that are not checked
    out. \[David\]
-   The cover date select widget now works properly in the clone interface when
    a non-ISO style date preference is selected. Thanks to Susan G. for the
    spot! \[David\]
-   Sorting templates based on Asset Type (Element) no longer causes an error.
    \[David\]
-   Fixed a number of the callbacks in the story, media, and template profiles
    so that they didn’t clear out the session before other callbacks were done
    with it. Most often seen as the error “Can’t call method ‘get\_tiles’ on an
    undefined value” in the media profile, especially with IE/Windows (for some
    unknown reason). Reported by Ed Stevenson. \[David\]
-   Fixed typo in clone page that caused all output channels to be listed rather
    than only those associated with the element itself. \[Scott\]
-   Fixed double listing of the “All” group in the group membership double list
    manager. \[Christian Hauser\]
-   Image buttons now correctly execute the `onsubmit()` method for forms that
    define an `onsubmit` attribute. This means that, among other things, changes
    to a group profile will persist when you click the “Permissions” button.
    \[David\]
-   Simple search now works when it is selected when the “Default Search”
    preference is set to “Advanced”. Reported by Marshall Roch. \[David\]
-   Multiple alert types set up to trigger alerts for the same event will now
    all properly execute. Thanks to Christian Hauser for the spot! \[David\]
-   Publishing stories or media via SOAP with the `published_only` parameter
    (`--published-only` for *bric\_republish*) now correctly republishes the
    published versions of documents even if the current version is in workflow.
    Reported by Adam Rinehart. \[David\]
-   Users granted a permission greater than READ to the members of the “All
    Users” group no longer get such permission to any members of the “Global
    Admins” group unless they have specifically been granted such permission to
    the members of the “Global Admins” group. Thanks to Marshall Roch for the
    spot! \[David\]

For a complete list of the changes, see the [changes]. For the complete history
of ongoing changes in Bricolage, see [Bric::Changes].

Download Bricolage 1.8.3 now from the Bricolage Website [Downloads page], from
the [SourceForge download page], and from the [Kineticode download page].

### About Bricolage

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete HTML::Mason, HTML::Template, and Template
Toolkit support for flexibility, and many other features. It operates in an
Apache/mod\_perl environment and uses the PostgreSQL RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage was hailed as
“quite possibly the most capable enterprise-class open-source application
available” by *eWEEK*.

Enjoy!

--The Bricolage Team

  [changes]: http://www.bricolage.cc/news/announce/changes/bricolage-1.8.3/
  [Bric::Changes]: http://www.bricolage.cc/docs/api/current/Bric::Changes
  [Downloads page]: http://www.bricolage.cc/downloads/
  [SourceForge download page]: http://sourceforge.net/project/showfiles.php?group_id=281500
  [Kineticode download page]: https://www.kineticode.com/bricolage/index2.html
