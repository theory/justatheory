--- 
date: 2005-07-19T16:18:50Z
slug: bricolage-1.8.6
title: Bricolage 1.8.6 Released
aliases: [/bricolage/1.8.6.html]
tags: [Bricolage, Perl, Content Management, Content Managment]
type: post
---

The Bricolage development team is pleased to announce the release of Bricolage
1.8.6. This maintenance release addresses numerous minor issues in Bricolage
1.8.5 and adds a number of improvements, including SOAP, document expiration,
and *bric\_queued* fixes. The most important changes include:

### Improvements

-   Added JavaScript code to validate that the username in the user profile does
    not have leading or trailing spaces. \[David\]
-   Events in the event log are now returned (and displayed) in reverse
    chronological order. \[David\]
-   The SOAP server now uses a user's template sandbox when executing previews
    (such as with `bric_soap --to-preview workflow publish`). Reported by
    Marshall. \[David\]
-   Bric::Biz::Workflow now caches calls to `allowed_desks()`. This will allow
    desks to render *much* Faster, since most assets on a desk will list the
    same desks in the “Move to” select lists. \[David\]
-   When the `PUBLISH_RELATED_ASSETS` *bricolage.conf* directive is enabled,
    aliases are now also republished. Only aliases that have previously been
    published will be republished, and only the last published version will be
    republished, rather than any versions created since the last publish.
    Suggested by Serge Sozonoff. \[David\]
-   A story or media document published with an expire date earlier than the
    scheduled publish time no longer bothers with the publish but just expires
    the story or media document. \[David\]
-   Media documents without an associated media file will no longer be displayed
    in the search results when attempting to relate a media document to an
    element. Reported by Adam Rinehart. \[David\]

### Bug Fixes

-   Form validation and group management now properly work in the user profile.
    \[David\]
-   The SFTP mover now works with `bric_queued`. \[David\]
-   Cloned stories now properly set the `published_version` attribute to `undef`
    rather than the value of the original story, thus preventing the clone from
    having a published version number greater than its current version number.
    Reported by Nate Perry-Thistle and Joshua Edelstein. \[David and Nate
    Perry-Thistle\]
-   When a category is added to a story that creates a URI conflict, the new
    category does not remain associated with the story in the story profile
    after the conflict error has been thrown. Reported by Paul Orrock. \[David\]
-   Contributor groups created in the contributor profile are no longer missing
    from the contributor manager search interface. Reported by Rachel Murray and
    Scott. \[David\]
-   The *favicon.ico* works again. \[David\]
-   Stories are now properly expired when the `BRIC_QUEUED` *bricolage.conf*
    directive is enabled. Reported by Scott. \[David\]
-   When a template is checked out of the library and then the checkout is
    canceled, it is no longer left on the desk it was moved into upon the
    checkout, but properly reshelved. Reported by Marshall. \[David\]
-   Super Bulk Edit now works for media as well as stories. Reported by Scott.
    \[David\]
-   When a template is moved to a new category, the old version of the template
    is undeployed when the new version is deployed to the new category. The
    versions in the sandbox are properly synced, as well.

For a complete list of the changes, see the [changes]. For the complete history
of ongoing changes in Bricolage, see [Bric::Changes].

Download Bricolage 1.8.6 now from the Bricolage Web site [Downloads page], from
the [SourceForge download page], and from the [Kineticode download page].

### About Bricolage

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete HTML::Mason, HTML::Template, and Template
Toolkit support for flexibility, and many other features. It operates in an
Apache/mod\_perl environment and uses the PostgreSQL RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage has been hailed as
“quite possibly the most capable enterprise-class open-source application
available” by *eWEEK*.

  [changes]: https://bricolagecms.org/news/announce/changes/bricolage-1.8.6/
  [Bric::Changes]: https://github.com/bricoleurs/bricolage/blob/master/lib/Bric/Changes.pod
  [Downloads page]: https://bricolagecms.org/downloads/
  [SourceForge download page]: https://sourceforge.net/projects/bricolage/files/
  [Kineticode download page]: https://kineticode.com/bricolage/downloads/
