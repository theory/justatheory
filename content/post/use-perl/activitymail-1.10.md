---
date: 2003-08-27T23:57:27Z
description: I finally got around to a new release.
lastMod: 2022-10-02T22:39:29Z
slug: activitymail-1.10
tags:
  - use Perl
  - Perl
  - activitymail
title: activitymail 1.10
---

It is my pleasure to announce the release of the [activitymail]
1.10, available shortly from your nearest CPAN mirror.

This is a major upgrade to my little CVS notification program, but I
think I got all of your requests in there (although some of the options
have changed, and the code you might have sent me most certainly has
changed!) Here's what you can look forward to as soon as your CPAN
mirror syncs:

*   Added empty lines between the text of the commit message and the
    attached diff. This looks neater in mail clients that display
    attachments inline.

*   Added -H option sending HTML email. Thanks to Hernan Otero for the
    initial implementation.

*   Added -V option to include revision numbers after each listed file.
    Thanks to Hernan Otero for the initial implementation.

*   Cut down on the number of times that data is copied in the script,
    thus reducing processing time and memory requirements, especially
    on big commits.

*   Added -w option for a link to a CVSWeb view of the diff for each
    changed file. Actually looks best when used with HTML. Thanks to
    Hernan Otero for the initial implementation.

*   Added check for binary files so that they won't be diffed.

*   Added -B option to specify a list of binary file name extensions to
    indicate files that should not be diffed.

*   New files and deleted files are now diffed against /dev/null in
    order to provide a more realistic diff.

*   Added -j option to point to a diff executable to compare added and
    deleted files. Defaults to "diff", assuming that it's in the path.

*   Added -M option to prevent messages over a maximum size from being
    emailed. Thanks to Sam Tregar.

*   Added -S option to add directory context information to the
    subject. Thanks to Kent Lindquist.

*   Branch tags are now listed in the email under their own header.
    Suggested by David Krembs.

*   Added -v option to print the version number.

*   Added POD tests.

*   Switched to Module::Build for installation.

Enjoy!

--- David

*Originally published [on use Perl;]*

  [activitymail]: http://search.cpan.org/dist/activitymail/
  [on use Perl;]: https://use-perl.github.io/user/Theory/journal/14355/
    "use.perl.org journal of Theory: “activitymail 1.10”"
