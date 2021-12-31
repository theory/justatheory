--- 
date: 2005-03-19T07:15:58Z
slug: bricolage-1.8.5
title: Bricolage 1.8.5 Released
aliases: [/bricolage/announce/1.8.5.html]
tags: [Bricolage, Shipping, Perl, Postgres, Apache, mod_perl]
type: post
---

The Bricolage development team is pleased to announce the release of Bricolage
1.8.5. This maintenance release addresses a number of issues in Bricolage 1.8.3
and adds a number of improvements (there was no announcement for the short-lived
1.8.4 release). The SOAP server in particular sees improvements in this release,
with improved character set support; better support for related stories and
media using URIs in addition to IDs; and as support for top-level element
relations. Issues with the ordering of story elements have also been corrected,
as well as errors when attempting to revert a story or media document or
template. Here are the other highlights of this release:

### Improvements

-   Added Linux startup script *contrib/start\_scripts/linux*. \[David\]
-   Related story and media elements managed through the SOAP server can now use
    a combination of URI and site ID to identify related assets in addition to
    the existing approach of using story and media IDs. \[David\]
-   A list of subelements is now less likely to mysteriously become out of order
    and thus lead to strange action-at-a-distance errors. And even if they do
    become out of order, the error message will be more appropriate (“Warning!
    State inconsistent” instead of “Can't call method "get\_name" on an
    undefined value”). Reported by Curtis Poe. \[David\]
-   The SOAP media interface now supports creating relationships between the
    media documents elements and other story and media documents, just like the
    SOAP story interface does. \[David\]
-   The SOAP interface now supports Related stories and media on story type and
    media type elements just as in the UI. This involved the somewhat hackish
    necessity for including the “related\_story\_id” and “related\_media\_id”
    (or “related\_story\_uri” and “related\_media\_uri”) attributes in the
    “elements” XML element, but it does the trick. \[David\]

### Bug Fixes

-   Calls to publish documents via SOAP will no longer fail if the
    `published_version` attribute is not specified and the document to be
    published has never been published before. \[David\]
-   The Bricolage virtual FTP server will no longer fail to start if Template
    Toolkit is installed but its version number is less than 2.14. Reported by
    Adam Rinehart. \[David\]
-   Stories and Media created or updated via the SOAP interface will now
    associate contributors of the appropriate type, instead of “All
    Contributors”. \[Scott & David\]
-   Deleting an element that has a template no longer causes an error. Thanks to
    Susan for the spot! \[David\]
-   Eliminated encoding errors when using the SOAP interface to output stories,
    media, or templates with wide characters. Reported by Scott Lanning.
    \[David\]
-   Reverting (stories, media, templates) no longer gives an error. Reported by
    Simon Wilcox, Rachel Murray, and others. \[David\]
-   Publishing a published version of a document that has a later version in
    workflow will no longer cause that later version to be mysteriously removed
    from workflow. This could be caused by passing a document looked up using
    the `published_version` to `list()` to `$burner->publish_another` in a
    template. \[David\]
-   The SOAP server story and media interfaces now support elements that contain
    both related stories and media, rather than one or the other. \[David\]
-   Attempting to preview a story or media document currently checked out to
    another user no longer causes an error. Reported by Paul Orrock. \[David\]
-   Custom fields with default values now have their values included when they
    are added to stories and media. Thanks to Clare Parkinson for the spot!
    \[David\]
-   The `bric_queued` script now requires a username and password and will
    authenticate the user. This user will then be used for logging events. All
    events logged when a job is run via the UI are now also logged by
    `bric_queued`. \[Mark and David\]
-   Preview redirections now use the protocol setting of the preview output
    channel if it’s available, and falls back on using “http://” when it’s not,
    instead of using the hard-coded “http://”. Thanks to Martin Bacovsky for the
    spot! \[David\]
-   The `has_keyword()` method in the Business class (from which the story and
    media classes inherit) now works. Thanks to Clare Parkinson for the spot!
    \[David\]
-   Clicking a link in the left-side navigation after the session has expired
    now causes the whole window to show the login form, rather than it showing
    inside the nav frame, which was useless. \[Marshall\]
-   The JavaScript that validates form contents once again works with htmlArea,
    provided htmlArea itself is patched. See the relevant [htmlArea bug report]
    for the patch. As of this writing, you must run the version of htmlArea in
    CVS. \[David & Marshall\]
-   The JavaScript that handles the double list manager has been vastly
    optimized. It should now be able to better handle large lists, such as a
    list of thousands of categories. Reported by Scott. \[Marshall\]
-   Uploading a new image to a media document with a different media type than
    the previous image no longer causes an Imager error. \[David\]

For a complete list of the changes, see the [changes]. For the complete history
of ongoing changes in Bricolage, see [Bric::Changes].

Download Bricolage 1.8.5 now from the Bricolage Web site [Downloads page], from
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

  [htmlArea bug report]: http://sourceforge.net/tracker/index.php?func=detail&aid=1155712&group_id=69750&atid=525656
  [changes]: http://www.bricolage.cc/news/announce/changes/bricolage-1.8.5/
  [Bric::Changes]: http://www.bricolage.cc/docs/api/current/Bric::Changes
  [Downloads page]: http://www.bricolage.cc/downloads/
  [SourceForge download page]: http://sourceforge.net/project/showfiles.php?group_id=281500
  [Kineticode download page]: https://kineticode.com/bricolage/index2.html
