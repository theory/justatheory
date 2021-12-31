--- 
date: 2004-10-15T23:28:38Z
slug: svnnotify-2.22
title: SVN::Notify 2.22 Improves Diff Parsing
aliases: [/computers/programming/perl/modules/svnnotify_2.22.html]
tags: [Perl, SVN::Notify, Subversion, diffs]
type: post
---

I released SVN::Notify 2.22 last night. The new version fixes a few issues in
the parsing of diffs in the HTML subclasses. SVN::Notify::HTML now properly
identifies added, deleted, and property setting sections of an included diff
file when creating IDs. The lists of the affected files near the top of the
email links down into the diff, and now also includes links to the locations in
the diff for files that have had only their properties changed.

SVN::Notify::HTML::ColorDiff had similar updates. It now properly outputs added
and deleted files in the diff in separate sections, instead of grouping them
under the last modified file listed. It also creates separate sections for files
that have only had their properties changed. I've put an example [here].

Grab the new version from [CPAN] now

  [here]: {{% link "/code/svnnotify/svnnotify-2.22_colordiff_example.html" %}}
    "SVN::Notify 2.22 sample ColorDiff output"
  [CPAN]: https://metacpan.org/dist/SVN-Notify/ "SVN::Notify on CPAN"
