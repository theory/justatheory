---
date: 2004-09-13T17:04:28Z
description: The Bricolage development team is pleased to announce the release of Bricolage 1.8.2.
lastMod: 2022-10-02T22:39:29Z
slug: bricolage-1.8.2-released
tags:
  - use Perl
  - Perl
  - Bricolage
title: Bricolage 1.8.2 Released
---

This maintenance release addresses quite a large number of issues in
Bricolage 1.8.1. The most important changes were to enhance Unicode
support in Bricolage. Bricolage now internally handles all text content
as UTF-8 strings, thus enabling templates to better control the
manipulation of multibyte characters. Other changes include better
performance for searches using the `ANY()` operators and more
intelligent transaction handling for distribution jobs. Here are the
other highlights of this release:

**Improvements**

*   Bricolage now runs under a DSO `mod_perl` as long as it uses a Perl
    compiled with `-Uusemymalloc` *or* `-Ubincompat5005`. See [The `mod_perl`
    FAQ]
    for details.

*   Alerts triggered to be sent to users who don't have the appropriate
    contact information will now be logged for those users so that they
    can see them and acknowledge them under "My Alerts".

*   Added `bric_media_dump` script to `contrib/`.

*   The category association interface used in the story profile when
    the `ENABLE_CATEGORY_BROWSER` *bricolage.conf* directive is enabled
    now uses radio buttons instead of a link to select the primary
    category. Suggested by Scott Lanning.

*   Existing jobs are now executed within their own transactions, as
    opposed to no transaction specification. This means that each job
    must succeed or fail independent of any other jobs. New jobs are
    executed before being inserted into the database so as to keep them
    atomic within their surrounding transaction (generally a UI
    request). All this means that transactionality is much more
    intelligent for jobs and will hopefully eliminate job table
    deadlocks.

*   All templates now execute with UTF-8 character strings enabled.
    This means that any templates that convert content to other
    character sets might need to change the way they do so. For
    example, templates that had used `<%filter>` blocks to convert
    content to another encoding using something like `Encode::from_to($_,
    'utf-8', $encoding)` must now use something like `$_ =
    Encode::encode($encoding, $_)`, instead. Bric::Util::CharTrans
    should continue to do the right thing.

*   Added `encoding` attribute to Bric::Util::Burner so that, if
    templates are outputting something other than Perl `utf8` decoded
    data, they can specify what they're outputting, and the file opened
    for output from the templates will be set to the proper mode.
    Applies to Perl 5.8.0 and later only.

*   Added `SFTP_HOME` *bricolage.conf* directive to specify the home
    directory and location of SSH keys when SSH is enabled.

**Bug Fixes**

*   `make clone` once again properly copies the *lib/Makefile.PL* and *bin/Makefile.PL*
    files from the source directory.

*   Added missing language-specifying HTML attributes so as to properly
    localize story titles and the like.

*   The list of output channels to add to an element in the element
    profile now contains the name of the site that each is associated
    with, since different sites can have output channels with the same
    names.

*   The "Advanced Search" interface once again works for searching for
    related story and media documents.

*   Bricolage no longer attempts to email alerts to an empty list of
    recipients. This will make your SMTP server happier.

*   The version numbering issues of Bricolage modules have all been
    worked out after the confusion in 1.8.1. This incidentally allows
    the HTML::Template and Template Toolkit burners to be available
    again.

*   Misspelling the name of a key name tag or including a
    non-repeatable field more than once in Super Bulk Edit no longer
    causes all of the changes in that screen to be lost.

*   When a user overrides the global "Date/Time Format" and "Time Zone"
    preferences, the affects of the overrides are now properly
    reflected in the UI.

*   Publishing a story or media document along with its related story
    or media documents from a publish desk again correctly publishes
    the original asset as well as the relateds.

*   Deleted output channels no longer show up in the select list for
    story type and media type elements.

*   Deleting a workflow from the workflow manager now properly updates
    the workflow cache so that the deleted workflow is removed from the
    left navigation without a restart.

*   When Bricolage notices that a document or template is not in
    workflow or on a desk when it should be, it is now more intelligent
    in trying to select the correct workflow and/or desk to put it on,
    based on current workflow context and user permissions.

*   Content submitted to Bricolage in the UTF-8 character set is now
    always has the `utf8` flag set on the Perl strings that store it.
    This allows fields that have a maximum length to be truncated to
    that length in characters instead of bytes.

*   Elements with autopopulated fields (e.g., for image documents) can
    now be created via the SOAP interface.

*   Fixed a number of the parameters to the `list()` method of the
    Story, Media, and Template classes to properly handle an argument
    using the `ANY` operator. These include the `keyword` and `category_uri`
    parameters. Passing an `ANY` argument to these parameters before
    this release could cause a well-populated database to lock up with
    an impossible query for hours at a time.

*   Template sandboxes now work for the Template Toolkit burner.

For a complete list of the changes, see the [changes]. For the complete history
of ongoing changes in Bricolage, see [Bric::Changes].

Download Bricolage 1.8.2 now from the Bricolage Website [Downloads page], from
the [SourceForge download page], and from the [Kineticode download page].

**About Bricolage**

Bricolage is a full-featured, enterprise-class content management and publishing
system. It offers a browser-based interface for ease-of use, a full-fledged
templating system with complete HTML::Mason, HTML::Template, and Template
Toolkit support for flexibility, and many other features. It operates in an
Apache/mod_perl environment and uses the PostgreSQL RDBMS for its repository. A
comprehensive, actively-developed open source CMS, Bricolage was hailed as
"quite possibly the most capable enterprise-class open-source application
available by *eWEEK*."

Enjoy!

--The Bricolage Team

*Originally published [on use Perl;]*

  [The `mod_perl`     FAQ]: http://perl.apache.org/docs/1.0/guide/install.html#When_DSO_can_be_Used
  [changes]: http://www.bricolage.cc/news/announce/changes/bricolage-1.8.2/
  [Bric::Changes]: http://www.bricolage.cc/docs/api/current/Bric::Changes
  [Downloads page]: http://www.bricolage.cc/downloads/
  [SourceForge download page]: http://sourceforge.net/project/showfiles.php?group_id=34789
  [Kineticode download page]: http://www.kineticode.com/bricolage/index2.html
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/20856/
    "use.perl.org journal of Theory: “Bricolage 1.8.2 Released”"
